import Foundation
import SwiftUI

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
    
    var currentColorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let savedColor = UserDefaults.standard.string(forKey: "primaryColor") ?? "Blue"
        self.primaryColor = AppThemeColor(rawValue: savedColor) ?? .blue
        self.appVersion = UserDefaults.standard.string(forKey: "appVersion") ?? "1.0.0"
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
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Float(info.resident_size) / 1024.0 / 1024.0
            return String(format: "%.1f MB", usedMB)
        } else {
            return "Unknown"
        }
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
}
