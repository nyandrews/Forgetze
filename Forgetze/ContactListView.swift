import SwiftUI
import SwiftData
import Foundation

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appSettings: AppSettings
    @Query private var contacts: [Contact]
    
    @State private var showingAddContact = false
    @State private var showingHamburgerMenu = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = true
    
    // MARK: - State Objects
    @EnvironmentObject var searchManager: SearchManager
    @StateObject private var voiceSearchManager = VoiceSearchManager()
    
    // MARK: - Computed Properties
    
    private var hasContacts: Bool {
        !contacts.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar with voice search
                SearchBarView(
                    searchManager: searchManager,
                    voiceSearchManager: voiceSearchManager,
                    contacts: contacts
                )
                .background(Color(.systemGroupedBackground))
                
                .background(Color(.systemGroupedBackground))
                
                // Content based on state
                if isLoading {
                    LoadingView()
                } else if !hasContacts {
                    EmptyStateView {
                        showingAddContact = true
                    }
                } else {
                    ContactListContent(
                        contacts: contacts,
                        searchManager: searchManager,
                        onDelete: deleteContacts,
                        themeColor: appSettings.primaryColor.color,
                        sortOption: appSettings.sortOption,
                        displayOrder: appSettings.displayOrder
                    )
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingHamburgerMenu = true
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(appSettings.primaryColor.color)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .accessibilityIdentifier("hamburgerMenuButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Contact") {
                        showingAddContact = true
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddContact) {
                ContactEditView()
            }
            .sheet(isPresented: $showingHamburgerMenu) {
                HamburgerMenuView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Speech Recognition Permission", isPresented: $voiceSearchManager.showingPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Voice search requires permission to access your microphone and speech recognition. Please enable these in Settings.")
            }
            .alert("Voice Search Error", isPresented: $voiceSearchManager.showingError) {
                Button("OK") { }
            } message: {
                Text(voiceSearchManager.errorMessage)
            }
            .onAppear {
                // Load data immediately
                loadDemoDataIfNeeded()
                
                // Reveal UI immediately
                isLoading = false
                print("✅ Ready")
            }

            .navigationDestination(for: Contact.self) { contact in
                ContactDetailView(contact: contact)
            }
        }
    }
    
    // MARK: - Demo Data Loading
    
    private func loadDemoDataIfNeeded() {
        Task {
            do {
                try await DemoDataService.shared.loadDemoDataIfNeeded(
                    context: modelContext,
                    existingContacts: contacts
                )
            } catch {
                print("Failed to load demo data: \(error)")
            }
        }
    }
    
    // MARK: - Contact Deletion
    
    private func deleteContacts(offsets: IndexSet) {
        withAnimation {
            // Get the filtered contacts for deletion
            let contactsToDelete = offsets.map { index in
                contacts[index]
            }
            
            // Use safe delete with data protection
            Task { @MainActor in
                for contact in contactsToDelete {
                    do {
                        try await DataProtectionManager.shared.safeDelete(contact, in: modelContext)
                        // Deletion successful
                    } catch {
                        errorMessage = "Failed to delete contact '\(contact.displayName)': \(error.localizedDescription)"
                        showingError = true
                    }
                }
            }
        }
    }
}

// MARK: - ContactListContent

struct ContactListContent: View {
    let contacts: [Contact]
    @ObservedObject var searchManager: SearchManager
    let onDelete: (IndexSet) -> Void
    let themeColor: Color
    let sortOption: ContactSortOrder
    let displayOrder: ContactDisplayOrder
    
    var filteredContacts: [Contact] {
        let results: [Contact]
        if searchManager.hasActiveSearch() {
            results = searchManager.getResults()
        } else {
            results = contacts
        }
        
        // Sort based on user preference
        return results.sorted { contact1, contact2 in
            let option = sortOption // Use passed sortOption
            let name1: String
            let name2: String
            
            switch option {
            case .firstName:
                name1 = contact1.firstName.isEmpty ? contact1.lastName : contact1.firstName
                name2 = contact2.firstName.isEmpty ? contact2.lastName : contact2.firstName
            case .lastName:
                name1 = contact1.lastName.isEmpty ? contact1.firstName : contact1.lastName
                name2 = contact2.lastName.isEmpty ? contact2.firstName : contact2.lastName
            }
            
            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
        }
    }
    
    var body: some View {
        List {
            Section(header: HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.headline)
                Text("Contacts")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(themeColor)
            .textCase(nil)
            .padding(.leading, -16)
            .padding(.top, -10)
            .padding(.bottom, 6)
            ) {
                ForEach(filteredContacts) { contact in
                    NavigationLink(value: contact) {
                        if searchManager.hasActiveSearch() {
                            EnhancedContactRowView(
                                contact: contact, 
                                searchText: searchManager.searchText, 
                                themeColor: themeColor, 
                                sortOption: sortOption,
                                displayOrder: displayOrder
                            )
                        } else {
                            ContactRowView(
                                contact: contact, 
                                themeColor: themeColor, 
                                sortOption: sortOption,
                                displayOrder: displayOrder
                            )
                        }
                    }
                }
                .onDelete(perform: onDelete)
            }
        }
        .listStyle(.insetGrouped)
    }
}

    // MARK: - ContactRowView

struct ContactRowView: View {
    let contact: Contact
    let themeColor: Color
    let sortOption: ContactSortOrder
    let displayOrder: ContactDisplayOrder
    
    var body: some View {
        HStack {
            // Circle with initials
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor, themeColor.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: themeColor.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(contact.initials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(width: 12)
            
            Text(contact.displayName(order: displayOrder))
                .font(.headline)
                .foregroundColor(.primary)
            
            if contact.isSample {
                Text("Sample")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EnhancedContactRowView

struct EnhancedContactRowView: View {
    let contact: Contact
    let searchText: String
    let themeColor: Color
    let sortOption: ContactSortOrder
    let displayOrder: ContactDisplayOrder
    
    var body: some View {
        HStack {
            // Circle with initials
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [themeColor, themeColor.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: themeColor.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(contact.initials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(width: 12)
            
            highlightedText(contact.displayName(order: displayOrder), searchText: searchText)
                .font(.headline)
                .foregroundColor(.primary)
            
            if contact.isSample {
                Text("Sample")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    

    
    // Safer, pre-calculated approach
    private struct TextChunk: Identifiable {
        let id = UUID()
        let text: String
        let isHighlight: Bool
    }
    
    private func getChunks(text: String, searchText: String) -> [TextChunk] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return [TextChunk(text: text, isHighlight: false)]
        }
        
        let tokens = searchText.lowercased().components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if tokens.isEmpty { return [TextChunk(text: text, isHighlight: false)] }
        
        let pattern = tokens.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
             return [TextChunk(text: text, isHighlight: false)]
        }
        
        let nsString = text as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var chunks: [TextChunk] = []
        var currentIndex = 0
        
        for match in matches {
            // Safety check for ranges
            if match.range.location == NSNotFound || match.range.location + match.range.length > nsString.length {
                continue
            }
            
            // Text before match
            if match.range.location > currentIndex {
                let length = match.range.location - currentIndex
                if length > 0 {
                    let substring = nsString.substring(with: NSRange(location: currentIndex, length: length))
                    chunks.append(TextChunk(text: substring, isHighlight: false))
                }
            }
            
            // Matched text
            let matchSubstring = nsString.substring(with: match.range)
            chunks.append(TextChunk(text: matchSubstring, isHighlight: true))
            
            currentIndex = match.range.location + match.range.length
        }
        
        // Remaining text
        if currentIndex < nsString.length {
            let substring = nsString.substring(with: NSRange(location: currentIndex, length: nsString.length - currentIndex))
            chunks.append(TextChunk(text: substring, isHighlight: false))
        }
        
        return chunks
    }

    @ViewBuilder
    private func highlightedText(_ text: String, searchText: String) -> some View {
         let chunks = getChunks(text: text, searchText: searchText)
         HStack(spacing: 0) {
             ForEach(chunks) { chunk in
                 Text(chunk.text)
                     .background(chunk.isHighlight ? themeColor.opacity(0.3) : Color.clear)
                     .foregroundColor(.primary)
             }
         }
    }
}

#Preview {
    ContactListView()
        .environmentObject(AppSettings())
        .modelContainer(for: Contact.self, inMemory: true)
}
