//
//  ForgetzeApp.swift
//  Forgetze
//
//  Created by Mark Andrews on 8/14/25.
//

import SwiftUI
import SwiftData

@main
struct ForgetzeApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            Kid.self,
            Birthday.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.currentColorScheme)
                .onAppear {
                    // Add sample data if this is the first launch
                    if UserDefaults.standard.bool(forKey: "hasAddedSampleData") == false {
                        let modelContext = sharedModelContainer.mainContext
                        SampleData.addSampleData(to: modelContext)
                        UserDefaults.standard.set(true, forKey: "hasAddedSampleData")
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
