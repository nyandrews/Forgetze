import Foundation
import SwiftUI
import SwiftData

public enum AppThemeColor: String, CaseIterable {
    case merlot = "Merlot"     // Sophisticated Deep Red
    case red = "Red"           // LEGO Red
    case coral = "Coral"
    case orange = "Orange"     // LEGO Orange
    case amber = "Amber"       // Enhanced Gold
    case sunshine = "Sunshine" // LEGO Yellow #FFD700
    case green = "Green"       // Refined Emerald Pigment
    case pine = "Pine"         // Deep Organic Green
    case teal = "Teal"         // Vibrant Blue-Green
    case blue = "Blue"         // LEGO Blue
    case purple = "Purple"     // LEGO Purple
    case sand = "Sand"         // Warm Luxury Neutral
    case slate = "Slate"       // Refined Steel
    case midnight = "Midnight" // Intensely Blue Deep Navy
    case charcoal = "Charcoal"
    case jet = "Jet"           // True OLED Black
    
    public var color: Color {
        switch self {
        case .merlot: return Color(red: 0.5, green: 0.05, blue: 0.1)
        case .red: return Color(red: 0.85, green: 0.16, blue: 0.11) // LEGO Red #DA291C
        case .coral: return Color(red: 1.0, green: 0.5, blue: 0.45)
        case .orange: return Color(red: 1.0, green: 0.58, blue: 0.13) // LEGO Orange #FF9320
        case .amber: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .sunshine: return Color(red: 1.0, green: 0.84, blue: 0.0) // LEGO Yellow #FFD700
        case .green: return Color(red: 0.0, green: 0.6, blue: 0.4) // Emerald refinement
        case .pine: return Color(red: 0.05, green: 0.35, blue: 0.25)
        case .teal: return Color(red: 0.0, green: 0.5, blue: 0.5)
        case .blue: return Color(red: 0.09, green: 0.45, blue: 0.74) // LEGO Blue #1873BC
        case .purple: return Color(red: 0.51, green: 0.0, blue: 0.48) // LEGO Purple #81007B
        case .sand: return Color(red: 0.89, green: 0.85, blue: 0.79) // Warm Sand
        case .slate: return Color(red: 0.44, green: 0.5, blue: 0.56)
        case .midnight: return Color(red: 0.05, green: 0.15, blue: 0.55)
        case .charcoal: return Color(red: 0.2, green: 0.2, blue: 0.25)
        case .jet: return .black // True OLED Black
        }
    }
    
    public var accentColor: Color {
        // Professional Hue-Shifting for gradients
        switch self {
        case .merlot: return Color(red: 0.7, green: 0.1, blue: 0.2)
        case .red: return Color(red: 1.0, green: 0.3, blue: 0.25)
        case .coral: return Color(red: 1.0, green: 0.65, blue: 0.5)
        case .orange: return Color(red: 1.0, green: 0.75, blue: 0.3)
        case .amber: return Color(red: 1.0, green: 0.85, blue: 0.3)
        case .sunshine: return Color(red: 1.0, green: 0.95, blue: 0.4) // Bright Sunshine
        case .green: return Color(red: 0.1, green: 0.8, blue: 0.5)
        case .pine: return Color(red: 0.1, green: 0.5, blue: 0.4)
        case .teal: return Color(red: 0.2, green: 0.7, blue: 0.8)
        case .blue: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .purple: return Color(red: 0.7, green: 0.45, blue: 0.75)
        case .sand: return Color(red: 0.95, green: 0.92, blue: 0.88) // Lighter Sand
        case .slate: return Color(red: 0.6, green: 0.65, blue: 0.7)
        case .midnight: return Color(red: 0.2, green: 0.5, blue: 0.9)
        case .charcoal: return Color(red: 0.4, green: 0.4, blue: 0.45)
        case .jet: return Color(red: 0.2, green: 0.2, blue: 0.2) // Stealth Gray Shift
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
    
    @Published var appVersion: String
    

    
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
        
        // Migration logic for "Premium 12" palette consolidation
        var colorToUse = savedColor
        let migrationMap = [
            "Indigo": "Purple",
            "Violet": "Purple",
            "Lavender": "Purple",
            "Royal Purple": "Purple",
            "Purple": "Purple",
            "Rose": "Red",
            "Mint": "Green",
            "Ocean": "Blue",
            "Emerald": "Green",
            "Forest": "Green",
            "Gold": "Amber",
            "Steel": "Slate",
            "Sunset": "Orange"
        ]
        
        if let migrated = migrationMap[savedColor] {
            colorToUse = migrated
        }
        
        self.primaryColor = AppThemeColor(rawValue: colorToUse) ?? .blue
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        self.appVersion = version
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
    
    // Memory management methods have been removed as they were providing no benefit and potentially causing overhead.
    // The system (ARC and OS memory management) handles this automatically.

    
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
public struct ModernCardBackground: ViewModifier {
    public let glassEffectEnabled: Bool
    public let cornerRadius: CGFloat = 12
    @Environment(\.colorScheme) var colorScheme
    
    public init(glassEffectEnabled: Bool) {
        self.glassEffectEnabled = glassEffectEnabled
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if glassEffectEnabled {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.clear)
                            .background(Material.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(.systemGray6))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Modern Section Header Modifier
public struct ModernSectionHeader: ViewModifier {
    public let themeColor: Color
    
    public init(themeColor: Color) {
        self.themeColor = themeColor
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(themeColor)
            .textCase(nil)
    }
}

// MARK: - View Extension for Easy Access
public extension View {
    func modernCardBackground(glassEffectEnabled: Bool) -> some View {
        modifier(ModernCardBackground(glassEffectEnabled: glassEffectEnabled))
    }
    
    func modernSectionHeader(themeColor: Color) -> some View {
        modifier(ModernSectionHeader(themeColor: themeColor))
    }
}
