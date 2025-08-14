import Foundation

struct Kid: Codable, Identifiable, Validatable {
    var firstName: String
    var lastName: String
    var birthday: Birthday?
    
    // Generate a unique ID based on the kid's data
    var id: String {
        let name = "\(firstName)-\(lastName)"
        let birthdayId = birthday?.id ?? "N/A"
        return "\(name)-\(birthdayId)"
    }
    
    init(firstName: String, lastName: String, birthday: Birthday? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
    }
    
    var fullName: String {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if first.isEmpty && last.isEmpty {
            return "Unknown Child"
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
            return "Unnamed Child"
        } else if firstName.isEmpty {
            return lastName
        } else if last.isEmpty {
            return firstName
        } else {
            return "\(firstName) \(lastName)"
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
    
    // MARK: - Validation
    
    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("First name is required")
        }
        
        return errors
    }
}
