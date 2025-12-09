import SwiftUI

struct UserInstructionsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome
                Group {
                    Text("Welcome to Forgetze")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    Text("Forgetze helps you remember a person's name by storing little details that matter most. Never forget a name again.")
                        .font(.body)
                }
                
                Divider()
                
                // Getting Started
                Group {
                    Text("Getting Started")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        instructionRow(text: "Tap the + Add Contact button in the top-right corner")
                        instructionRow(text: "Enter at least one name (first or last)")
                        instructionRow(text: "Add notes about how you know them")
                        instructionRow(text: "Include birthdays, family members, addresses and social media links")
                    }
                }
                
                Divider()
                
                // Finding Contacts
                Group {
                    Text("Finding Contacts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        instructionRow(text: "Use the search bar at the top")
                        instructionRow(text: "Search by name, notes, or any detail you remember")
                        instructionRow(text: "Try searching for: 'met at conference', 'lives in Seattle', 'has blue car'")
                        instructionRow(text: "Use Siri shortcuts for hands-free searching")
                    }
                }
                
                Divider()
                
                // Editing Contacts
                Group {
                    Text("Editing Contacts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        instructionRow(text: "Tap any contact to view their details")
                        instructionRow(text: "Tap the three-dot menu (⋮) to edit")
                        instructionRow(text: "Add or edit addresses, social media, and family")
                        instructionRow(text: "Share individual addresses or social media")
                    }
                }
                
                Divider()
                
                // Pro Tips
                Group {
                    Text("Pro Tips")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        proTipRow(text: "Include context clues: where you met, mutual friends, shared interests")
                        proTipRow(text: "Add family members (children need at least one name) and their relationships to build a complete picture")
                        proTipRow(text: "Use the voice search feature for quick hands-free lookups")
                    }
                }
                
                Divider()
                
                // Privacy
                Group {
                    Text("Privacy & Security")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        instructionRow(text: "All data is stored locally on your device")
                        instructionRow(text: "Optional iCloud sync keeps your data backed up")
                        instructionRow(text: "No data is shared with third parties")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Instructions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func instructionRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .fontWeight(.bold)
                .foregroundColor(appSettings.primaryColor.color)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func proTipRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("💡")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .font(.callout)
                .italic()
        }
    }
}

#Preview {
    NavigationView {
        UserInstructionsView()
            .environmentObject(AppSettings())
    }
}


