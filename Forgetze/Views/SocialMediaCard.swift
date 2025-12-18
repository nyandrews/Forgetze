import SwiftUI

struct SocialMediaCard: View {
    let url: String
    let themeColor: Color
    let onDelete: (() -> Void)?
    @EnvironmentObject var appSettings: AppSettings
    
    private var platformInfo: (name: String, icon: String, color: Color) {
        let lowercased = url.lowercased()
        
        if lowercased.contains("linkedin") {
            // "linkedin" is not a valid SF Symbol. Using "briefcase.fill" as a professional networking proxy.
            return ("LinkedIn", "briefcase.fill", Color(red: 0.0, green: 0.47, blue: 0.71))
        } else if lowercased.contains("twitter") || lowercased.contains("x.com") {
            // "bird" is not a valid SF Symbol. Using "at" or "bubble.left" as proxy.
            return ("X (Twitter)", "at", Color(red: 0.0, green: 0.0, blue: 0.0))
        } else if lowercased.contains("facebook") {
            return ("Facebook", "person.2.fill", Color(red: 0.2, green: 0.4, blue: 0.8))
        } else if lowercased.contains("instagram") {
            return ("Instagram", "camera.fill", Color(red: 0.8, green: 0.3, blue: 0.6))
        } else if lowercased.contains("github") {
            return ("GitHub", "terminal.fill", Color(red: 0.2, green: 0.2, blue: 0.2))
        } else if lowercased.contains("youtube") {
            return ("YouTube", "play.rectangle.fill", Color(red: 1.0, green: 0.0, blue: 0.0))
        } else if lowercased.contains("tiktok") {
            return ("TikTok", "music.note", Color(red: 0.0, green: 0.0, blue: 0.0))
        } else if lowercased.contains("snapchat") {
             return ("Snapchat", "message.fill", Color(red: 1.0, green: 1.0, blue: 0.0))
        } else {
            return ("Social Media", "link", themeColor)
        }
    }
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                // Platform icon with background
                ZStack {
                    Circle()
                        .fill(platformInfo.color)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: platformInfo.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(platformInfo.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                    
                    Text(url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                // Delete button
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Action indicator
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(themeColor)
                    .font(.title2)
            }
            .padding()
            .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        SocialMediaCard(url: "https://linkedin.com/in/johndoe", themeColor: .blue, onDelete: {})
        SocialMediaCard(url: "https://twitter.com/johndoe", themeColor: .blue, onDelete: {})
        SocialMediaCard(url: "https://instagram.com/johndoe", themeColor: .blue, onDelete: {})
        SocialMediaCard(url: "https://github.com/johndoe", themeColor: .blue, onDelete: {})
    }
    .environmentObject(AppSettings())
    .padding()
}
