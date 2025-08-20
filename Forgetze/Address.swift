import Foundation
import SwiftData

@Model
final class Address {
    var id: UUID
    var type: String // "Home", "Work", "Other", or custom names
    var street: String
    var city: String
    var state: String // 2-letter state code
    var zip: String
    var country: String
    var isDefault: Bool // Whether this is the primary address
    var createdAt: Date
    var updatedAt: Date
    
    // Relationship to Contact
    var contact: Contact?
    
    init(type: String = "Home", street: String = "", city: String = "", state: String = "", zip: String = "", country: String = "United States", isDefault: Bool = false) {
        self.id = UUID()
        self.type = type
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.isDefault = isDefault
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Computed property for full address string
    var fullAddress: String {
        var components: [String] = []
        
        if !street.isEmpty { components.append(street) }
        if !city.isEmpty || !state.isEmpty || !zip.isEmpty {
            let cityStateZip = [city, state, zip].filter { !$0.isEmpty }.joined(separator: ", ")
            if !cityStateZip.isEmpty { components.append(cityStateZip) }
        }
        if !country.isEmpty && country != "United States" { components.append(country) }
        
        return components.joined(separator: "\n")
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
