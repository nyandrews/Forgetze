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
                                    get: { Calendar.current.component(.year, from: birthday) != 1 },
                                    set: { includeYear in
                                        let calendar = Calendar.current
                                        var components = calendar.dateComponents([.year, .month, .day], from: birthday)
                                        if includeYear {
                                            components.year = Calendar.current.component(.year, from: Date())
                                        } else {
                                            components.year = 1
                                        }
                                        birthday = calendar.date(from: components) ?? birthday
                                    }
                                ))
                                
                                if Calendar.current.component(.year, from: birthday) != 1 {
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
                            birthday: hasBirthday ? Birthday(
                                month: Calendar.current.component(.month, from: birthday),
                                day: Calendar.current.component(.day, from: birthday),
                                year: Calendar.current.component(.year, from: birthday) != 1 ? Calendar.current.component(.year, from: birthday) : nil
                            ) : nil
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
