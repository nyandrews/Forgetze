import SwiftUI
import SwiftData

struct ContactEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var notes = ""
    @State private var group = ""
    @State private var birthday: Birthday?
    @State private var hasBirthday = false
    @State private var kids: [Kid] = []
    
    @State private var showingAddKidSheet = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let contact: Contact?
    
    init(contact: Contact? = nil) {
        self.contact = contact
        if let contact = contact {
            _firstName = State(initialValue: contact.firstName)
            _lastName = State(initialValue: contact.lastName)
            _notes = State(initialValue: contact.notes)
            _group = State(initialValue: contact.group)
            _birthday = State(initialValue: contact.birthday)
            _hasBirthday = State(initialValue: contact.birthday != nil)
            _kids = State(initialValue: contact.kids)
        }
    }
    
    var isNewContact: Bool {
        contact == nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                    
                    TextField("Group", text: $group)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Birthday") {
                    Toggle("Has Birthday", isOn: $hasBirthday)
                    
                    if hasBirthday {
                        DatePicker(
                            "Birthday",
                            selection: Binding(
                                get: { birthday?.date ?? Date() },
                                set: { birthday = Birthday(date: $0) }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
                
                Section("Children") {
                    ForEach(kids) { kid in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(kid.displayName)
                                .font(.headline)
                            
                            if let birthday = kid.birthday {
                                Text("Born \(birthday.shortDisplayString)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let age = birthday.age {
                                    Text("(\(age) years old)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteKids)
                    
                    Button("Add Child") {
                        showingAddKidSheet = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle(isNewContact ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddKidSheet) {
                AddKidView { newKid in
                    kids.append(newKid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveContact() {
        let newContact = Contact(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            group: group.trimmingCharacters(in: .whitespaces),
            birthday: hasBirthday ? birthday : nil,
            kids: kids
        )
        
        guard newContact.isValid else {
            errorMessage = newContact.validationErrors.joined(separator: ", ")
            showingError = true
            return
        }
        
        if isNewContact {
            modelContext.insert(newContact)
        } else if let existingContact = contact {
            existingContact.firstName = newContact.firstName
            existingContact.lastName = newContact.lastName
            existingContact.notes = newContact.notes
            existingContact.group = newContact.group
            existingContact.birthday = newContact.birthday
            existingContact.kids = newContact.kids
            existingContact.updatedAt = Date()
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save contact: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteKids(offsets: IndexSet) {
        kids.remove(atOffsets: offsets)
    }
}

#Preview {
    ContactEditView()
        .modelContainer(for: Contact.self, inMemory: true)
}
