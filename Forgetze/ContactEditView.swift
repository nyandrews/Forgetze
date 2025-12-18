import SwiftUI
import SwiftData

struct ContactEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appSettings: AppSettings
    let contact: Contact?
    let isNewContact: Bool
    
    struct EditPhoneNumber: Identifiable {
        let id: UUID
        var number: String
        var label: String
    }

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var notes = ""
    @State private var phoneNumbers: [EditPhoneNumber] = []
    @State private var socialMediaURLs: [String] = []
    @State private var addresses: [Address] = []
    @State private var birthday: Birthday?
    @State private var kids: [Kid] = []
    @State private var spouse: Spouse?
    
    @State private var showingAddKidSheet = false
    @State private var showingEditKidSheet = false
    @State private var showingAddSpouseSheet = false
    @State private var showingAddAddressSheet = false
    @State private var selectedKid: Kid?
    @State private var selectedAddress: Address?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(contact: Contact? = nil) {
        self.contact = contact
        self.isNewContact = contact == nil
        if let contact = contact {
            _firstName = State(initialValue: contact.firstName)
            _lastName = State(initialValue: contact.lastName)
            _notes = State(initialValue: contact.notes)
            
            // Map existing phone numbers to edit structs
            let existingPhones = contact.displayPhoneNumbers.map {
                EditPhoneNumber(id: $0.id, number: $0.number, label: $0.label)
            }
            _phoneNumbers = State(initialValue: existingPhones)
            
            _socialMediaURLs = State(initialValue: contact.socialMediaURLs)
            _addresses = State(initialValue: contact.addresses)
            _birthday = State(initialValue: contact.birthday)
            _kids = State(initialValue: contact.kids)
            _spouse = State(initialValue: contact.spouse)
        }
        
        // Ensure at least one empty entry for frictionless input if new
        if _phoneNumbers.wrappedValue.isEmpty {
            _phoneNumbers = State(initialValue: [EditPhoneNumber(id: UUID(), number: "", label: "Mobile")])
        }
        if _socialMediaURLs.wrappedValue.isEmpty {
            _socialMediaURLs = State(initialValue: [""])
        }
        if _addresses.wrappedValue.isEmpty {
            _addresses = State(initialValue: [Address(type: "Home", street: "", city: "", state: "", zip: "", country: "USA")])
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                } header: {
                    Text("Basic Info")
                }
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }

                phoneNumbersSection()
                relationshipsSection()
                addressesSection()
                socialMediaSection()
            }
            .navigationTitle(isNewContact ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(appSettings.primaryColor.color)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveContact() }
                        .foregroundColor(appSettings.primaryColor.color)
                        .fontWeight(.semibold)
                        .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddKidSheet) {
                AddKidView { kids.append($0) }
            }
            .sheet(isPresented: $showingAddSpouseSheet) {
                AddSpouseView(spouse: spouse) { updated in
                    if let existing = spouse { updated.id = existing.id }
                    spouse = updated
                }
            }
            .sheet(isPresented: $showingAddAddressSheet) {
                AddressEditView(address: selectedAddress) { updated in
                    if let selected = selectedAddress, let idx = addresses.firstIndex(where: { $0.id == selected.id }) {
                        addresses[idx] = updated
                    } else {
                        addresses.append(updated)
                    }
                    selectedAddress = nil
                }
            }
            .sheet(isPresented: $showingEditKidSheet) {
                if let kid = selectedKid {
                    EditKidSheet(kid: kid) { updated in
                        if let idx = kids.firstIndex(where: { $0.id == updated.id }) {
                            kids[idx] = updated
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
    
    // MARK: - Helper Methods
    
    private func ensureEmptyPhoneRow() {
        if phoneNumbers.isEmpty || !phoneNumbers.last!.number.isEmpty {
            phoneNumbers.append(EditPhoneNumber(id: UUID(), number: "", label: "Mobile"))
        }
    }
    
    private func ensureEmptySocialRow() {
        if socialMediaURLs.isEmpty || !socialMediaURLs.last!.isEmpty {
            socialMediaURLs.append("")
        }
    }
    
    private func editAddress(_ address: Address) {
        selectedAddress = address
        showingAddAddressSheet = true
    }
    
    private func saveContact() {
        // Clean up empty rows before saving
        let finalPhones = phoneNumbers.compactMap { $0.number.isEmpty ? nil : PhoneNumber(number: $0.number, label: $0.label) }
        let finalSocials = socialMediaURLs.filter { !$0.isEmpty }
        let finalAddresses = addresses.filter { !$0.street.isEmpty || !$0.city.isEmpty }
        
        let newContact = Contact(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            phoneNumbers: finalPhones,
            socialMediaURLs: finalSocials,
            birthday: birthday,
            kids: kids,
            spouse: spouse,
            addresses: finalAddresses
        )
        
        guard newContact.isValid else {
            errorMessage = newContact.validationErrors.joined(separator: ", ")
            showingError = true
            return
        }
        
        Task {
            do {
                if isNewContact {
                    modelContext.insert(newContact)
                    try await DataProtectionManager.shared.safeSave(newContact, in: modelContext)
                } else if let existing = contact {
                    existing.firstName = newContact.firstName
                    existing.lastName = newContact.lastName
                    existing.notes = newContact.notes
                    existing.phoneNumbers = finalPhones
                    existing.socialMediaURLs = finalSocials
                    existing.birthday = newContact.birthday
                    existing.kids = newContact.kids
                    existing.spouse = newContact.spouse
                    existing.addresses = addresses
                    existing.updatedAt = Date()
                    try await DataProtectionManager.shared.safeSave(existing, in: modelContext)
                }
                dismiss()
            } catch {
                errorMessage = "Failed to save: \(error.localizedDescription)"
                showingError = true
            }
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

// MARK: - Subviews Extension
extension ContactEditView {
    
    @ViewBuilder
    func phoneNumbersSection() -> some View {
        Section {
            ForEach($phoneNumbers) { $phone in
                HStack {
                    TextField("Phone Number", text: Binding(
                        get: { phone.number },
                        set: { newValue in
                            phone.number = FieldFormatters.formatPhoneNumber(newValue)
                            ensureEmptyPhoneRow()
                        }
                    ))
                    .keyboardType(.phonePad)
                    
                    Picker("", selection: $phone.label) {
                        Text("Mobile").tag("Mobile")
                        Text("Home").tag("Home")
                        Text("Work").tag("Work")
                        Text("iPhone").tag("iPhone")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    
                    if phoneNumbers.count > 1 || !phone.number.isEmpty {
                        Button(action: {
                            if let index = phoneNumbers.firstIndex(where: { $0.id == phone.id }) {
                                phoneNumbers.remove(at: index)
                                ensureEmptyPhoneRow()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        } header: {
            Text("Phone Numbers")
        }
    }
    
    @ViewBuilder
    func socialMediaSection() -> some View {
        Section {
            ForEach(socialMediaURLs.indices, id: \.self) { index in
                HStack {
                    TextField("Social Media URL / Handle", text: Binding(
                        get: { socialMediaURLs[index] },
                        set: { newValue in
                            socialMediaURLs[index] = newValue
                            ensureEmptySocialRow()
                        }
                    ))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                    if socialMediaURLs.count > 1 || !socialMediaURLs[index].isEmpty {
                        Button(action: {
                            socialMediaURLs.remove(at: index)
                            ensureEmptySocialRow()
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        } header: {
            Text("Social Media")
        }
    }
    
    @ViewBuilder
    func addressesSection() -> some View {
        Section {
            ForEach(addresses) { addr in
                HStack {
                    VStack(alignment: .leading) {
                        if addr.street.isEmpty && addr.city.isEmpty {
                            Text("Add Address...")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Text(addr.street)
                                .font(.headline)
                            if !addr.city.isEmpty {
                                Text("\(addr.city), \(addr.state)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    Spacer()
                    
                    if addr.isDefault {
                        Image(systemName: "star.fill")
                            .foregroundColor(appSettings.primaryColor.color)
                            .font(.caption)
                    }
                    
                    Button(addr.street.isEmpty ? "Add" : "Edit") { editAddress(addr) }
                        .foregroundColor(appSettings.primaryColor.color)
                }
            }
            .onDelete { indices in
                addresses.remove(atOffsets: indices)
            }
            
            if !addresses.contains(where: { $0.street.isEmpty && $0.city.isEmpty }) {
                Button(action: { 
                    let newAddr = Address(type: "Home", street: "", city: "", state: "", zip: "", country: "USA")
                    addresses.append(newAddr)
                    editAddress(newAddr)
                }) {
                    Label("Add Another Address", systemImage: "mappin.and.ellipse")
                        .foregroundColor(appSettings.primaryColor.color)
                }
            }
        } header: {
            Text("Addresses")
        }
    }
    
    @ViewBuilder
    func relationshipsSection() -> some View {
        Group {
            Section {
                if let bday = birthday {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Month:")
                            Picker("Month", selection: Binding<Int>(
                                get: { bday.month },
                                set: { bday.month = $0 }
                            )) {
                                Text("Unknown").tag(0)
                                ForEach(1...12, id: \.self) { month in
                                    Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("Day:")
                            Picker("Day", selection: Binding<Int>(
                                get: { bday.day },
                                set: { bday.day = $0 }
                            )) {
                                Text("Unknown").tag(0)
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        HStack {
                            Text("Year:")
                            Picker("Year", selection: Binding<Int>(
                                get: { bday.year ?? 0 },
                                set: { newValue in
                                    if newValue > 0 {
                                        bday.year = newValue
                                    } else {
                                        bday.year = nil
                                    }
                                }
                            )) {
                                Text("Unknown").tag(0)
                                ForEach(1900...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                                    Text("\(year)").tag(year)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Button(action: {
                            birthday = nil
                        }) {
                            Label("Remove Birthday", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.top, 4)
                    }
                } else {
                    Button(action: { 
                        birthday = Birthday(month: 0, day: 0)
                    }) {
                        Label("Add Birthday", systemImage: "gift.fill")
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                }
            } header: {
                Text("Birthday")
            }
            
            Section {
                if let spouse = spouse {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(spouse.displayName)
                                .font(.headline)
                            if let bday = spouse.birthday {
                                Text("Born \(bday.shortDisplayString)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button("Edit") { showingAddSpouseSheet = true }
                            .foregroundColor(appSettings.primaryColor.color)
                        Button(action: { self.spouse = nil }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Button(action: { showingAddSpouseSheet = true }) {
                        Label("Add Spouse", systemImage: "heart.fill")
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                }
            } header: {
                Text("Spouse")
            }
            
            Section {
                ForEach(kids) { kid in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(kid.displayName)
                                .font(.headline)
                        }
                        Spacer()
                        Button("Edit") { editKid(kid) }
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                }
                .onDelete(perform: deleteKids)
                
                Button(action: { showingAddKidSheet = true }) {
                    Label("Add Child", systemImage: "person.2.fill")
                        .foregroundColor(appSettings.primaryColor.color)
                }
            } header: {
                Text("Children")
            }
        }
    }
}

// MARK: - EditKidSheet
struct EditKidSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    
    // Partial birthday state
    @State private var birthMonth: Int = 0 
    @State private var birthDay: Int = 0
    @State private var birthYear: Int = 0 
    
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
            _birthMonth = State(initialValue: kidBirthday.month)
            _birthDay = State(initialValue: kidBirthday.day)
            _birthYear = State(initialValue: kidBirthday.year ?? 0)
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
                        // Only create birthday if something is set
                        var newBirthday: Birthday? = nil
                        if birthMonth > 0 || birthDay > 0 || birthYear > 0 {
                             newBirthday = Birthday(
                                month: birthMonth,
                                day: birthDay,
                                year: birthYear > 0 ? birthYear : nil
                            )
                        }
                        
                        let updatedKid = Kid(
                            firstName: firstName.trimmingCharacters(in: .whitespaces),
                            lastName: lastName.trimmingCharacters(in: .whitespaces),
                            birthday: newBirthday
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

// MARK: - FieldFormatters
struct FieldFormatters {
    static func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        var result = ""
        var index = cleanNumber.startIndex
        for ch in mask {
            if index == cleanNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}


