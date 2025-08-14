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
