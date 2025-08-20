import SwiftUI

struct SocialMediaCard: View {
    let url: String
    let themeColor: Color
    
    private var platformInfo: (name: String, icon: String, color: Color) {
        let lowercased = url.lowercased()
        
        if lowercased.contains("linkedin") {
            return ("LinkedIn", "linkedin", Color(red: 0.1, green: 0.6, blue: 0.9))
        } else if lowercased.contains("twitter") || lowercased.contains("x.com") {
            return ("Twitter", "bird", Color(red: 0.2, green: 0.6, blue: 1.0))
        } else if lowercased.contains("facebook") {
            return ("Facebook", "person.2", Color(red: 0.2, green: 0.4, blue: 0.8))
        } else if lowercased.contains("instagram") {
            return ("Instagram", "camera", Color(red: 0.8, green: 0.3, blue: 0.6))
        } else if lowercased.contains("github") {
            return ("GitHub", "chevron.left.forwardslash.chevron.right", Color(red: 0.2, green: 0.2, blue: 0.2))
        } else if lowercased.contains("youtube") {
            return ("YouTube", "play.rectangle", Color(red: 1.0, green: 0.0, blue: 0.0))
        } else if lowercased.contains("tiktok") {
            return ("TikTok", "music.note", Color(red: 0.0, green: 0.0, blue: 0.0))
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
                
                // Action indicator
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(themeColor)
                    .font(.title2)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(platformInfo.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        SocialMediaCard(url: "https://linkedin.com/in/johndoe", themeColor: .blue)
        SocialMediaCard(url: "https://twitter.com/johndoe", themeColor: .blue)
        SocialMediaCard(url: "https://instagram.com/johndoe", themeColor: .blue)
        SocialMediaCard(url: "https://github.com/johndoe", themeColor: .blue)
    }
    .padding()
}
