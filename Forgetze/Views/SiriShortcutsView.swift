import SwiftUI

struct SiriShortcutsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search by Memory")
                        .font(.headline)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    Text("Hey Siri, find by memory [what you remember] in Forgetze")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                    
                    Text("Example: \"Hey Siri, find by memory software engineer in Forgetze\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Notes")
                        .font(.headline)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    Text("Hey Siri, search notes for [what you remember] in Forgetze")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                    
                    Text("Example: \"Hey Siri, search notes for met at conference in Forgetze\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Label("VOICE COMMANDS", systemImage: "mic.fill")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("1.")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Open the Shortcuts app on your iPhone")
                            .font(.body)
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("2.")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Search for \"Forgetze\" to find available actions")
                            .font(.body)
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("3.")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Set up your custom voice commands")
                            .font(.body)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Label("SETUP INSTRUCTIONS", systemImage: "info.circle.fill")
            } footer: {
                Text("Note: Siri Shortcuts require iOS 16+ and may take a few minutes to appear in the Shortcuts app after installation.")
                    .padding(.top, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Siri Shortcuts")
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
}

#Preview {
    NavigationView {
        SiriShortcutsView()
            .environmentObject(AppSettings())
    }
}


