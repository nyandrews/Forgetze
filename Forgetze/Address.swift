import Foundation
import SwiftData

@Model
final class Address {
    var id: UUID = UUID()
    var type: String = "Home" // "Home", "Work", "Other", or custom names
    var street: String = ""
    var street2: String? // Apartment, suite, unit, etc. (optional for backward compatibility)
    var city: String = ""
    var state: String = "" // 2-letter state code
    var zip: String = ""
    var country: String = "United States"
    var isDefault: Bool = false // Whether this is the primary address
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Relationship to Contact
    var contact: Contact?
    
    init(type: String = "Home", street: String = "", street2: String? = nil, city: String = "", state: String = "", zip: String = "", country: String = "United States", isDefault: Bool = false) {
        self.type = type
        self.street = street
        self.street2 = street2
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.isDefault = isDefault
    }
    
    // Computed property for full address string
    var fullAddress: String {
        var components: [String] = []
        
        if !street.isEmpty { components.append(street) }
        if let street2 = street2, !street2.isEmpty { components.append(street2) }
        if !city.isEmpty || !state.isEmpty || !zip.isEmpty {
            let cityStateZip = [city, state, zip].filter { !$0.isEmpty }.joined(separator: ", ")
            if !cityStateZip.isEmpty { components.append(cityStateZip) }
        }
        if !country.isEmpty && country != "United States" { components.append(country) }
        
        return components.joined(separator: "\n")
    }
    
    // Computed property for display string (used in sharing)
    var displayString: String {
        var components: [String] = []
        
        if !type.isEmpty { components.append("[\(type)]") }
        if !street.isEmpty { components.append(street) }
        if let street2 = street2, !street2.isEmpty { components.append(street2) }
        if !city.isEmpty || !state.isEmpty || !zip.isEmpty {
            let cityStateZip = [city, state, zip].filter { !$0.isEmpty }.joined(separator: ", ")
            if !cityStateZip.isEmpty { components.append(cityStateZip) }
        }
        if !country.isEmpty && country != "United States" { components.append(country) }
        
        return components.joined(separator: " ")
    }
    
    // Computed property for address validation
    var isValid: Bool {
        return !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty
    }
    
    // Method to update timestamp
    func updateTimestamp() {
        self.updatedAt = Date()
    }
}

// MARK: - Address Type Presets
extension Address {
    static let predefinedTypes = ["Home", "Work", "Other"]
    
    static func createDefaultHomeAddress() -> Address {
        return Address(type: "Home", isDefault: true)
    }
}

// MARK: - Address Validation
extension Address {
    func validateState() -> Bool {
        // North American state/province validation
        let validStates = [
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
        return validStates.contains(state.uppercased())
    }
    
    func validateZIP() -> Bool {
        // Basic ZIP code validation (5 digits or 5+4 format)
        let zipRegex = #"^\d{5}(-\d{4})?$"#
        return zip.range(of: zipRegex, options: .regularExpression) != nil
    }
}
