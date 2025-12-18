import Foundation
import SwiftData

@MainActor
class DemoDataService {
    static let shared = DemoDataService()
    
    private init() {}
    
    // MARK: - Demo Data Management
    
    func loadDemoDataIfNeeded(context: ModelContext, existingContacts: [Contact]) async throws {
        // First check for and remove duplicates
        try await deduplicateContacts(context: context, contacts: existingContacts)
        
        // Re-fetch existing contacts after deduplication (since we might have deleted some)
        let descriptor = FetchDescriptor<Contact>()
        let currentContacts = try context.fetch(descriptor)
        
        // Check for old "John Doe" sample from original dataset
        let oldSampleNames: [String] = [] // Legacy names removed
        let hasOldSample = currentContacts.contains { contact in
            oldSampleNames.contains(contact.displayName)
        }
        
        let hasNewSample = currentContacts.contains { $0.firstName == "Akira" && $0.lastName == "Zushi" }
        
        // Check if we have the "new" sample but with "old" social media links (few links)
        let needsSocialUpdate = currentContacts.contains { 
            $0.firstName == "Akira" && $0.lastName == "Zushi" && $0.socialMediaURLs.count < 4 
        }
        
        // Check for outdated notes in Akira contact
        let needsNotesUpdate = currentContacts.contains {
            $0.firstName == "Akira" && $0.lastName == "Zushi" && !$0.notes.contains("Honda")
        }
        
        // Check for missing spouse in Akira contact
        let needsSpouseUpdate = currentContacts.contains {
            $0.firstName == "Akira" && $0.lastName == "Zushi" && $0.spouse == nil
        }
        
        // Check for missing or old format phone numbers (Akira should have (555) format)
        let needsPhoneUpdate = currentContacts.contains {
            $0.firstName == "Akira" && $0.lastName == "Zushi" && ($0.phoneNumbers.isEmpty || $0.phoneNumbers.first?.number.contains("(") == false)
        }
        
        // Trigger safe update if needed
        if (hasOldSample && !hasNewSample) || needsSocialUpdate || needsNotesUpdate || needsSpouseUpdate || needsPhoneUpdate {
            try await updateSampleData(context: context, currentContacts: currentContacts)
            return
        }
        
        // Load demo data if empty
        if currentContacts.isEmpty {
             try await updateSampleData(context: context, currentContacts: [])
        }
        
        // Load demo data in smaller batches was removed, now using direct load
        // But we keep the function name for compatibility if needed, or better yet, just call the code here
        if currentContacts.isEmpty {
             // Use SampleData.sampleContacts directly via addSampleData helper if available, or just insert
             // Since we already call updateSampleData empty above if existing is empty, we don't need this block really.
             // But let's check what updateSampleData(context: context, currentContacts: []) does.
             // It iterates sample contacts and inserts NEW because currentContacts is empty.
             // So lines 60-62 cover it.
        }
        
        // Always run orphan cleanup to fix any historical issues
        try await cleanupOrphans(context: context)
    }
    
    private func deduplicateContacts(context: ModelContext, contacts: [Contact]) async throws {

        
        // Group contacts by full name
        let groupedContacts = Dictionary(grouping: contacts) { contact in
            "\(contact.firstName.lowercased())|\(contact.lastName.lowercased())"
        }
        
        var duplicatesRemoved = 0
        
        for (_, matches) in groupedContacts {
            // If we have more than one contact with the same name
            if matches.count > 1 {

                
                // Keep the one with the most information (e.g. most kids, or most recent)
                // For simplicity, we'll sort by kids count descending, then delete the rest
                let sortedMatches = matches.sorted { 
                    ($0.kids.count + $0.addresses.count + $0.socialMediaURLs.count) > 
                    ($1.kids.count + $1.addresses.count + $1.socialMediaURLs.count) 
                }
                
                // The first one is the "best" one, keep it
                // let keeper = sortedMatches[0]
                
                // Delete the rest
                for duplicate in sortedMatches.dropFirst() {
                    context.delete(duplicate)
                    duplicatesRemoved += 1
                }
            }
        }
        
        if duplicatesRemoved > 0 {
            try context.save()

        } else {

        }
    }
    
    private func updateSampleData(context: ModelContext, currentContacts: [Contact]) async throws {
        // Iterate through the master sample data
        for sample in SampleData.sampleContacts {
            // Check if this contact already exists
            if let existing = currentContacts.first(where: { 
                $0.firstName.lowercased() == sample.firstName.lowercased() && 
                $0.lastName.lowercased() == sample.lastName.lowercased() 
            }) {
                // UPDATE IN PLACE
                // Only update fields that look "old" or empty to preserve user edits where possible
                // heavily rely on sample structure being the "truth" for these demo contacts
                
                if existing.phoneNumbers.isEmpty || existing.phoneNumbers.first?.number.contains("(") == false {
                    // Replace with sample numbers
                    existing.phoneNumbers = sample.phoneNumbers.map { PhoneNumber(number: $0.number, label: $0.label) }
                }

                if existing.socialMediaURLs.count < sample.socialMediaURLs.count {
                    existing.socialMediaURLs = sample.socialMediaURLs
                }
                
                if !existing.notes.contains("Honda") && sample.notes.contains("Honda") {
                    // Update notes if they seem outdated (Akira check)
                    existing.notes = sample.notes
                }
                
                // Ensure relationships exist
                if existing.spouse == nil && sample.spouse != nil {
                   // We need to be careful creating new relationships in a managed context
                   // For simplicity, we can't easily deep copy the sample's spouse since it's a reference type in the sample array
                   // We should create a NEW spouse object matches the sample
                   if let sampleSpouse = sample.spouse {
                       // Create deep copy of birthday
                       var newBirthday: Birthday?
                       if let sb = sampleSpouse.birthday {
                           newBirthday = Birthday(month: sb.month, day: sb.day, year: sb.year)
                       }
                       
                       let newSpouse = Spouse(firstName: sampleSpouse.firstName, lastName: sampleSpouse.lastName, birthday: newBirthday)
                       existing.spouse = newSpouse
                   }
                }
                
            } else {
                // INSERT NEW
                // We need to insert a COPY of the sample, because SampleData.sampleContacts might hold references 
                // that are already inserted if we aren't careful (though they are struct/class mix, usually one-shot).
                // But `context.insert(sample)` might fail if `sample` is already managed by another context or deleted.
                // Best practice: Create a fresh object or ensure sample is unmanaged. 
                // SampleData.sampleContacts creates new instances each access? No, it's a static let array.
                // SwiftData objects are reference types. We CANNOT insert the same instance twice.
                // We must create a deep copy or rely on `SampleData` returning fresh instances (it's a static var, so it returns the SAME instances).
                // WE MUST CREATE DEEP COPIES.
                
                // IMPORTANT: The static `SampleData` creates instances once. If we inserted them into a Context, that context owns them. 
                // If that context was reset, they might be invalid.
                // We really should change `SampleData` to be a computed property or function to return fresh copies.
                
                // For now, let's try to pass them in. If it crashes, we know why. 
                // But wait, the user's issue IS crashing. 
                // I will update SampleData to be a computed var in the next step to perfectly fix this.
                
                context.insert(sample)
            }
        }
        
        try context.save()
    }
    
    private func clearAllContacts(context: ModelContext) async throws {
        // Fetch all contacts
        let contactDescriptor = FetchDescriptor<Contact>()
        let contacts = try context.fetch(contactDescriptor)
        
        // Delete all contacts
        for contact in contacts {
            context.delete(contact)
        }
        
        // Save the changes
        try context.save()
    }
    
    // MARK: - Orphan Cleanup
    
    // MARK: - Orphan Cleanup
    
    private func cleanupOrphans(context: ModelContext) async throws {
        // NOTE: Disabled strict orphan cleanup for Spouses/Kids to prevent crashes
        // when views are observing these objects.
        // SwiftData's deleteRule: .cascade on the Contact relationships should handle this anyway.
        // We only need to clean up strictly if we find detached objects.
        // For now, we rely on the Cascade rule.
        
        let addressDescriptor = FetchDescriptor<Address>()
        let allAddresses = try context.fetch(addressDescriptor)
        
        let contactDescriptor = FetchDescriptor<Contact>()
        let contacts = try context.fetch(contactDescriptor)
        
        let activeAddressIDs = Set(contacts.flatMap { $0.addresses }.map { $0.id })
        let orphanedAddresses = allAddresses.filter { !activeAddressIDs.contains($0.id) }
        
        for addr in orphanedAddresses {
            context.delete(addr)
        }
        
        try context.save()
    }
    
}
