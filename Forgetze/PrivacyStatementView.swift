import SwiftUI

struct PrivacyStatementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Statement")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Data Collection")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Forgetze collects and stores contact information that you input, including names, birthdays, and notes. This data is stored locally on your device and optionally synced to iCloud if you enable CloudKit.")
                        
                        Text("Data Usage")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your contact data is used solely to provide the app's core functionality. We do not collect, analyze, or share your personal information with third parties.")
                        
                        Text("Data Storage")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("All data is stored locally on your device using Swift Data. If you enable CloudKit, your data is also stored securely in your iCloud account, protected by Apple's security measures.")
                        
                        Text("Data Sharing")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("We do not share your contact data with any third parties. Your data remains private and under your control.")
                        
                        Text("User Rights")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("You have full control over your data. You can export, delete, or modify your contacts at any time through the app's interface.")
                        
                        Text("Contact Information")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("If you have questions about this privacy statement, please contact us at support@forgetze.com")
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Statement")
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
    PrivacyStatementView()
}
