import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    let contact: Contact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(contact.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if !contact.notes.isEmpty {
                        Text(contact.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if !contact.group.isEmpty {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.blue)
                            Text(contact.group)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Birthday Section
                if let birthday = contact.birthday {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "gift")
                                .foregroundColor(.orange)
                            Text("Birthday")
                                .font(.headline)
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
                                .foregroundColor(.blue)
                            Text("Children (\(contact.kidsCount))")
                                .font(.headline)
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
                

            }
            .padding(.vertical)
        }
        .navigationTitle("Contact Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    
                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
}



#Preview {
    NavigationView {
        ContactDetailView(contact: Contact(
            firstName: "John",
            lastName: "Doe",
            notes: "Sample contact for preview",
            group: "Family",
            birthday: Birthday(date: Date().addingTimeInterval(-30*365*24*60*60)),
            kids: [
                Kid(firstName: "Jane", lastName: "Doe", birthday: Birthday(date: Date().addingTimeInterval(-5*365*24*60*60))),
                Kid(firstName: "Bob", lastName: "Doe")
            ]
        ))
    }
    .modelContainer(for: Contact.self, inMemory: true)
}
