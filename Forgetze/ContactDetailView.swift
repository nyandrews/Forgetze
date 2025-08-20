import SwiftUI
import SwiftData
import Contacts
import EventKit
import PDFKit
import UIKit

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    
    let contact: Contact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    Text(contact.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Notes prominently displayed below the name
                    if !contact.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(contact.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    

                }
                .padding(.horizontal)
                
                // Birthday Section
                if let birthday = contact.birthday {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "gift")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Birthday")
                                .font(.headline)
                                .foregroundColor(appSettings.primaryColor.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(birthday.displayString)
                                .font(.title2)
                            
                            Text(birthday.ageDisplayString)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Children Section
                if contact.hasKids {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.3")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Children (\(contact.kidsCount))")
                                .font(.headline)
                                .foregroundColor(appSettings.primaryColor.color)
                        }
                        
                        VStack(spacing: 16) {
                            ForEach(contact.kids) { kid in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(kid.displayName)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    if let birthday = kid.birthday {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Born \(birthday.shortDisplayString)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Text("(\(birthday.ageDisplayString))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    } else {
                                        Text("No birthday set")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                                }
                
                // Social Media Section - At the bottom
                if contact.hasSocialMedia {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Social Media")
                                .font(.headline)
                                .foregroundColor(appSettings.primaryColor.color)
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }, id: \.self) { url in
                                Button(action: {
                                    if let url = URL(string: url) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Text(url)
                                            .font(.body)
                                            .foregroundColor(appSettings.primaryColor.color)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(appSettings.primaryColor.color)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Contact Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Primary Actions
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    
                    Divider()
                    
                    // Export & Share
                    Button("Export as PDF") {
                        exportAsPDF()
                    }
                    
                    Button("Export to iOS Contacts") {
                        exportToIOSContacts()
                    }
                    
                    Button("Share Contact") {
                        shareContact()
                    }
                    
                    Divider()
                    
                    // Utility Actions
                    Button("Copy Contact Info") {
                        copyContactInfo()
                    }
                    
                    if let birthday = contact.birthday {
                        Button("Set Birthday Reminder") {
                            setBirthdayReminder(birthday: birthday)
                        }
                    }
                    
                    Divider()
                    
                    // Destructive Actions
                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(appSettings.primaryColor.color)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ContactEditView(contact: contact)
        }
        .alert("Delete Contact", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteContact()
            }
        } message: {
            Text("Are you sure you want to delete this contact? This action cannot be undone.")
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(successMessage)
        }
    }
    
    private func deleteContact() {
        modelContext.delete(contact)
        
        do {
            try modelContext.save()
            // Navigate back
        } catch {
            // Handle error
        }
    }
    
    // MARK: - Enhanced Menu Functions
    
    private func exportAsPDF() {
        let pdfData = generateContactPDF()
        if let data = pdfData {
            // Save PDF to documents directory and share
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let pdfURL = documentsPath.appendingPathComponent("\(contact.displayName)_Contact.pdf")
            
            do {
                try data.write(to: pdfURL)
                let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(activityVC, animated: true)
                }
            } catch {
                successMessage = "Failed to export PDF: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
    
    private func exportToIOSContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let contact = CNMutableContact()
                    contact.givenName = self.contact.firstName
                    contact.familyName = self.contact.lastName
                    contact.note = self.contact.notes
                    
                    // Add social media if available
                    if !self.contact.socialMediaURLs.isEmpty {
                        let validURLs = self.contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        if !validURLs.isEmpty {
                            contact.urlAddresses = validURLs.map { CNLabeledValue(label: CNLabelURLAddressHomePage, value: $0 as NSString) }
                        }
                    }
                    
                    // Add birthday if available
                    if let birthday = self.contact.birthday {
                        let dateComponents = DateComponents(year: birthday.year, month: birthday.month, day: birthday.day)
                        contact.birthday = dateComponents
                    }
                    
                    let request = CNSaveRequest()
                    request.add(contact, toContainerWithIdentifier: nil)
                    
                    do {
                        try store.execute(request)
                        self.successMessage = "Contact exported to iOS Contacts successfully!"
                        self.showingSuccessAlert = true
                    } catch {
                        self.successMessage = "Failed to export: \(error.localizedDescription)"
                        self.showingSuccessAlert = true
                    }
                } else {
                    self.successMessage = "Permission denied. Please enable Contacts access in Settings."
                    self.showingSuccessAlert = true
                }
            }
        }
    }
    
    private func shareContact() {
                    let contactInfo = """
            \(contact.displayName)
            
            Notes: \(contact.notes)
            \(!contact.socialMediaURLs.isEmpty ? "Social Media: \(contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.joined(separator: ", "))" : "")
            """
        
        let activityVC = UIActivityViewController(activityItems: [contactInfo], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func copyContactInfo() {
                    let contactInfo = """
            \(contact.displayName)
            Notes: \(contact.notes)
            \(!contact.socialMediaURLs.isEmpty ? "Social Media: \(contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.joined(separator: ", "))" : "")
            """
        
        UIPasteboard.general.string = contactInfo
        successMessage = "Contact info copied to clipboard!"
        showingSuccessAlert = true
    }
    
    private func setBirthdayReminder(birthday: Birthday) {
        let eventStore = EKEventStore()
        
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        let event = EKEvent(eventStore: eventStore)
                        event.title = "\(self.contact.displayName)'s Birthday"
                        event.notes = "Birthday reminder for \(self.contact.displayName)"
                        
                        // Set for next occurrence of this birthday
                        let calendar = Calendar.current
                        let now = Date()
                        var nextBirthday = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: birthday.month, day: birthday.day)) ?? Date()
                        
                        // If birthday has passed this year, set for next year
                        if nextBirthday < now {
                            nextBirthday = calendar.date(from: DateComponents(year: calendar.component(.year, from: now) + 1, month: birthday.month, day: birthday.day)) ?? Date()
                        }
                        
                        event.startDate = nextBirthday
                        event.endDate = calendar.date(byAdding: .hour, value: 1, to: nextBirthday) ?? nextBirthday
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        
                        do {
                            try eventStore.save(event, span: .thisEvent)
                            self.successMessage = "Birthday reminder set for \(birthday.displayString)!"
                            self.showingSuccessAlert = true
                        } catch {
                            self.successMessage = "Failed to set reminder: \(error.localizedDescription)"
                            self.showingSuccessAlert = true
                        }
                    } else {
                        self.successMessage = "Permission denied. Please enable Calendar access in Settings."
                        self.showingSuccessAlert = true
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        let event = EKEvent(eventStore: eventStore)
                        event.title = "\(self.contact.displayName)'s Birthday"
                        event.notes = "Birthday reminder for \(self.contact.displayName)"
                        
                        // Set for next occurrence of this birthday
                        let calendar = Calendar.current
                        let now = Date()
                        var nextBirthday = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: birthday.month, day: birthday.day)) ?? Date()
                        
                        // If birthday has passed this year, set for next year
                        if nextBirthday < now {
                            nextBirthday = calendar.date(from: DateComponents(year: calendar.component(.year, from: now) + 1, month: birthday.month, day: birthday.day)) ?? Date()
                        }
                        
                        event.startDate = nextBirthday
                        event.endDate = calendar.date(byAdding: .hour, value: 1, to: nextBirthday) ?? nextBirthday
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        
                        do {
                            try eventStore.save(event, span: .thisEvent)
                            self.successMessage = "Birthday reminder set for \(birthday.displayString)!"
                            self.showingSuccessAlert = true
                        } catch {
                            self.successMessage = "Failed to set reminder: \(error.localizedDescription)"
                            self.showingSuccessAlert = true
                        }
                    } else {
                        self.successMessage = "Permission denied. Please enable Calendar access in Settings."
                        self.showingSuccessAlert = true
                    }
                }
            }
        }
    }
    
    private func generateContactPDF() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Forgetze",
            kCGPDFContextAuthor: "Forgetze App",
            kCGPDFContextTitle: "\(contact.displayName) - Contact Card"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            let titleString = "\(contact.displayName) - Contact Card"
            titleString.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            // Contact Details
            let detailAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            var yPosition: CGFloat = 120
            
            if !contact.notes.isEmpty {
                "Notes: \(contact.notes)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: detailAttributes)
                yPosition += 30
            }
            

            
            if !contact.socialMediaURLs.isEmpty {
                let validURLs = contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                if !validURLs.isEmpty {
                    "Social Media:".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: detailAttributes)
                    yPosition += 25
                    for url in validURLs {
                        "  • \(url)".draw(at: CGPoint(x: 70, y: yPosition), withAttributes: detailAttributes)
                        yPosition += 20
                    }
                    yPosition += 10
                }
            }
            
            if let birthday = contact.birthday {
                "Birthday: \(birthday.displayString)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: detailAttributes)
                yPosition += 30
                
                if let age = birthday.age {
                    "Age: \(age) years old".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: detailAttributes)
                    yPosition += 30
                }
            }
            
            if contact.hasKids {
                "Children: \(contact.kidsCount)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: detailAttributes)
                yPosition += 30
                
                for kid in contact.kids {
                    "  • \(kid.displayName)".draw(at: CGPoint(x: 70, y: yPosition), withAttributes: detailAttributes)
                    yPosition += 25
                    
                    if let kidBirthday = kid.birthday {
                        "    Birthday: \(kidBirthday.shortDisplayString)".draw(at: CGPoint(x: 70, y: yPosition), withAttributes: detailAttributes)
                        yPosition += 25
                    }
                }
            }
            
            // Footer
            let footerAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.gray
            ]
            let footerString = "Generated by Forgetze on \(Date().formatted(date: .abbreviated, time: .shortened))"
            footerString.draw(at: CGPoint(x: 50, y: pageRect.height - 50), withAttributes: footerAttributes)
        }
        
        return data
    }
}

#Preview {
    NavigationView {
        ContactDetailView(contact: Contact(
            firstName: "John",
            lastName: "Doe",
            notes: "Sample contact for preview",
    
            socialMediaURLs: ["https://linkedin.com/in/johndoe", "https://twitter.com/johndoe"],
            birthday: Birthday(date: Date().addingTimeInterval(-30*365*24*60*60)),
            kids: [
                Kid(firstName: "Jane", lastName: "Doe", birthday: Birthday(date: Date().addingTimeInterval(-5*365*24*60*60))),
                Kid(firstName: "Bob", lastName: "Doe")
            ]
        ))
    }
    .modelContainer(for: Contact.self, inMemory: true)
}
