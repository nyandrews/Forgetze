import SwiftUI
import SwiftData

struct ContactListContent: View {
    let contacts: [Contact]
    @ObservedObject var searchManager: SearchManager
    let onDelete: (IndexSet) -> Void
    
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
                                    EnhancedContactRowView(contact: contact, searchText: searchManager.searchText)
                                } else {
                                    ContactRowView(contact: contact)
                                }
                            }
                        }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    ContactListContent(
        contacts: [],
        searchManager: SearchManager(),
        onDelete: { _ in }
    )
}
