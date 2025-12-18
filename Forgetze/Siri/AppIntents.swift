import AppIntents
import SwiftUI

// MARK: - Search Intent

struct SearchContactsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Forgetze"
    static var description = IntentDescription("Searches for a contact in Forgetze based on your query.")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Query", requestValueDialog: "Who are you looking for?")
    var query: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Construct the deep link URL
        // format: forgetze://search?query=Honda
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "forgetze://search?query=\(encodedQuery)"
        
        if let url = URL(string: urlString) {
            // Open the app via URL scheme
            await UIApplication.shared.open(url)
        }
        
        return .result()
    }
}

// MARK: - Shortcuts Provider

struct ForgetzeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchContactsIntent(),
            phrases: [
                "Search \(.applicationName) for \(\.$query)",
                "Find \(\.$query) in \(.applicationName)",
                "Look up \(\.$query) in \(.applicationName)",
                "Search by memory in \(.applicationName)"
            ],
            shortTitle: "Search Contact",
            systemImageName: "magnifyingglass"
        )
    }
}
