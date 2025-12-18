import SwiftUI

struct AddressEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    let address: Address?
    let onSave: (Address) -> Void
    
    @State private var type: String = "Home"
    @State private var street: String = ""
    @State private var street2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zip: String = ""
    @State private var country: String = "United States"
    @State private var isDefault: Bool = false
    @State private var customType: String = ""
    @State private var showingCustomTypeInput = false
    
    private let predefinedTypes = Address.predefinedTypes
    private let validStates = [
        // US States
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
        // Canadian Provinces
        "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE",
        "QC", "SK", "YT"
    ]
    
    init(address: Address? = nil, onSave: @escaping (Address) -> Void) {
        self.address = address
        self.onSave = onSave
        
        if let address = address {
            _type = State(initialValue: address.type)
            _street = State(initialValue: address.street)
            _street2 = State(initialValue: address.street2 ?? "")
            _city = State(initialValue: address.city)
            _state = State(initialValue: address.state)
            _zip = State(initialValue: address.zip)
            _country = State(initialValue: address.country)
            _isDefault = State(initialValue: address.isDefault)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Address Type") {
                    HStack {
                        Text("Type")
                        Spacer()
                        Menu {
                            ForEach(predefinedTypes, id: \.self) { type in
                                Button(type) {
                                    self.type = type
                                    showingCustomTypeInput = false
                                }
                            }
                            
                            Divider()
                            
                            Button("Custom...") {
                                showingCustomTypeInput = true
                            }
                        } label: {
                            HStack {
                                Text(type)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if showingCustomTypeInput {
                        TextField("Enter custom type", text: $customType)
                            .onChange(of: customType) { _, newValue in
                                if !newValue.isEmpty {
                                    type = newValue
                                }
                            }
                    }
                    
                    Toggle("Set as Default Address", isOn: $isDefault)
                        .foregroundColor(appSettings.primaryColor.color)
                }
                
                Section {
                    TextField("Street Address", text: $street)
                    
                    TextField("Street Address 2 (Apt, Suite, etc.)", text: $street2)
                    
                    HStack {
                        TextField("City", text: $city)
                        
                        TextField("State", text: $state)
                            .frame(maxWidth: 80)
                            .textInputAutocapitalization(.characters)
                            .onChange(of: state) { _, newValue in
                                state = newValue.uppercased()
                            }
                    }
                    
                    HStack {
                        TextField("ZIP Code", text: $zip)
                            .keyboardType(.numberPad)
                        
                        TextField("Country", text: $country)
                    }
                } header: {
                    Text("Address Details")
                } footer: {
                    if !validationWarnings.isEmpty && !street.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Recommendations:")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            
                            ForEach(validationWarnings, id: \.self) { warning in
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption2)
                                    Text(warning)
                                }
                                .foregroundColor(.orange)
                            }
                        }
                    } else if !street.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Address format looks great")
                        }
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle(address == nil ? "Add Address" : "Edit Address")
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
                        saveAddress()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                    .disabled(street.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private var isValid: Bool {
        return Address(
            type: type,
            street: street,
            street2: street2,
            city: city,
            state: state,
            zip: zip,
            country: country,
            isDefault: isDefault
        ).isValid
    }
    
    private var validationWarnings: [String] {
        return Address(
            type: type,
            street: street,
            street2: street2,
            city: city,
            state: state,
            zip: zip,
            country: country,
            isDefault: isDefault
        ).validationWarnings
    }
    
    private func saveAddress() {
        let finalType = showingCustomTypeInput && !customType.isEmpty ? customType : type
        
        if let existingAddress = address {
            // Update existing address in place to preserve ID and relationships
            existingAddress.type = finalType
            existingAddress.street = street.trimmingCharacters(in: .whitespacesAndNewlines)
            existingAddress.street2 = street2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : street2.trimmingCharacters(in: .whitespacesAndNewlines)
            existingAddress.city = city.trimmingCharacters(in: .whitespacesAndNewlines)
            existingAddress.state = state.trimmingCharacters(in: .whitespacesAndNewlines)
            existingAddress.zip = zip.trimmingCharacters(in: .whitespacesAndNewlines)
            existingAddress.country = country.trimmingCharacters(in: .whitespacesAndNewlines)
            existingAddress.isDefault = isDefault
            existingAddress.updatedAt = Date()
            
            onSave(existingAddress)
        } else {
            // Create new address
            let newAddress = Address(
                type: finalType,
                street: street.trimmingCharacters(in: .whitespacesAndNewlines),
                street2: street2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : street2.trimmingCharacters(in: .whitespacesAndNewlines),
                city: city.trimmingCharacters(in: .whitespacesAndNewlines),
                state: state.trimmingCharacters(in: .whitespacesAndNewlines),
                zip: zip.trimmingCharacters(in: .whitespacesAndNewlines),
                country: country.trimmingCharacters(in: .whitespacesAndNewlines),
                isDefault: isDefault
            )
            onSave(newAddress)
        }
        
        dismiss()
    }
}

#Preview {
    AddressEditView { address in
        print("Saved address: \(address)")
    }
    .environmentObject(AppSettings())
}
