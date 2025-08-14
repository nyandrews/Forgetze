import Foundation

struct Contact: Identifiable, Codable, Validatable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var notes: String
    var group: String
    var birthday: Birthday?
    var kids: [Kid]
    var createdAt: Date
    var updatedAt: Date
    
    init(firstName: String, lastName: String, notes: String = "", group: String = "", birthday: Birthday? = nil, kids: [Kid] = []) {
        self.firstName = firstName
        self.lastName = lastName
        self.notes = notes
        self.group = group
        self.birthday = birthday
        self.kids = kids
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
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
    
    var hasKids: Bool {
        return !kids.isEmpty
    }
    
    var kidsCount: Int {
        return kids.count
    }
    
    // MARK: - Validation
    
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
