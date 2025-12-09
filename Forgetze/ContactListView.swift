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
    @StateObject private var searchManager = SearchManager()
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
                .background(Color(.systemGroupedBackground)) // Match list background for seamless look
                
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
            .navigationTitle("Contacts")
            .background(Color(.systemGroupedBackground)) // Ensure background consistency
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
                // Pre-emptive memory cleanup BEFORE loading demo data
                print("🧹 Pre-startup memory cleanup...")
                appSettings.aggressiveMemoryCleanup()
                
                // Longer delay to allow system memory to stabilize
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    loadDemoDataIfNeeded()
                }
                
                // Additional memory cleanup
                searchManager.cleanupMemory()
                
                // Set loading to false after demo data has time to load
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isLoading = false
                    
                    // Final cleanup after loading
                    appSettings.cleanupMemory()
                    print("✅ Startup sequence completed")
                }
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
            ForEach(filteredContacts) { contact in
                NavigationLink(destination: ContactDetailView(contact: contact)) {
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
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(width: 12)
            
            Text(contact.displayName(order: displayOrder))
                .font(.headline)
                .foregroundColor(.primary)
            
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
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(width: 12)
            
            highlightedText(contact.displayName(order: displayOrder), searchText: searchText)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func highlightedText(_ text: String, searchText: String) -> some View {
        if searchText.isEmpty {
            Text(text)
        } else {
            let parts = text.components(separatedBy: searchText)
            if parts.count > 1 {
                HStack(spacing: 0) {
                    ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                        Group {
                            Text(part)
                            if index < parts.count - 1 {
                                Text(searchText)
                                    .background(themeColor.opacity(0.3))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            } else {
                Text(text)
            }
        }
    }
}

#Preview {
    ContactListView()
        .environmentObject(AppSettings())
        .modelContainer(for: Contact.self, inMemory: true)
}
