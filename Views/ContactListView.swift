import SwiftUI
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var searchText = ""
    @State private var showingAddContact = false
    @State private var showingHamburgerMenu = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.firstName.localizedCaseInsensitiveContains(searchText) ||
                contact.lastName.localizedCaseInsensitiveContains(searchText) ||
                contact.notes.localizedCaseInsensitiveContains(searchText) ||
                contact.group.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredContacts) { contact in
                    NavigationLink(destination: ContactDetailView(contact: contact)) {
                        ContactRowView(contact: contact)
                    }
                }
                .onDelete(perform: deleteContacts)
            }
            .searchable(text: $searchText, prompt: "Search contacts...")
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingHamburgerMenu = true
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                    .accessibilityIdentifier("hamburgerMenuButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Contact") {
                        showingAddContact = true
                    }
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
        }
    }
    
    private func deleteContacts(offsets: IndexSet) {
        let contactsToDelete = offsets.map { filteredContacts[$0] }
        for contact in contactsToDelete {
            modelContext.delete(contact)
        }
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete contact: \(error.localizedDescription)"
            showingError = true
        }
    }
}

struct ContactRowView: View {
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
            
            if !contact.notes.isEmpty {
                Text(contact.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if contact.hasKids {
                HStack {
                    Image(systemName: "person.3")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("\(contact.kidsCount) child\(contact.kidsCount == 1 ? "" : "ren")")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ContactListView()
        .environmentObject(AppSettings())
        .modelContainer(for: Contact.self, inMemory: true)
}
