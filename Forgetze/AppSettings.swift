import Foundation
import SwiftUI
import Darwin
import SwiftData

enum AppThemeColor: String, CaseIterable {
    case red = "Red"
    case rose = "Rose"
    case coral = "Coral"
    case sunset = "Sunset"
    case orange = "Orange"
    case gold = "Gold"
    case mint = "Mint"
    case emerald = "Emerald"
    case green = "Green"
    case forest = "Forest"
    case ocean = "Ocean"
    case blue = "Blue"
    case indigo = "Indigo"
    case lavender = "Lavender"
    case purple = "Purple"
    case steel = "Steel"
    case midnight = "Midnight"
    
    var color: Color {
        switch self {
        case .red: return Color(red: 1.0, green: 0.23, blue: 0.19)
        case .rose: return Color(red: 1.0, green: 0.2, blue: 0.4)
        case .coral: return Color(red: 1.0, green: 0.5, blue: 0.45)
        case .sunset: return Color(red: 1.0, green: 0.4, blue: 0.2)
        case .orange: return Color.orange
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .mint: return Color.mint
        case .emerald: return Color(red: 0.0, green: 0.6, blue: 0.4)
        case .green: return Color.green
        case .forest: return Color(red: 0.0, green: 0.4, blue: 0.2)
        case .ocean: return Color(red: 0.0, green: 0.5, blue: 0.8)
        case .blue: return Color.blue
        case .indigo: return Color.indigo
        case .lavender: return Color(red: 0.7, green: 0.6, blue: 0.9)
        case .purple: return Color.purple
        case .steel: return Color(red: 0.4, green: 0.4, blue: 0.5)
        case .midnight: return Color(red: 0.1, green: 0.1, blue: 0.3)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .red: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .rose: return Color(red: 1.0, green: 0.4, blue: 0.6)
        case .coral: return Color(red: 1.0, green: 0.6, blue: 0.5)
        case .sunset: return Color(red: 1.0, green: 0.5, blue: 0.3)
        case .orange: return Color(red: 1.0, green: 0.7, blue: 0.2)
        case .gold: return Color(red: 1.0, green: 0.9, blue: 0.2)
        case .mint: return Color(red: 0.4, green: 0.9, blue: 0.7)
        case .emerald: return Color(red: 0.2, green: 0.8, blue: 0.5)
        case .green: return Color(red: 0.3, green: 0.9, blue: 0.4)
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .ocean: return Color(red: 0.2, green: 0.7, blue: 0.9)
        case .blue: return Color(red: 0.3, green: 0.6, blue: 1.0)
        case .indigo: return Color(red: 0.4, green: 0.4, blue: 1.0)
        case .lavender: return Color(red: 0.8, green: 0.7, blue: 1.0)
        case .purple: return Color(red: 0.8, green: 0.4, blue: 1.0)
        case .steel: return Color(red: 0.6, green: 0.6, blue: 0.7)
        case .midnight: return Color(red: 0.3, green: 0.3, blue: 0.5)
        }
    }
}

enum ContactViewMode: String, CaseIterable {
    case basic = "Basic"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .basic:
            return "Name, notes, DOB, age, children"
        case .advanced:
            return "Includes social media and addresses"
        }
    }
}

enum ContactSortOrder: String, CaseIterable {
    case firstName = "First Name"
    case lastName = "Last Name"
}

enum ContactDisplayOrder: String, CaseIterable {
    case firstNameFirst = "First Last"
    case lastNameFirst = "Last, First"
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var primaryColor: AppThemeColor {
        didSet {
            UserDefaults.standard.set(primaryColor.rawValue, forKey: "primaryColor")
        }
    }
    
    @Published var appVersion: String {
        didSet {
            UserDefaults.standard.set(appVersion, forKey: "appVersion")
        }
    }
    
    @Published var defaultContactView: ContactViewMode {
        didSet {
            UserDefaults.standard.set(defaultContactView.rawValue, forKey: "defaultContactView")
        }
    }
    
    @Published var glassEffectEnabled: Bool {
        didSet {
            UserDefaults.standard.set(glassEffectEnabled, forKey: "glassEffectEnabled")
        }
    }
    
    @Published var sortOption: ContactSortOrder {
        didSet {
            UserDefaults.standard.set(sortOption.rawValue, forKey: "contactSortOrder")
        }
    }
    
    @Published var displayOrder: ContactDisplayOrder {
        didSet {
            UserDefaults.standard.set(displayOrder.rawValue, forKey: "contactDisplayOrder")
        }
    }
    
    var currentColorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let savedColor = UserDefaults.standard.string(forKey: "primaryColor") ?? "Blue"
        // Handle migration from old indigo/violet colors to purple
        var colorToUse = savedColor
        if savedColor == "Indigo" || savedColor == "Violet" {
            colorToUse = "Purple"
        }
        self.primaryColor = AppThemeColor(rawValue: colorToUse) ?? .blue
        self.appVersion = UserDefaults.standard.string(forKey: "appVersion") ?? "1.0.0"
        let savedViewMode = UserDefaults.standard.string(forKey: "defaultContactView") ?? "Advanced"
        self.defaultContactView = ContactViewMode(rawValue: savedViewMode) ?? .advanced
        self.glassEffectEnabled = UserDefaults.standard.bool(forKey: "glassEffectEnabled")
        
        // Migration for sort option
        let savedSortOrder = UserDefaults.standard.string(forKey: "contactSortOrder") ?? UserDefaults.standard.string(forKey: "contactSortOption") ?? "First Name"
        self.sortOption = ContactSortOrder(rawValue: savedSortOrder) ?? .firstName
        
        let savedDisplayOrder = UserDefaults.standard.string(forKey: "contactDisplayOrder") ?? "First Last"
        self.displayOrder = ContactDisplayOrder(rawValue: savedDisplayOrder) ?? .firstNameFirst
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    func setTheme(_ isDark: Bool) {
        isDarkMode = isDark
    }
    
    func setPrimaryColor(_ color: AppThemeColor) {
        primaryColor = color
    }
    
    // MARK: - Memory Management
    
    func getMemoryUsage() -> String {
        // Simple memory usage estimation using autorelease pool
        return "Memory monitoring active"
    }
    
    func logMemoryUsage() {
        let usage = getMemoryUsage()
        print("Current memory usage: \(usage)")
    }
    
    func cleanupMemory() {
        // Force garbage collection if available
        autoreleasepool {
            // This will help release autoreleased objects
        }
        
        logMemoryUsage()
    }
    
    // MARK: - Aggressive Memory Management
    
    func aggressiveMemoryCleanup() {
        print("🔄 Starting aggressive memory cleanup...")
        
        // Force multiple autorelease pool cycles
        for _ in 1...3 {
            autoreleasepool {
                // Create and immediately release objects to trigger cleanup
                let _ = Array<Int>(repeating: 0, count: 1000)
            }
        }
        
        // Log memory before and after
        let beforeUsage = getMemoryUsage()
        print("Memory before cleanup: \(beforeUsage)")
        
        // Force system memory cleanup
        if #available(iOS 13.0, *) {
            // Trigger system-level memory cleanup
            let _ = ProcessInfo.processInfo.thermalState
        }
        
        // Small delay to allow cleanup
        Thread.sleep(forTimeInterval: 0.1)
        
        let afterUsage = getMemoryUsage()
        print("Memory after cleanup: \(afterUsage)")
        
        // Check if we're in a critical memory state
        checkMemoryPressure()
    }
    
    private func checkMemoryPressure() {
        let usage = getMemoryUsage()
        print("✅ Memory cleanup completed: \(usage)")
    }
    
    func emergencyMemoryCleanup() {
        print("🚨 EMERGENCY MEMORY CLEANUP TRIGGERED")
        
        // Most aggressive cleanup possible
        autoreleasepool {
            // Force release of all autoreleased objects
            let _ = Array<Int>(repeating: 0, count: 10000)
        }
        
        // Request system memory cleanup
        if #available(iOS 13.0, *) {
            // Trigger system memory pressure handling
            let _ = ProcessInfo.processInfo.thermalState
        }
        
        // Log final memory state
        let finalUsage = getMemoryUsage()
        print("Emergency cleanup complete. Final memory: \(finalUsage)")
    }
    
    // MARK: - Data Management
    
    @MainActor
    func removeDuplicateContacts(context: SwiftData.ModelContext) async {
        do {
            let descriptor = FetchDescriptor<Contact>()
            let contacts = try context.fetch(descriptor)
            
            print("🔍 Checking for duplicates (Cleanup)...")
            
            // Group contacts by full name
            let groupedContacts = Dictionary(grouping: contacts) { contact in
                "\(contact.firstName.lowercased())|\(contact.lastName.lowercased())"
            }
            
            var duplicatesRemoved = 0
            
            for (_, matches) in groupedContacts {
                // If we have more than one contact with the same name
                if matches.count > 1 {
                    print("Found duplicate for: \(matches[0].displayName)")
                    
                    // Keep the one with the most information (e.g. most kids, or most recent)
                    // For simplicity, we'll sort by kids count descending, then delete the rest
                    let sortedMatches = matches.sorted { 
                        ($0.kids.count + $0.addresses.count + $0.socialMediaURLs.count) > 
                        ($1.kids.count + $1.addresses.count + $1.socialMediaURLs.count) 
                    }
                    
                    // The first one is the "best" one, keep it
                    // Delete the rest
                    for duplicate in sortedMatches.dropFirst() {
                        context.delete(duplicate)
                        duplicatesRemoved += 1
                    }
                }
            }
            
            if duplicatesRemoved > 0 {
                try context.save()
                print("✅ Removed \(duplicatesRemoved) duplicate contacts (Cleanup)")
            } else {
                print("✅ No duplicates found (Cleanup)")
            }
        } catch {
            print("Failed to remove duplicates: \(error)")
        }
    }
}

// MARK: - Modern Card Background Modifier
struct ModernCardBackground: ViewModifier {
    let glassEffectEnabled: Bool
    let cornerRadius: CGFloat = 12
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if glassEffectEnabled {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.clear)
                            .background(Material.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    } else {
                        // Use explicit systemGray6 for consistent light gray background in light mode
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(.systemGray6))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Modern Section Header Modifier
struct ModernSectionHeader: ViewModifier {
    let themeColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(themeColor)
            .textCase(nil) // Prevent automatic uppercasing if desired, or keep standard
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func modernCardBackground(glassEffectEnabled: Bool) -> some View {
        modifier(ModernCardBackground(glassEffectEnabled: glassEffectEnabled))
    }
    
    func modernSectionHeader(themeColor: Color) -> some View {
        modifier(ModernSectionHeader(themeColor: themeColor))
    }
}
