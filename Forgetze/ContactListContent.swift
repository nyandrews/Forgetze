import SwiftUI
import SwiftData

/**
 * Contact List Content
 * 
 * Manages the display logic for the list of contacts, including search filtering
 * and deletion functionality. This view separates the list logic from the main
 * view and provides a clean interface for contact management.
 * 
 * ## Features:
 * - Dynamic contact filtering based on search
 * - Smooth animations for list changes
 * - Deletion support with confirmation
 * - Accessibility support
 * - Performance optimized for large lists
 * 
 * ## Usage:
 * ```swift
 * ContactListContent(
 *     contacts: contacts,
 *     searchManager: searchManager,
 *     onDelete: deleteContacts
 * )
 * ```
 */
struct ContactListContent: View {
    let contacts: [Contact]
    @ObservedObject var searchManager: SearchManager
    let onDelete: (IndexSet) -> Void
    let themeColor: Color
    
    // Computed property for filtered contacts
    private var filteredContacts: [Contact] {
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
                    ContactRowView(contact: contact, themeColor: themeColor)
                }
                .accessibilityIdentifier("contactRow_\(contact.id)")
                .accessibilityLabel("Contact: \(contact.displayName)")
                .accessibilityHint("Tap to view contact details")
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
        .animation(.easeInOut(duration: 0.3), value: filteredContacts.count)
        .accessibilityIdentifier("contactList")
        .accessibilityLabel("List of contacts")
        .accessibilityHint("Swipe left on a contact to delete")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    let sampleContact = Contact(firstName: "John", lastName: "Doe", notes: "Sample contact")
    
    return ContactListContent(
        contacts: [sampleContact],
        searchManager: SearchManager(),
        onDelete: { _ in },
        themeColor: .blue // Added themeColor for preview
    )
    .modelContainer(container)
}

