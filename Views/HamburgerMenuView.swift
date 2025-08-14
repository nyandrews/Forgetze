import SwiftUI

struct HamburgerMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingPrivacyStatement = false
    @State private var showingAboutForgetze = false
    
    var body: some View {
        NavigationView {
            List {
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text(appSettings.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingAboutForgetze = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("About Forgetze")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.forgetze.com")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("www.forgetze.com")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section("Appearance") {
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.blue)
                        Text("Theme")
                        Spacer()
                        Picker("Theme", selection: $appSettings.isDarkMode) {
                            Text("Light").tag(false)
                            Text("Dark").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                    }
                }
                
                Section("Legal") {
                    Button(action: {
                        showingPrivacyStatement = true
                    }) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                            Text("Privacy Statement")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section("Support") {
                    Link(destination: URL(string: "mailto:support@forgetze.com")!) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("Contact Support")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
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
                }
            }
        }
        .sheet(isPresented: $showingPrivacyStatement) {
            PrivacyStatementView()
        }
        .sheet(isPresented: $showingAboutForgetze) {
            AboutForgetzeView()
        }
    }
}

#Preview {
    HamburgerMenuView()
        .environmentObject(AppSettings())
}
