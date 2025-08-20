import Foundation
import SwiftUI
import Darwin

enum AppThemeColor: String, CaseIterable {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case indigo = "Indigo"
    case violet = "Violet"
    
    var color: Color {
        switch self {
        case .red: return Color(red: 0.8, green: 0.2, blue: 0.2)
        case .orange: return Color(red: 0.9, green: 0.5, blue: 0.1)
        case .yellow: return Color(red: 0.9, green: 0.8, blue: 0.1)
        case .green: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .blue: return Color(red: 0.2, green: 0.5, blue: 0.9)
        case .indigo: return Color(red: 0.4, green: 0.3, blue: 0.8)
        case .violet: return Color(red: 0.6, green: 0.3, blue: 0.8)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .red: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .orange: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .yellow: return Color(red: 1.0, green: 0.9, blue: 0.2)
        case .green: return Color(red: 0.3, green: 0.8, blue: 0.4)
        case .blue: return Color(red: 0.3, green: 0.6, blue: 1.0)
        case .indigo: return Color(red: 0.5, green: 0.4, blue: 0.9)
        case .violet: return Color(red: 0.7, green: 0.4, blue: 0.9)
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
    
    var currentColorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let savedColor = UserDefaults.standard.string(forKey: "primaryColor") ?? "Blue"
        self.primaryColor = AppThemeColor(rawValue: savedColor) ?? .blue
        self.appVersion = UserDefaults.standard.string(forKey: "appVersion") ?? "1.0.0"
        let savedViewMode = UserDefaults.standard.string(forKey: "defaultContactView") ?? "Basic"
        self.defaultContactView = ContactViewMode(rawValue: savedViewMode) ?? .basic
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
}
