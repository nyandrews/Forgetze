import SwiftUI
import UIKit

struct HamburgerMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingPrivacyStatement = false
    @State private var showingAboutForgetze = false
    @State private var showingDataProtection = false
    
    var body: some View {
        NavigationView {
            List {
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
                        Menu {
                            ForEach(AppThemeColor.allCases, id: \.self) { color in
                                Button(action: {
                                    appSettings.primaryColor = color
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 16, height: 16)
                                        Text(color.rawValue)
                                            .foregroundColor(color.color) // Use the color itself, not the current theme
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(appSettings.primaryColor.rawValue)
                                    .foregroundColor(appSettings.primaryColor.color)
                                    .font(.body)
                                    .fontWeight(.medium) // Make it more prominent
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(appSettings.primaryColor.color)
                                    .font(.caption)
                            }
                        }
                        .accentColor(appSettings.primaryColor.color) // Force accent color
                    }
                }
                
                Section("CONTACT VIEW") {
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Default View")
                            .foregroundColor(appSettings.primaryColor.color)
                        Spacer()
                        Picker("View Mode", selection: $appSettings.defaultContactView) {
                            Text("Basic").tag(ContactViewMode.basic)
                            Text("Advanced").tag(ContactViewMode.advanced)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 140)
                    }
                    
                    Text("Basic: Name, notes, DOB, age, children. Advanced: Includes social media and addresses.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
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
                
                Section("SUPPORT") {
                    Button(action: {
                        if let url = URL(string: "mailto:support@forgetze.com") {
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
                

                
                // TODO: Uncomment when DataProtectionManager is added to Xcode project
                /*
                Section("🛡️ DATA PROTECTION") {
                    Button(action: {
                        showingDataProtection = true
                    }) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.green)
                            Text("Data Protection Status")
                                .foregroundColor(.green)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "archivebox")
                            .foregroundColor(.blue)
                        Text("Backup Status")
                        Spacer()
                        Text("0 backups")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                */
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
        // TODO: Uncomment when DataProtectionStatusView is added to Xcode project
        /*
        .sheet(isPresented: $showingDataProtection) {
            DataProtectionStatusView()
        }
        */
    }
}

#Preview {
    HamburgerMenuView()
        .environmentObject(AppSettings())
}
