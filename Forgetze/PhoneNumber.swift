import Foundation
import SwiftData

@Model
final class PhoneNumber: Identifiable {
    var id: UUID = UUID()
    var number: String = ""
    var label: String = "Mobile" // e.g., "Mobile", "Home", "Work"
    
    // Relationship to Contact (optional inverse, though usually managed by Contact)
    // We don't necessarily need an explicit inverse if we only access via Contact
    
    init(number: String, label: String = "Mobile") {
        self.number = number
        self.label = label
    }
}
