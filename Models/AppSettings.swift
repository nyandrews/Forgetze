import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
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
        self.appVersion = UserDefaults.standard.string(forKey: "appVersion") ?? "1.0.0"
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    func setTheme(_ isDark: Bool) {
        isDarkMode = isDark
    }
}
