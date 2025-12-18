import SwiftUI
import UIKit

struct HamburgerMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingPrivacyStatement = false
    @State private var showingAboutForgetze = false
    @State private var showingDataProtection = false
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            List {
                // 1. Contact View Settings (Most Functional)
                Section("CONTACT VIEW") {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Sort By")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Picker("Sort By", selection: $appSettings.sortOption) {
                            Text("First Name").tag(ContactSortOrder.firstName)
                            Text("Last Name").tag(ContactSortOrder.lastName)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 180)
                    }
                    
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Display Name")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Picker("Display Name", selection: $appSettings.displayOrder) {
                            Text("First Last").tag(ContactDisplayOrder.firstNameFirst)
                            Text("Last, First").tag(ContactDisplayOrder.lastNameFirst)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 180)
                    }
                    

                }
                
                // 2. Appearance
                Section("APPEARANCE") {
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Theme")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Picker("Theme", selection: $appSettings.isDarkMode) {
                            Text("Light").tag(false)
                            Text("Dark").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Image(systemName: "paintpalette")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Theme Color")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        
                        Button(action: {
                            showingColorPicker = true
                        }) {
                            HStack(spacing: 8) {
                                Text(appSettings.primaryColor.rawValue)
                                    .foregroundColor(appSettings.primaryColor.color)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(appSettings.primaryColor.color)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // 3. Help (Instructions)
                Section("HELP") {
                    NavigationLink(destination: UserInstructionsView()) {
                        HStack {
                            Image(systemName: "book")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("User Guide")
                                .foregroundColor(appSettings.primaryColor.color)
                        }
                    }
                }
                
                // 4. Voice Control
                Section("VOICE CONTROL") {
                    NavigationLink(destination: SiriShortcutsView()) {
                        HStack {
                            Image(systemName: "mic.circle")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Siri Shortcuts")
                                .foregroundColor(appSettings.primaryColor.color)
                        }
                    }
                }
                
                // 5. Data Protection
                Section("DATA PROTECTION") {
                    Button(action: {
                        showingDataProtection = true
                    }) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Data Protection Status")
                                .foregroundColor(appSettings.primaryColor.color)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("iCloud Sync")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Text("Active")
                            .foregroundColor(appSettings.primaryColor.color)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "archivebox")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Backup Status")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Text("Active")
                            .foregroundColor(appSettings.primaryColor.color)
                            .font(.caption)
                    }
                }
                
                // 6. Support
                Section("SUPPORT") {
                    Button(action: {
                        if let url = URL(string: "mailto:hello@forgetze.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Contact Support")
                                .foregroundColor(appSettings.primaryColor.color)
                                .font(.body)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 7. App Information
                Section("APP INFORMATION") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Version")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Text(appSettings.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingAboutForgetze = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("About Forgetze")
                                .foregroundColor(appSettings.primaryColor.color)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.forgetze.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("www.forgetze.com")
                                .foregroundColor(appSettings.primaryColor.color)
                                .font(.body)
                                .fontWeight(.medium)
                                .underline()
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 8. Legal
                Section("LEGAL") {
                    Button(action: {
                        showingPrivacyStatement = true
                    }) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(appSettings.primaryColor.color)
                            Text("Privacy Statement")
                                .foregroundColor(appSettings.primaryColor.color)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                }
            }
        }
        .sheet(isPresented: $showingPrivacyStatement) {
            PrivacyStatementView()
        }
        .sheet(isPresented: $showingAboutForgetze) {
            AboutForgetzeView()
        }
        .sheet(isPresented: $showingDataProtection) {
            DataProtectionStatusView()
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(selectedColor: $appSettings.primaryColor)
        }
    }
}

// MARK: - Custom Color Picker Sheet
struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: AppThemeColor
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AppThemeColor.allCases, id: \.self) { color in
                    Button(action: {
                        selectedColor = color
                        dismiss()
                    }) {
                        HStack {
                            Circle()
                            .fill(color.color)
                            .frame(width: 20, height: 20)
                            Text(color.rawValue)
                                .foregroundColor(color.color)
                                .fontWeight(.medium)
                            Spacer()
                            if color == selectedColor {
                                Image(systemName: "checkmark")
                                    .foregroundColor(color.color)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Choose Theme Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HamburgerMenuView()
        .environmentObject(AppSettings())
}
