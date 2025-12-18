import Foundation
import SwiftData

struct SampleData {
    static var sampleContacts: [Contact] {
        return [
        Contact(
            firstName: "Akira",
            lastName: "Zushi",
            notes: "From Japan, drives blue Honda, went to NYU and studied chemistry, friends with Steve.",
            phoneNumbers: [PhoneNumber(number: "(555) 123-4567", label: "Mobile")],
            socialMediaURLs: [
                "https://instagram.com/akirazushi",
                "https://linkedin.com/in/akirazushi",
                "https://facebook.com/akirazushi",
                "https://twitter.com/akirazushi",
                "https://tiktok.com/@akirazushi",
                "https://youtube.com/@akirazushi_cooking"
            ],
            birthday: Birthday(month: 5, day: 21, year: 1988), // May 21, 1988
            kids: [
                Kid(firstName: "Kenji", lastName: "Zushi", birthday: Birthday(date: Date().addingTimeInterval(-8*365*24*60*60))),
                Kid(firstName: "Hana", lastName: "Zushi", birthday: Birthday(date: Date().addingTimeInterval(-5*365*24*60*60)))
            ],
            spouse: Spouse(
                firstName: "Keiko",
                lastName: "Zushi",
                birthday: Birthday(month: 6, day: 15, year: Calendar.current.component(.year, from: Date()) - 32)
            ),
            addresses: [
                Address(type: "Work", street: "123 Main St", street2: "Suite 100", city: "New York", state: "NY", zip: "10001", isDefault: true),
                Address(type: "Home", street: "45 River Rd", city: "Brooklyn", state: "NY", zip: "11201")
            ],
            isSample: true
        ),
        Contact(
            firstName: "Tony",
            lastName: "Bevilaqua",
            notes: "Reliable plumber, available 24/7. Fixed the leak in the basement last winter. Very fair pricing and quick service. Recommended by the neighbors. big fan of Italian opera. Drives a white service van.",
            phoneNumbers: [PhoneNumber(number: "(555) 234-5678", label: "Mobile")],
            socialMediaURLs: [
                "https://facebook.com/tonybevilaquaplumbing",
                "https://instagram.com/tonytheplumber",
                "https://yelp.com/biz/tony-bevilaqua-plumbing",
                "https://linkedin.com/in/tonybevilaqua",
                "https://twitter.com/tonyfixit",
                "https://angieslist.com/company/tonybevilaqua"
            ],
            birthday: Birthday(month: 11, day: 12, year: 1980), // November 12, 1980
            kids: [
                Kid(firstName: "Anthony Jr.", lastName: "Bevilaqua", birthday: Birthday(date: Date().addingTimeInterval(-15*365*24*60*60))),
                Kid(firstName: "Maria", lastName: "Bevilaqua", birthday: Birthday(date: Date().addingTimeInterval(-12*365*24*60*60))),
                Kid(firstName: "Sofia", lastName: "Bevilaqua", birthday: Birthday(date: Date().addingTimeInterval(-9*365*24*60*60)))
            ],
            spouse: Spouse(
                firstName: "Carmela",
                lastName: "Bevilaqua",
                birthday: Birthday(month: 4, day: 3, year: Calendar.current.component(.year, from: Date()) - 38)
            ),
            addresses: [
                Address(type: "Work", street: "78 Industrial Pkwy", city: "Newark", state: "NJ", zip: "07102", isDefault: true)
            ],
            isSample: true
        ),
        Contact(
            firstName: "Cindy",
            lastName: "Dubois",
            notes: "Yoga instructor and wellness coach. Runs the morning classes at the community center. Very inspiring and positive energy. Organizes annual wellness retreats. Met at the local organic market. Drives a hybrid SUV.",
            phoneNumbers: [PhoneNumber(number: "(555) 345-6789", label: "Home")],
            socialMediaURLs: [
                "https://instagram.com/cindydubois_yoga",
                "https://youtube.com/@cindydubois",
                "https://facebook.com/cindyduboiswellness",
                "https://tiktok.com/@zenwithcindy",
                "https://pinterest.com/cindydubois",
                "https://linkedin.com/in/cindydubois"
            ],
            birthday: Birthday(month: 3, day: 8, year: 1993), // March 8, 1993
            kids: [
                Kid(firstName: "Leo", lastName: "Dubois", birthday: Birthday(date: Date().addingTimeInterval(-6*365*24*60*60)))
            ],
            spouse: Spouse(
                firstName: "Julian",
                lastName: "Dubois",
                birthday: Birthday(month: 9, day: 22, year: Calendar.current.component(.year, from: Date()) - 34)
            ),
            addresses: [
                Address(type: "Home", street: "88 Maple Ave", city: "Portland", state: "OR", zip: "97205", isDefault: true),
                Address(type: "Studio", street: "442 Wellness Way", city: "Portland", state: "OR", zip: "97209")
            ],
            isSample: true
        )
        ]
    }
    
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
