import Foundation
import SwiftData

struct SampleData {
    static let sampleContacts = [
        Contact(
            firstName: "John",
            lastName: "Doe",
            notes: "Family friend, loves hiking and outdoor activities. Met through mutual friends at the local hiking club. Always brings homemade trail mix to gatherings. Planning a camping trip next month. Drives a blue Subaru Outback. Graduated from University of Colorado Boulder with a degree in Environmental Science.",
    
            socialMediaURLs: ["https://linkedin.com/in/johndoe", "https://twitter.com/johndoe"],
            birthday: Birthday(date: Date().addingTimeInterval(-30*365*24*60*60)),
            kids: [
                Kid(firstName: "Emma", lastName: "Doe", birthday: Birthday(date: Date().addingTimeInterval(-5*365*24*60*60))),
                Kid(firstName: "Liam", lastName: "Doe", birthday: Birthday(month: 3, day: 8)), // March 8, no year
                Kid(firstName: "Sophia", lastName: "Doe", birthday: Birthday(date: Date().addingTimeInterval(-1*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Sarah",
            lastName: "Smith",
            notes: "Work colleague and project manager for the mobile app team. Excellent at coordinating cross-functional projects. Loves coffee and has a standing Friday afternoon meeting. Always professional and deadline-oriented. Drives a silver Tesla Model 3. Graduated from Stanford University with an MBA in Technology Management.",
    
            socialMediaURLs: ["https://twitter.com/sarahsmith", "https://linkedin.com/in/sarahsmith"],
            birthday: Birthday(date: Date().addingTimeInterval(-28*365*24*60*60)),
            kids: [
                Kid(firstName: "Maya", lastName: "Smith", birthday: Birthday(date: Date().addingTimeInterval(-8*365*24*60*60))),
                Kid(firstName: "Jake", lastName: "Smith", birthday: Birthday(month: 7, day: 14)) // July 14, no year
            ]
        ),
        Contact(
            firstName: "Mike",
            lastName: "Johnson",
            notes: "Neighbor from across the street. Always helpful with yard work and home maintenance. Retired firefighter with great stories. Loves grilling and often shares BBQ tips. Has a beautiful garden. Drives a red Ford F-150 pickup truck. Graduated from the Fire Academy and served 25 years with the city fire department.",
    
            socialMediaURLs: ["https://facebook.com/mike.johnson", "https://instagram.com/mikejohnson"],
            birthday: Birthday(date: Date().addingTimeInterval(-45*365*24*60*60)),
            kids: [
                Kid(firstName: "Alex", lastName: "Johnson", birthday: Birthday(date: Date().addingTimeInterval(-12*365*24*60*60))),
                Kid(firstName: "Taylor", lastName: "Johnson", birthday: Birthday(date: Date().addingTimeInterval(-10*365*24*60*60))),
                Kid(firstName: "Jordan", lastName: "Johnson", birthday: Birthday(date: Date().addingTimeInterval(-7*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Lisa",
            lastName: "Brown",
            notes: "Book club organizer and avid reader. Hosts monthly meetings at her home. Specializes in mystery novels and historical fiction. Great cook and always serves themed snacks. Met at the local library. Drives a green Honda Civic. Graduated from University of Michigan with a degree in English Literature.",
    
            socialMediaURLs: ["https://instagram.com/lisabrown", "https://pinterest.com/lisabrown"],
            birthday: Birthday(month: 6, day: 15), // June 15, no year
            kids: [
                Kid(firstName: "Olivia", lastName: "Brown", birthday: Birthday(date: Date().addingTimeInterval(-9*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "David",
            lastName: "Wilson",
            notes: "College roommate and best friend. Software engineer who loves video games and board games. We meet up every other weekend for game night. Great sense of humor and always up for adventure. Drives a black BMW 3 Series. Graduated from MIT with a degree in Computer Science.",
    
            socialMediaURLs: ["https://github.com/davidwilson", "https://linkedin.com/in/davidwilson"],
            birthday: Birthday(date: Date().addingTimeInterval(-32*365*24*60*60)),
            kids: [
                Kid(firstName: "Noah", lastName: "Wilson", birthday: Birthday(date: Date().addingTimeInterval(-4*365*24*60*60))),
                Kid(firstName: "Ava", lastName: "Wilson", birthday: Birthday(date: Date().addingTimeInterval(-2*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Jennifer",
            lastName: "Garcia",
            notes: "Dentist at Downtown Dental. Very thorough and gentle with patients. Loves yoga and meditation. Always gives great health advice. Met through a mutual friend's recommendation. Drives a white Lexus RX. Graduated from UCLA with a Doctor of Dental Surgery degree.",
    
            socialMediaURLs: ["https://linkedin.com/in/jennifergarcia", "https://twitter.com/jennifergarcia"],
            birthday: Birthday(date: Date().addingTimeInterval(-38*365*24*60*60)),
            kids: [
                Kid(firstName: "Isabella", lastName: "Garcia", birthday: Birthday(date: Date().addingTimeInterval(-11*365*24*60*60))),
                Kid(firstName: "Lucas", lastName: "Garcia", birthday: Birthday(date: Date().addingTimeInterval(-8*365*24*60*60))),
                Kid(firstName: "Elena", lastName: "Garcia", birthday: Birthday(date: Date().addingTimeInterval(-5*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Robert",
            lastName: "Taylor",
            notes: "Gym buddy and fitness enthusiast. Personal trainer who gives great workout advice. Loves protein shakes and meal prep. We work out together three times a week. Always motivating. Drives a gray Toyota Camry. Graduated from Arizona State University with a degree in Exercise Science.",
    
            socialMediaURLs: ["https://instagram.com/roberttaylor.fitness", "https://youtube.com/@roberttaylor"],
            birthday: Birthday(date: Date().addingTimeInterval(-29*365*24*60*60)),
            kids: [
                Kid(firstName: "William", lastName: "Taylor", birthday: Birthday(date: Date().addingTimeInterval(-6*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Amanda",
            lastName: "Martinez",
            notes: "Art teacher at the community center. Incredibly creative and inspiring. Teaches painting and pottery classes. Loves nature and often incorporates outdoor elements into her art. Met at the local art fair. Drives a purple Volkswagen Beetle. Graduated from Rhode Island School of Design with a degree in Fine Arts.",
    
            socialMediaURLs: ["https://pinterest.com/amandamartinez.art", "https://instagram.com/amandamartinez.art"],
            birthday: Birthday(month: 9, day: 22), // September 22, no year
            kids: [
                Kid(firstName: "Chloe", lastName: "Martinez", birthday: Birthday(date: Date().addingTimeInterval(-7*365*24*60*60))),
                Kid(firstName: "Ethan", lastName: "Martinez", birthday: Birthday(date: Date().addingTimeInterval(-4*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Thomas",
            lastName: "Anderson",
            notes: "Local coffee shop owner. Makes the best espresso in town. Loves jazz music and often plays it in the shop. Great conversationalist and knows everyone's name. Met while getting coffee. Drives a brown Ford Transit van for deliveries. Graduated from Seattle University with a degree in Business Administration.",
    
            socialMediaURLs: ["https://instagram.com/coffeeanderson", "https://twitter.com/coffeeanderson"],
            birthday: Birthday(date: Date().addingTimeInterval(-41*365*24*60*60)),
            kids: [
                Kid(firstName: "Benjamin", lastName: "Anderson", birthday: Birthday(date: Date().addingTimeInterval(-13*365*24*60*60))),
                Kid(firstName: "Zoe", lastName: "Anderson", birthday: Birthday(date: Date().addingTimeInterval(-9*365*24*60*60))),
                Kid(firstName: "Henry", lastName: "Anderson", birthday: Birthday(date: Date().addingTimeInterval(-6*365*24*60*60))),
                Kid(firstName: "Lily", lastName: "Anderson", birthday: Birthday(date: Date().addingTimeInterval(-3*365*24*60*60)))
            ]
        ),
        Contact(
            firstName: "Rachel",
            lastName: "Clark",
            notes: "Volunteer coordinator at the animal shelter. Passionate about animal welfare and adoption. Loves hiking with her rescue dogs. Organizes monthly adoption events. Met while volunteering. Drives a silver Honda CR-V. Graduated from University of Oregon with a degree in Animal Science.",
    
            socialMediaURLs: ["https://facebook.com/rachel.clark.volunteer", "https://instagram.com/rachelclark.volunteer"],
            birthday: Birthday(month: 12, day: 3), // December 3, no year
            kids: [
                Kid(firstName: "Grace", lastName: "Clark", birthday: Birthday(date: Date().addingTimeInterval(-10*365*24*60*60)))
            ]
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

