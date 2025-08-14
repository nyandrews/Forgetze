import Foundation

protocol Validatable {
    var isValid: Bool { get }
    var validationErrors: [String] { get }
}

// MARK: - Default Implementation
extension Validatable {
    var isValid: Bool {
        validationErrors.isEmpty
    }
}
