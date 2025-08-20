import SwiftUI

struct EditKidView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var birthday: Date
    @State private var hasBirthday: Bool
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let kid: Kid
    let onSave: (Kid) -> Void
    
    init(kid: Kid, onSave: @escaping (Kid) -> Void) {
        self.kid = kid
        self.onSave = onSave
        
        // Initialize state with current kid data
        _firstName = State(initialValue: kid.firstName)
        _lastName = State(initialValue: kid.lastName)
        
        if let kidBirthday = kid.birthday {
            _hasBirthday = State(initialValue: true)
            // Create a Date from the birthday components
            var components = DateComponents()
            components.month = kidBirthday.month
            components.day = kidBirthday.day
            components.year = kidBirthday.year ?? 2000
            _birthday = State(initialValue: Calendar.current.date(from: components) ?? Date())
        } else {
            _hasBirthday = State(initialValue: false)
            _birthday = State(initialValue: Date())
        }
    }
    
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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Month:")
                                Picker("Month", selection: Binding<Int>(
                                    get: { Calendar.current.component(.month, from: birthday) },
                                    set: { newMonth in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: birthday)
                                        components.month = newMonth
                                        birthday = calendar.date(from: components) ?? birthday
                                    }
                                )) {
                                    ForEach(1...12, id: \.self) { month in
                                        Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            HStack {
                                Text("Day:")
                                Picker("Day", selection: Binding<Int>(
                                    get: { Calendar.current.component(.day, from: birthday) },
                                    set: { newDay in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: birthday)
                                        components.day = newDay
                                        birthday = calendar.date(from: components) ?? birthday
                                    }
                                )) {
                                    ForEach(1...31, id: \.self) { day in
                                        Text("\(day)").tag(day)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            HStack {
                                Text("Year:")
                                Toggle("Include Year", isOn: Binding<Bool>(
                                    get: { Calendar.current.component(.year, from: birthday) != 2000 },
                                    set: { includeYear in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: birthday)
                                        if includeYear {
                                            components.year = Calendar.current.component(.year, from: Date())
                                        } else {
                                            components.year = 2000
                                        }
                                        birthday = calendar.date(from: components) ?? birthday
                                    }
                                ))
                                
                                if Calendar.current.component(.year, from: birthday) != 2000 {
                                    Picker("Year", selection: Binding<Int>(
                                        get: { Calendar.current.component(.year, from: birthday) },
                                        set: { newYear in
                                            let calendar = Calendar.current
                                            var components = calendar.dateComponents([.year, .month, .day], from: birthday)
                                            components.year = newYear
                                            birthday = calendar.date(from: components) ?? birthday
                                        }
                                    )) {
                                        ForEach(1900...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                                            Text("\(year)").tag(year)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedKid = Kid(
                            firstName: firstName.trimmingCharacters(in: .whitespaces),
                            lastName: lastName.trimmingCharacters(in: .whitespaces),
                            birthday: hasBirthday ? Birthday(
                                month: Calendar.current.component(.month, from: birthday),
                                day: Calendar.current.component(.day, from: birthday),
                                year: Calendar.current.component(.year, from: birthday) != 2000 ? Calendar.current.component(.year, from: birthday) : nil
                            ) : nil
                        )
                        
                        if updatedKid.isValid {
                            // Preserve the original ID
                            updatedKid.id = kid.id
                            onSave(updatedKid)
                            dismiss()
                        } else {
                            errorMessage = updatedKid.validationErrors.joined(separator: ", ")
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
    let sampleKid = Kid(firstName: "John", lastName: "Doe", birthday: Birthday(month: 6, day: 15, year: 2010))
    EditKidView(kid: sampleKid) { _ in }
        .modelContainer(for: Contact.self, inMemory: true)
}
