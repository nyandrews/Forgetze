import Foundation
import SwiftData

/**
 * Contact Model
 * 
 * Represents a contact person in the Forgetze app with comprehensive information
 * including personal details, relationships, and social media connections.
 * 
 * This model implements the Validatable protocol to ensure data integrity
 * and provides computed properties for easy access to derived information.
 * 
 * ## Key Features:
 * - Full name and contact information
 * - Birthday tracking with age calculation
 * - Kids/family relationship management
 * - Social media URL storage
 * - Automatic timestamp tracking
 * - Data validation
 * 
 * ## Usage Example:
 * ```swift
 * let contact = Contact(
 *     firstName: "John",
 *     lastName: "Doe",
 *     notes: "Software engineer and friend"
 * )
 * 
 * if contact.isValid {
 *     // Save to database
 * }
 * ```
 * 
 * ## Data Persistence:
 * Uses SwiftData for automatic persistence with automatic ID generation
 * and timestamp tracking for creation and updates.
 */
@Model
final class Contact: Identifiable, Validatable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var notes: String

    var socialMediaURLs: [String]
    var birthday: Birthday?
    var kids: [Kid]
    var addresses: [Address]
    var createdAt: Date
    var updatedAt: Date
    
    /**
     * Initialize a new Contact
     * 
     * Creates a new contact with the specified information and automatically
     * sets creation and update timestamps.
     * 
     * - Parameters:
     *   - firstName: The contact's first name (required)
     *   - lastName: The contact's last name (required)
     *   - notes: Additional notes about the contact (optional, defaults to empty)
     *   - socialMediaURLs: Array of social media profile URLs (optional, defaults to empty)
     *   - birthday: The contact's birthday information (optional)
     *   - kids: Array of children/family members (optional, defaults to empty)
     * 
     * - Note: firstName and lastName are required for validation. Empty strings
     *   will cause the contact to fail validation.
     */
    init(firstName: String, lastName: String, notes: String = "", socialMediaURLs: [String] = [], birthday: Birthday? = nil, kids: [Kid] = [], addresses: [Address] = []) {
        self.firstName = firstName
        self.lastName = lastName
        self.notes = notes
        self.socialMediaURLs = socialMediaURLs
        self.birthday = birthday
        self.kids = kids
        self.addresses = addresses
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /**
     * Full name of the contact
     * 
     * Combines firstName and lastName with proper handling of empty values.
     * Returns "Unknown Contact" if both names are empty or whitespace.
     * 
     * - Returns: A formatted full name string
     * 
     * ## Examples:
     * - "John Doe" for firstName: "John", lastName: "Doe"
     * - "Smith" for firstName: "", lastName: "Smith"
     * - "Unknown Contact" for firstName: "", lastName: ""
     */
    var fullName: String {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if first.isEmpty && last.isEmpty {
            return "Unknown Contact"
        } else if first.isEmpty {
            return last
        } else if last.isEmpty {
            return first
        } else {
            return "\(first) \(last)"
        }
    }
    
    var displayName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return "Unnamed Contact"
        } else if firstName.isEmpty {
            return lastName
        } else if lastName.isEmpty {
            return firstName
        } else {
            return "\(firstName) \(lastName)"
        }
    }
    
    var initials: String {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if first.isEmpty && last.isEmpty {
            return "?"
        } else if first.isEmpty {
            return String(last.prefix(2)).uppercased()
        } else if last.isEmpty {
            return String(first.prefix(2)).uppercased()
        } else {
            let firstInitial = String(first.prefix(1))
            let lastInitial = String(last.prefix(1))
            return "\(firstInitial)\(lastInitial)".uppercased()
        }
    }
    
    var age: Int? {
        return birthday?.age
    }
    
    var birthdayDisplay: String {
        if let birthday = birthday {
            return birthday.displayString
        } else {
            return "No birthday set"
        }
    }
    
    var shortBirthdayDisplay: String {
        if let birthday = birthday {
            return birthday.shortDisplayString
        } else {
            return "No birthday"
        }
    }
    
    var hasKids: Bool {
        return !kids.isEmpty
    }
    
    var kidsCount: Int {
        return kids.count
    }
    
    var hasSocialMedia: Bool {
        return !socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.isEmpty
    }
    
    var hasAddresses: Bool {
        return !addresses.filter { $0.isValid }.isEmpty
    }
    
    var addressesCount: Int {
        return addresses.filter { $0.isValid }.count
    }
    
    var defaultAddress: Address? {
        return addresses.first { $0.isDefault } ?? addresses.first { $0.isValid }
    }
    
    var shareText: String {
        var text = "\(displayName)"
        if !notes.isEmpty {
            text += "\n\nNotes: \(notes)"
        }
        if let birthday = birthday {
            text += "\n\nBirthday: \(birthday.displayString)"
        }
        if hasKids {
            text += "\n\nChildren: \(kids.map { $0.displayName }.joined(separator: ", "))"
        }
        if hasAddresses {
            text += "\n\nAddresses: \(addresses.map { $0.displayString }.joined(separator: "; "))"
        }
        if hasSocialMedia {
            text += "\n\nSocial Media: \(socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.joined(separator: ", "))"
        }
        return text
    }
    
    // MARK: - Validation
    
    /**
     * Validation status of the contact
     * 
     * Checks if the contact has all required information and valid children.
     * A contact is considered valid if it has non-empty first and last names
     * and all associated kids are valid.
     * 
     * - Returns: `true` if the contact is valid, `false` otherwise
     * 
     * ## Validation Rules:
     * - firstName must not be empty or only whitespace
     * - lastName must not be empty or only whitespace
     * - All kids must be valid (if any exist)
     * 
     * - Note: This property is required by the Validatable protocol
     */
    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        kids.allSatisfy { $0.isValid }
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("First name is required")
        }
        
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Last name is required")
        }
        
        for (index, kid) in kids.enumerated() {
            if !kid.isValid {
                errors.append("Child \(index + 1): \(kid.validationErrors.joined(separator: ", "))")
            }
        }
        
        return errors
    }
}
