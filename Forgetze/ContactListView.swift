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
        NavigationView {
            VStack(spacing: 0) {
                // Search bar with voice search
                SearchBarView(
                    searchManager: searchManager,
                    voiceSearchManager: voiceSearchManager,
                    contacts: contacts
                )
                
                // Divider line
                Divider()
                
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
                        themeColor: appSettings.primaryColor.color
                    )
                }
            }
            .navigationTitle("Contacts")
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
    
    var filteredContacts: [Contact] {
        if searchManager.hasActiveSearch() {
            return searchManager.getResults()
        } else {
            return contacts
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredContacts) { contact in
                NavigationLink(destination: ContactDetailView(contact: contact)) {
                    if searchManager.hasActiveSearch() {
                        EnhancedContactRowView(contact: contact, searchText: searchManager.searchText, themeColor: themeColor)
                    } else {
                        ContactRowView(contact: contact, themeColor: themeColor)
                    }
                }
                .accentColor(themeColor)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - ContactRowView

struct ContactRowView: View {
    let contact: Contact
    let themeColor: Color
    
    var body: some View {
        HStack {
            Text(contact.displayName)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Circle with initials
            ZStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 32, height: 32)
                
                Text(contact.initials)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EnhancedContactRowView

struct EnhancedContactRowView: View {
    let contact: Contact
    let searchText: String
    let themeColor: Color
    
    var body: some View {
        HStack {
            highlightedText(contact.displayName, searchText: searchText)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Circle with initials
            ZStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 32, height: 32)
                
                Text(contact.initials)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
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
