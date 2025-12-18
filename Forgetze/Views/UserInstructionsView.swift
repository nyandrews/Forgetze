import SwiftUI

struct UserInstructionsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Welcome
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to Forgetze")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    Text("\"Never forget a person's name ever again.\"")
                        .font(.title3)
                        .italic()
                        .foregroundColor(.secondary)
                    
                    Text("Forgetze is your personal relationship manager, designed to help you keep track of the important people in your life—their birthdays, families, and milestones.")
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - Home Screen
                VStack(alignment: .leading, spacing: 16) {
                    Text("🏠 at a Glance")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("The Home Screen is your command center. It gives you a clean, sorted list of everyone you care about.")
                        .padding(.horizontal)
                    
                    Image("forgetze_home_screen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        featureBullet(icon: "magnifyingglass", title: "Search", desc: "Tap the search bar or use the microphone to find people instantly.")
                        featureBullet(icon: "plus.circle.fill", title: "Add Contact", desc: "Tap the big blue + button to add someone new.")
                        featureBullet(icon: "list.bullet", title: "Quick Details", desc: "See names, birthdays, and key info right from the list.")
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - Adding & Editing
                VStack(alignment: .leading, spacing: 16) {
                    Text("✏️ Adding & Editing")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Adding a contact is simple but powerful. You can track as little or as much as you want.")
                        .padding(.horizontal)
                    
                    Image("forgetze_edit_contact")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {

                        
                        Text("Family Tracking")
                            .font(.headline)
                            .padding(.top, 4)
                        featureBullet(icon: "heart.fill", title: "Spouse", desc: "Add their partner's name and birthday.")
                        featureBullet(icon: "figure.2.and.child.holdinghands", title: "Children", desc: "Track names and ages so you never forget.")
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - Comprehensive Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("📋 Comprehensive Details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Tap any contact to see their full profile.")
                        .padding(.horizontal)
                    
                    Image("forgetze_contact_detail")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        featureBullet(icon: "person.text.rectangle", title: "Personal Info", desc: "Birthday, Age, and Next Birthday countdown.")
                        featureBullet(icon: "person.2.fill", title: "Family", desc: "Dedicated section for spouse and children.")
                        featureBullet(icon: "note.text", title: "Notes", desc: "A place for those little things you want to remember.")
                        featureBullet(icon: "link", title: "Social", desc: "One-tap links to their social profiles.")
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - Data Protection
                VStack(alignment: .leading, spacing: 16) {
                    Text("🛡️ Data Protection")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("We take your data seriously. Forgetze includes an industrial-strength Data Protection System.")
                        .padding(.horizontal)
                    
                    Image("forgetze_data_protection")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        featureBullet(icon: "arrow.clockwise", title: "Automatic Backups", desc: "Backups created instantly on every save or delete.")
                        featureBullet(icon: "stethoscope", title: "Health Check", desc: "Diagnostic scan to ensure data integrity.")
                        featureBullet(icon: "exclamationmark.shield", title: "Emergency Recovery", desc: "One tap restores your data to the last safe state.")
                    }
                    .padding(.horizontal)
                }
                
                // Bottom Spacing
                Color.clear.frame(height: 40)
            }
            .padding(.top)
        }
        .navigationTitle("User Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func featureBullet(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(appSettings.primaryColor.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(appSettings.primaryColor.color)
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        UserInstructionsView()
            .environmentObject(AppSettings())
    }
}


