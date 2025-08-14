import Foundation
import SwiftData

struct SampleData {
    static let sampleContacts = [
        Contact(
            firstName: "John",
            lastName: "Doe",
            notes: "Family friend, loves hiking",
            group: "Family",
            birthday: Birthday(date: Date().addingTimeInterval(-30*365*24*60*60)),
            kids: [
                Kid(firstName: "Emma", lastName: "Doe", birthday: Birthday(date: Date().addingTimeInterval(-5*365*24*60*60))),
                Kid(firstName: "Liam", lastName: "Doe", birthday: Birthday(date: Date().addingTimeInterval(-3*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Sarah",
            lastName: "Smith",
            notes: "Work colleague, project manager",
            group: "Work",
            birthday: Birthday(date: Date().addingTimeInterval(-28*365*24*60*60))
        ),
        Contact(
            firstName: "Mike",
            lastName: "Johnson",
            notes: "Neighbor, always helpful",
            group: "Neighbors",
            birthday: Birthday(date: Date().addingTimeInterval(-45*365*24*60*60)),
            kids: [
                Kid(firstName: "Alex", lastName: "Johnson", birthday: Birthday(date: Date().addingTimeInterval(-12*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Lisa",
            lastName: "Brown",
            notes: "Book club organizer",
            group: "Hobbies",
            birthday: Birthday(date: Date().addingTimeInterval(-35*365*24*60*60))
        )
    ]
    
    static func addSampleData(to modelContext: ModelContext) {
        for contact in sampleContacts {
            modelContext.insert(contact)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
}
