import SwiftUI

struct AddSpouseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    
    // Partial birthday state
    @State private var birthMonth: Int = 0 // 0 = Unknown
    @State private var birthDay: Int = 0   // 0 = Unknown
    @State private var birthYear: Int = 0  // 0 = Unknown
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let onSave: (Spouse) -> Void
    
    // Optional: Pre-fill data if editing
    init(spouse: Spouse? = nil, onSave: @escaping (Spouse) -> Void) {
        self.onSave = onSave
        if let spouse = spouse {
            _firstName = State(initialValue: spouse.firstName)
            _lastName = State(initialValue: spouse.lastName)
            if let bday = spouse.birthday {
                _birthMonth = State(initialValue: bday.month)
                _birthDay = State(initialValue: bday.day)
                _birthYear = State(initialValue: bday.year ?? 0)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Spouse Information") {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Birthday") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Month:")
                            Picker("Month", selection: $birthMonth) {
                                Text("Unknown").tag(0)
                                ForEach(1...12, id: \.self) { month in
                                    Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("Day:")
                            Picker("Day", selection: $birthDay) {
                                Text("Unknown").tag(0)
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("Year:")
                            Picker("Year", selection: $birthYear) {
                                Text("Unknown").tag(0)
                                ForEach(1900...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                                    Text("\(year)").tag(year)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
            }
            .navigationTitle("Spouse Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Only create birthday if something is set
                        var newBirthday: Birthday? = nil
                        if birthMonth > 0 || birthDay > 0 || birthYear > 0 {
                             newBirthday = Birthday(
                                month: birthMonth,
                                day: birthDay,
                                year: birthYear > 0 ? birthYear : nil
                            )
                        }
                        
                        let newSpouse = Spouse(
                            firstName: firstName.trimmingCharacters(in: .whitespaces),
                            lastName: lastName.trimmingCharacters(in: .whitespaces),
                            birthday: newBirthday
                        )
                        
                        if newSpouse.isValid {
                            onSave(newSpouse)
                            dismiss()
                        } else {
                            errorMessage = newSpouse.validationErrors.joined(separator: ", ")
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
    AddSpouseView { _ in }
}
