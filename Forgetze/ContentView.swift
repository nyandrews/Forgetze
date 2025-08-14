//
//  ContentView.swift
//  Forgetze
//
//  Created by Mark Andrews on 8/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContactListView()
            .environmentObject(appSettings)
            .onAppear {
                // Add sample data if this is the first launch
                if UserDefaults.standard.bool(forKey: "hasAddedSampleData") == false {
                    addSampleData()
                    UserDefaults.standard.set(true, forKey: "hasAddedSampleData")
                }
            }
    }
    
    private func addSampleData() {
        let sampleContacts = [
            Contact(
                firstName: "John",
                lastName: "Doe",
                notes: "Family friend from college. Loves hiking, camping, and craft beer. Works as a software engineer at TechCorp. Met through mutual friend Sarah. Always up for weekend adventures. Wife is Maria, they have two amazing kids. Favorite hiking spot is Mount Tamalpais. Birthday party is usually a backyard BBQ with friends.",
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
                notes: "Work colleague and close friend. Senior project manager at TechCorp, leads our mobile app team. Incredibly organized and detail-oriented. Loves yoga, reading mystery novels, and trying new restaurants. Has a cat named Luna. Always brings homemade cookies to team meetings. Planning a trip to Japan next spring. Great mentor for new team members.",
                group: "Work",
                birthday: Birthday(date: Date().addingTimeInterval(-28*365*24*60*60))
            ),
            Contact(
                firstName: "Mike",
                lastName: "Johnson",
                notes: "Next-door neighbor for 5 years. Retired firefighter, now volunteers at the local fire station. Extremely helpful - always shovels our driveway in winter and helps with home repairs. Loves gardening and has the most beautiful roses on the block. Wife is Carol, they've been married 35 years. Has a workshop in his garage where he builds birdhouses. Great source of neighborhood gossip and local history.",
                group: "Neighbors",
                birthday: Birthday(date: Date().addingTimeInterval(-45*365*24*60*60)),
                kids: [
                    Kid(firstName: "Alex", lastName: "Johnson", birthday: Birthday(month: 3, day: 22)) // No year known
                ]
            ),
            Contact(
                firstName: "Lisa",
                lastName: "Brown",
                notes: "Book club organizer and fellow bookworm. Runs the local library's monthly book discussion group. Former English teacher, now works as a freelance editor. Loves historical fiction, especially WWII era novels. Has a collection of over 500 books. Lives in a charming Victorian house downtown. Husband is Tom, they have no children but three rescue dogs. Always has great book recommendations and hosts the best book club meetings with wine and cheese.",
                group: "Hobbies",
                birthday: Birthday(month: 6, day: 15) // No year known
            ),
            Contact(
                firstName: "David",
                lastName: "Chen",
                notes: "Fitness trainer at the gym. Helped me get back into shape after the pandemic. Very motivating and knowledgeable about nutrition. Loves rock climbing and has climbed El Capitan twice. Originally from San Francisco, moved here for the outdoor lifestyle. Wife is Jennifer, they have a baby on the way. Always shares healthy recipe ideas and workout tips. Great person to talk to about fitness goals and motivation.",
                group: "Health",
                birthday: Birthday(date: Date().addingTimeInterval(-32*365*24*60*60))
            ),
            Contact(
                firstName: "Maria",
                lastName: "Garcia",
                notes: "Local restaurant owner. Runs the amazing 'Casa Maria' Mexican restaurant downtown. Incredible cook and warm personality. Always remembers our favorite orders. Loves to share stories about growing up in Mexico City. Has two teenage daughters, Sofia and Isabella. The restaurant is a family business started by her parents. Great place to bring out-of-town guests. Always has the best recommendations for authentic Mexican food in the area.",
                group: "Food",
                birthday: Birthday(date: Date().addingTimeInterval(-38*365*24*60*60))
            )
        ]
        
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

#Preview {
    ContentView()
        .environmentObject(AppSettings())
        .modelContainer(for: Contact.self, inMemory: true)
}
