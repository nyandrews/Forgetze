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
                
                Section("Address Details") {
                    TextField("Street Address", text: $street)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Street Address 2 (Apt, Suite, etc.)", text: $street2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        TextField("City", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("State", text: $state)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 80)
                            .textInputAutocapitalization(.characters)
                            .onChange(of: state) { _, newValue in
                                state = newValue.uppercased()
                            }
                    }
                    
                    HStack {
                        TextField("ZIP Code", text: $zip)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        TextField("Country", text: $country)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section("Validation") {
                    HStack {
                        Image(systemName: state.isEmpty ? "circle" : (Address(type: "", street: "", street2: nil, city: "", state: state, zip: "").validateState() ? "checkmark.circle.fill" : "xmark.circle.fill"))
                            .foregroundColor(state.isEmpty ? .secondary : (Address(type: "", street: "", street2: "", city: "", state: state, zip: "").validateState() ? .green : .red))
                        Text("State Code")
                        Spacer()
                        Text(state.isEmpty ? "Required" : (Address(type: "", street: "", street2: nil, city: "", state: state, zip: "").validateState() ? "Valid" : "Invalid"))
                            .font(.caption)
                            .foregroundColor(state.isEmpty ? .secondary : (Address(type: "", street: "", street2: nil, city: "", state: state, zip: "").validateState() ? .green : .red))
                    }
                    
                    HStack {
                        Image(systemName: zip.isEmpty ? "circle" : (Address(type: "", street: "", street2: nil, city: "", state: "", zip: zip).validateZIP() ? "checkmark.circle.fill" : "xmark.circle.fill"))
                            .foregroundColor(zip.isEmpty ? .secondary : (Address(type: "", street: "", street2: nil, city: "", state: "", zip: zip).validateZIP() ? .green : .red))
                        Text("ZIP Code")
                        Spacer()
                        Text(zip.isEmpty ? "Required" : (Address(type: "", street: "", street2: "", city: "", state: "", zip: zip).validateZIP() ? "Valid" : "Invalid"))
                            .font(.caption)
                            .foregroundColor(zip.isEmpty ? .secondary : (Address(type: "", street: "", street2: "", city: "", state: "", zip: zip).validateZIP() ? .green : .red))
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
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        return !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty &&
               Address(type: "", street: "", street2: "", city: "", state: state, zip: zip).validateState() &&
               Address(type: "", street: "", street2: "", city: "", state: "", zip: zip).validateZIP()
    }
    
    private func saveAddress() {
        let finalType = showingCustomTypeInput && !customType.isEmpty ? customType : type
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
        dismiss()
    }
}

#Preview {
    AddressEditView { address in
        print("Saved address: \(address)")
    }
    .environmentObject(AppSettings())
}
