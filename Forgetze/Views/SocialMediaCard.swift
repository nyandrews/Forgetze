import SwiftUI

struct SocialMediaCard: View {
    let url: String
    let themeColor: Color
    let onTap: () -> Void
    
    private var platformInfo: SocialMediaPlatform {
        SocialMediaPlatform.detect(from: url)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Platform Icon
                Image(systemName: platformInfo.iconName)
                    .font(.title2)
                    .foregroundColor(platformInfo.iconColor)
                    .frame(width: 24, height: 24)
                
                // Platform Name and URL
                VStack(alignment: .leading, spacing: 2) {
                    Text(platformInfo.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(url)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                // External Link Icon
                Image(systemName: "arrow.up.right.square")
                    .font(.title3)
                    .foregroundColor(themeColor)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(platformInfo.borderColor, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Social Media Platform Detection

struct SocialMediaPlatform {
    let name: String
    let displayName: String
    let iconName: String
    let iconColor: Color
    let borderColor: Color
    let urlPatterns: [String]
    
    static func detect(from url: String) -> SocialMediaPlatform {
        let lowercasedURL = url.lowercased()
        
        for platform in allPlatforms {
            for pattern in platform.urlPatterns {
                if lowercasedURL.contains(pattern) {
                    return platform
                }
            }
        }
        
        return .generic
    }
    
    static let allPlatforms: [SocialMediaPlatform] = [
        .facebook,
        .instagram,
        .twitter,
        .linkedin,
        .youtube,
        .tiktok,
        .snapchat,
        .whatsapp,
        .telegram,
        .discord,
        .reddit,
        .pinterest,
        .github,
        .spotify,
        .twitch,
        .generic
    ]
    
    // MARK: - Platform Definitions
    
    static let facebook = SocialMediaPlatform(
        name: "facebook",
        displayName: "Facebook",
        iconName: "person.2.circle.fill",
        iconColor: Color(red: 66/255, green: 103/255, blue: 178/255),
        borderColor: Color(red: 66/255, green: 103/255, blue: 178/255).opacity(0.3),
        urlPatterns: ["facebook.com", "fb.com"]
    )
    
    static let instagram = SocialMediaPlatform(
        name: "instagram",
        displayName: "Instagram",
        iconName: "camera.circle.fill",
        iconColor: Color(red: 225/255, green: 48/255, blue: 108/255),
        borderColor: Color(red: 225/255, green: 48/255, blue: 108/255).opacity(0.3),
        urlPatterns: ["instagram.com", "ig.com"]
    )
    
    static let twitter = SocialMediaPlatform(
        name: "twitter",
        displayName: "Twitter",
        iconName: "bird.fill",
        iconColor: Color(red: 29/255, green: 161/255, blue: 242/255),
        borderColor: Color(red: 29/255, green: 161/255, blue: 242/255).opacity(0.3),
        urlPatterns: ["twitter.com", "x.com", "t.co"]
    )
    
    static let linkedin = SocialMediaPlatform(
        name: "linkedin",
        displayName: "LinkedIn",
        iconName: "briefcase.circle.fill",
        iconColor: Color(red: 0/255, green: 119/255, blue: 181/255),
        borderColor: Color(red: 0/255, green: 119/255, blue: 181/255).opacity(0.3),
        urlPatterns: ["linkedin.com", "lnkd.in"]
    )
    
    static let youtube = SocialMediaPlatform(
        name: "youtube",
        displayName: "YouTube",
        iconName: "play.rectangle.fill",
        iconColor: Color(red: 255/255, green: 0/255, blue: 0/255),
        borderColor: Color(red: 255/255, green: 0/255, blue: 0/255).opacity(0.3),
        urlPatterns: ["youtube.com", "youtu.be"]
    )
    
    static let tiktok = SocialMediaPlatform(
        name: "tiktok",
        displayName: "TikTok",
        iconName: "music.note",
        iconColor: Color.black,
        borderColor: Color.black.opacity(0.3),
        urlPatterns: ["tiktok.com"]
    )
    
    static let snapchat = SocialMediaPlatform(
        name: "snapchat",
        displayName: "Snapchat",
        iconName: "ghost.fill",
        iconColor: Color.yellow,
        borderColor: Color.yellow.opacity(0.3),
        urlPatterns: ["snapchat.com", "snapchat"]
    )
    
    static let whatsapp = SocialMediaPlatform(
        name: "whatsapp",
        displayName: "WhatsApp",
        iconName: "message.circle.fill",
        iconColor: Color(red: 37/255, green: 211/255, blue: 102/255),
        borderColor: Color(red: 37/255, green: 211/255, blue: 102/255).opacity(0.3),
        urlPatterns: ["wa.me", "whatsapp.com"]
    )
    
    static let telegram = SocialMediaPlatform(
        name: "telegram",
        displayName: "Telegram",
        iconName: "paperplane.circle.fill",
        iconColor: Color(red: 0/255, green: 136/255, blue: 204/255),
        borderColor: Color(red: 0/255, green: 136/255, blue: 204/255).opacity(0.3),
        urlPatterns: ["t.me", "telegram.org"]
    )
    
    static let discord = SocialMediaPlatform(
        name: "discord",
        displayName: "Discord",
        iconName: "gamecontroller.fill",
        iconColor: Color(red: 114/255, green: 137/255, blue: 218/255),
        borderColor: Color(red: 114/255, green: 137/255, blue: 218/255).opacity(0.3),
        urlPatterns: ["discord.com", "discord.gg"]
    )
    
    static let reddit = SocialMediaPlatform(
        name: "reddit",
        displayName: "Reddit",
        iconName: "bubble.left.and.bubble.right.fill",
        iconColor: Color(red: 255/255, green: 69/255, blue: 0/255),
        borderColor: Color(red: 255/255, green: 69/255, blue: 0/255).opacity(0.3),
        urlPatterns: ["reddit.com", "redd.it"]
    )
    
    static let pinterest = SocialMediaPlatform(
        name: "pinterest",
        displayName: "Pinterest",
        iconName: "pin.circle.fill",
        iconColor: Color(red: 189/255, green: 8/255, blue: 28/255),
        borderColor: Color(red: 189/255, green: 8/255, blue: 28/255).opacity(0.3),
        urlPatterns: ["pinterest.com", "pin.it"]
    )
    
    static let github = SocialMediaPlatform(
        name: "github",
        displayName: "GitHub",
        iconName: "chevron.left.forwardslash.chevron.right",
        iconColor: Color.black,
        borderColor: Color.black.opacity(0.3),
        urlPatterns: ["github.com"]
    )
    
    static let spotify = SocialMediaPlatform(
        name: "spotify",
        displayName: "Spotify",
        iconName: "music.note.list",
        iconColor: Color(red: 30/255, green: 215/255, blue: 96/255),
        borderColor: Color(red: 30/255, green: 215/255, blue: 96/255).opacity(0.3),
        urlPatterns: ["spotify.com", "open.spotify.com"]
    )
    
    static let twitch = SocialMediaPlatform(
        name: "twitch",
        displayName: "Twitch",
        iconName: "tv.fill",
        iconColor: Color(red: 100/255, green: 65/255, blue: 164/255),
        borderColor: Color(red: 100/255, green: 65/255, blue: 164/255).opacity(0.3),
        urlPatterns: ["twitch.tv"]
    )
    
    static let generic = SocialMediaPlatform(
        name: "generic",
        displayName: "Social Media",
        iconName: "link.circle.fill",
        iconColor: Color.gray,
        borderColor: Color.gray.opacity(0.3),
        urlPatterns: []
    )
}

#Preview {
    VStack(spacing: 16) {
        SocialMediaCard(url: "https://facebook.com/johndoe", themeColor: .blue) {
            print("Facebook tapped")
        }
        
        SocialMediaCard(url: "https://instagram.com/johndoe", themeColor: .blue) {
            print("Instagram tapped")
        }
        
        SocialMediaCard(url: "https://linkedin.com/in/johndoe", themeColor: .blue) {
            print("LinkedIn tapped")
        }
        
        SocialMediaCard(url: "https://example.com/profile", themeColor: .blue) {
            print("Generic tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
