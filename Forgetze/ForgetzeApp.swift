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

    init() {
        // Pre-emptive memory management at app launch
        print("🚀 Forgetze starting up - Initializing memory management...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.currentColorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // Handle memory warnings
                    print("🚨 MEMORY WARNING RECEIVED - Running emergency cleanup")
                    appSettings.emergencyMemoryCleanup()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Clean up when app goes to background
                    print("📱 App going to background - Cleaning up memory")
                    appSettings.cleanupMemory()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Check memory when app becomes active
                    print("📱 App becoming active - Checking memory")
                    appSettings.logMemoryUsage()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
