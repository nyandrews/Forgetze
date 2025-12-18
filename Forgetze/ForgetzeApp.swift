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
    @StateObject private var searchManager = SearchManager()
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 Deep link received: \(url.absoluteString)")
        guard url.scheme == "forgetze" else { return }
        
        // Handle search: forgetze://search?query=Honda
        if url.host == "search" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let queryItems = components?.queryItems,
               let query = queryItems.first(where: { $0.name == "query" })?.value {
                print("🔍 Deep link search query: \(query)")
                // Add a small delay to ensure UI is ready if launching from cold start
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    searchManager.searchText = query
                }
            }
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            Kid.self,
            Birthday.self,
            Address.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Standard app initialization
        print("🚀 Forgetze starting up")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environmentObject(searchManager)
                .preferredColorScheme(appSettings.currentColorScheme)
                .onAppear {
                    Task { @MainActor in
                        // Run deduplication on startup
                        await appSettings.removeDuplicateContacts(context: sharedModelContainer.mainContext)
                    }
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
