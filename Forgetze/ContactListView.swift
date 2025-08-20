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
                // Load demo data if needed
                loadDemoDataIfNeeded()
                
                // Memory cleanup when view appears
                appSettings.cleanupMemory()
                searchManager.cleanupMemory()
                
                // Aggressive memory cleanup if needed
                if appSettings.getMemoryUsage().contains("MB") {
                    let usage = appSettings.getMemoryUsage()
                    if let mbValue = Float(usage.replacingOccurrences(of: " MB", with: "")) {
                        if mbValue > 80.0 {
                            print("⚠️ High memory detected, running aggressive cleanup")
                            appSettings.aggressiveMemoryCleanup()
                        }
                    }
                }
                
                // Set loading to false after a brief delay to prevent memory issues
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                }
            }
            .onChange(of: searchManager.searchText) { _, newValue in
                searchManager.performSearch(in: contacts)
            }
            .onDisappear {
                // Cleanup when view disappears
                searchManager.reset()
                voiceSearchManager.reset()
                
                // Final memory cleanup
                appSettings.cleanupMemory()
            }
        }
    }
    
    // MARK: - Contact Management Functions
    
    private func deleteContacts(offsets: IndexSet) {
        withAnimation {
            // Get the filtered contacts for deletion
            let contactsToDelete = offsets.map { index in
                // Since we're using the main contacts array, we need to find the actual contact
                // This is a simplified approach - in a real app you might want to use a view model
                contacts[index]
            }
            
            for contact in contactsToDelete {
                modelContext.delete(contact)
            }
            
            do {
                try modelContext.save()
            } catch {
                errorMessage = "Failed to delete contacts: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func loadDemoDataIfNeeded() {
        Task { @MainActor in
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
}

// MARK: - Contact Row Views

struct ContactRowView: View {
    let contact: Contact
    let themeColor: Color
    
    // Computed property to generate initials
    private var initials: String {
        let firstInitial = contact.firstName.first?.uppercased() ?? ""
        let lastInitial = contact.lastName.first?.uppercased() ?? ""
        
        if firstInitial.isEmpty && lastInitial.isEmpty {
            return "?"
        } else if firstInitial.isEmpty {
            return lastInitial
        } else if lastInitial.isEmpty {
            return firstInitial
        } else {
            return "\(firstInitial)\(lastInitial)"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Contact initials circle
            ZStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 40, height: 40)
                
                Text(initials)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Contact name only
            Text(contact.displayName)
                .font(.headline)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Enhanced Contact Row for Search Results

struct EnhancedContactRowView: View {
    let contact: Contact
    let searchText: String
    let themeColor: Color
    
    // Computed property to generate initials
    private var initials: String {
        let firstInitial = contact.firstName.first?.uppercased() ?? ""
        let lastInitial = contact.lastName.first?.uppercased() ?? ""
        
        if firstInitial.isEmpty && lastInitial.isEmpty {
            return "?"
        } else if firstInitial.isEmpty {
            return lastInitial
        } else if lastInitial.isEmpty {
            return firstInitial
        } else {
            return "\(firstInitial)\(lastInitial)"
        }
    }
    
    // Highlight matching text in notes - Simplified to reduce memory usage
    private func highlightedNotes() -> Text {
        if searchText.isEmpty || contact.notes.isEmpty {
            return Text(contact.notes)
        }
        
        // Simple highlighting without complex string operations
        return Text(contact.notes)
            .foregroundColor(.secondary)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Contact initials circle
            ZStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 40, height: 40)
                
                Text(initials)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Enhanced contact information for search results
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(contact.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let age = contact.age {
                        Text("(\(age))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Show matching notes with highlighting
                if !contact.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notes:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        highlightedNotes()
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                
                // Show kids information if relevant to search
                if contact.hasKids {
                    HStack {
                        Image(systemName: "person.3")
                            .font(.caption)
                            .foregroundColor(themeColor)
                        Text("\(contact.kidsCount) child\(contact.kidsCount == 1 ? "" : "ren")")
                            .font(.caption)
                            .foregroundColor(themeColor)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContactListView()
        .environmentObject(AppSettings())
}
