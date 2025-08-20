import SwiftUI

struct AboutForgetzeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("About Forgetze")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("What is Forgetze?")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Forgetze is a modern, privacy-focused contacts app designed to help you remember the important details about the people in your life. Whether it's birthdays, anniversaries, or just notes about your contacts, Forgetze keeps everything organized and accessible.")
                        
                        Text("Key Features")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "person.2", text: "Contact Management", color: appSettings.primaryColor.color)
                            FeatureRow(icon: "gift", text: "Birthday Tracking", color: appSettings.primaryColor.color)
                            FeatureRow(icon: "person.3", text: "Family & Children", color: appSettings.primaryColor.color)
                            FeatureRow(icon: "note.text", text: "Notes & Groups", color: appSettings.primaryColor.color)
                            FeatureRow(icon: "icloud", text: "iCloud Sync", color: appSettings.primaryColor.color)
                            FeatureRow(icon: "paintbrush", text: "Light & Dark Themes", color: appSettings.primaryColor.color)
                        }
                        
                        Text("Our Mission")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("We believe that personal relationships are the foundation of a meaningful life. Forgetze helps you nurture these relationships by ensuring you never forget the important details about the people who matter most.")
                        
                        Text("Privacy First")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your data belongs to you. Forgetze stores all information locally on your device and optionally syncs to your personal iCloud account. We never access, analyze, or share your personal information.")
                        
                        Text("Contact Us")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Website: www.forgetze.com\nEmail: support@forgetze.com")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("About")
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

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    AboutForgetzeView()
        .environmentObject(AppSettings())
}
