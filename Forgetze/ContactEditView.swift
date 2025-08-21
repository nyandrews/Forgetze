import SwiftUI
import SwiftData

struct ContactEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appSettings: AppSettings
    let contact: Contact?
    let isNewContact: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var notes = ""

    @State private var socialMediaURLs: [String] = []
    @State private var birthday: Birthday?
    @State private var hasBirthday = false
    @State private var kids: [Kid] = []
    
    @State private var showingAddKidSheet = false
    @State private var showingEditKidSheet = false
    @State private var selectedKid: Kid?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(contact: Contact? = nil) {
        self.contact = contact
        self.isNewContact = contact == nil
        if let contact = contact {
            _firstName = State(initialValue: contact.firstName)
            _lastName = State(initialValue: contact.lastName)
            _notes = State(initialValue: contact.notes)

            _socialMediaURLs = State(initialValue: contact.socialMediaURLs)
            _birthday = State(initialValue: contact.birthday)
            _hasBirthday = State(initialValue: contact.birthday != nil)
            _kids = State(initialValue: contact.kids)
        }
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
                    

                }
                
                Section("Birthday") {
                    Toggle("Has Birthday", isOn: $hasBirthday)
                    
                    if hasBirthday {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Month:")
                                Picker("Month", selection: Binding(
                                    get: { birthday?.month ?? 1 },
                                    set: { 
                                        if birthday == nil {
                                            birthday = Birthday(month: $0, day: 1)
                                        } else {
                                            birthday?.month = $0
                                        }
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
                                Picker("Day", selection: Binding(
                                    get: { birthday?.day ?? 1 },
                                    set: { 
                                        if birthday == nil {
                                            birthday = Birthday(month: 1, day: $0)
                                        } else {
                                            birthday?.day = $0
                                        }
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
                                Toggle("Include Year", isOn: Binding(
                                    get: { birthday?.year != nil },
                                    set: { includeYear in
                                        if includeYear {
                                            if birthday == nil {
                                                birthday = Birthday(month: 1, day: 1, year: Calendar.current.component(.year, from: Date()))
                                            } else if birthday?.year == nil {
                                                birthday?.year = Calendar.current.component(.year, from: Date())
                                            }
                                        } else {
                                            birthday?.year = nil
                                        }
                                    }
                                ))
                                
                                if birthday?.year != nil {
                                    Picker("Year", selection: Binding(
                                        get: { birthday?.year ?? Calendar.current.component(.year, from: Date()) },
                                        set: { birthday?.year = $0 }
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
                
                Section("Children") {
                    ForEach(kids) { kid in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(kid.displayName)
                                    .font(.headline)
                                
                                if let birthday = kid.birthday {
                                    Text("Born \(birthday.shortDisplayString)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if let age = birthday.age {
                                        Text("(\(String(age)) years old)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                editKid(kid)
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(appSettings.primaryColor.color)
                                    .font(.title2)
                            }
                        }
                    }
                    .onDelete(perform: deleteKids)
                    
                    Button("Add Child") {
                        showingAddKidSheet = true
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                }
                
                Section("Social Media") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(socialMediaURLs.indices, id: \.self) { index in
                            HStack {
                                TextField("Social Media URL", text: $socialMediaURLs[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.URL)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                
                                Button(action: {
                                    socialMediaURLs.remove(at: index)
                                }) {
                                                                    Image(systemName: "minus.circle.fill")
                                    .foregroundColor(appSettings.primaryColor.color)
                                }
                            }
                        }
                        
                        Button(action: {
                            socialMediaURLs.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Social Media URL")
                            }
                            .foregroundColor(appSettings.primaryColor.color)
                        }
                    }
                }
            }
            .navigationTitle(isNewContact ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.semibold)
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddKidSheet) {
                AddKidView { newKid in
                    kids.append(newKid)
                }
            }
            .sheet(isPresented: $showingEditKidSheet) {
                if let selectedKid = selectedKid {
                    EditKidSheet(kid: selectedKid) { updatedKid in
                        if let index = kids.firstIndex(where: { $0.id == updatedKid.id }) {
                            kids[index] = updatedKid
                        }
                    }
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
            socialMediaURLs: socialMediaURLs.compactMap { url in
                let trimmed = url.trimmingCharacters(in: .whitespaces)
                return trimmed.isEmpty ? nil : trimmed
            },
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

            existingContact.socialMediaURLs = newContact.socialMediaURLs
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
    
    private func editKid(_ kid: Kid) {
        selectedKid = kid
        showingEditKidSheet = true
    }
    
    private func deleteKids(offsets: IndexSet) {
        kids.remove(atOffsets: offsets)
    }
}

// MARK: - EditKidSheet (Embedded)
struct EditKidSheet: View {
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
    ContactEditView()
        .modelContainer(for: Contact.self, inMemory: true)
}
