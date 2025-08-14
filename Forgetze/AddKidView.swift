import SwiftUI

struct AddKidView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthday = Date()
    @State private var hasBirthday = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let onSave: (Kid) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Child Information") {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Birthday") {
                    Toggle("Has Birthday", isOn: $hasBirthday)
                    
                    if hasBirthday {
                        DatePicker(
                            "Birthday",
                            selection: $birthday,
                            displayedComponents: .date
                        )
                    }
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newKid = Kid(
                            firstName: firstName.trimmingCharacters(in: .whitespaces),
                            lastName: lastName.trimmingCharacters(in: .whitespaces),
                            birthday: hasBirthday ? Birthday(date: birthday) : nil
                        )
                        
                        if newKid.isValid {
                            onSave(newKid)
                            dismiss()
                        } else {
                            errorMessage = newKid.validationErrors.joined(separator: ", ")
                            showingError = true
                        }
                    }
                    .disabled(firstName.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    AddKidView { _ in }
}
