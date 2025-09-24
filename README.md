# Forgetze - Never Forget a Name Again

Forgetze is a native iOS app built with SwiftUI that helps you remember people's names by storing and searching through detailed information about them. When you can't remember someone's name but remember specific details about them, Forgetze's powerful search functionality helps you find them instantly.

## Features

### 🧠 Smart Memory Management
- **Rich Contact Profiles**: Store comprehensive information about each person
- **Searchable Notes**: Add detailed notes about where you met, what they do, their interests, and more
- **Powerful Search**: Find contacts by searching through names, notes, children's names, social media, and other details

### 👥 Contact Information
Each contact includes:
- **Basic Info**: First name, last name, date of birth
- **Children**: Names and birth dates of their kids
- **Notes**: Detailed notes about the person (work, hobbies, where you met, etc.)
- **Social Media**: Links to top 10 social media platforms
- **Metadata**: Creation and update timestamps

### 🔍 Advanced Search
- **Real-time Search**: Search as you type
- **Multi-field Search**: Search across all contact information
- **Highlighted Results**: See exactly where your search terms match
- **Smart Filtering**: Results are automatically sorted and filtered

### 📱 Beautiful Native UI
- **Modern Design**: Clean, intuitive interface following iOS design guidelines
- **Responsive Layout**: Optimized for all iPhone and iPad screen sizes
- **iPad Optimized**: Split view navigation and two-column layouts for iPad
- **Smooth Animations**: Fluid transitions and interactions
- **Accessibility**: Full VoiceOver support and accessibility features

### 💾 Data Persistence & Privacy
- **Local Storage Only**: All data stored locally on device using UserDefaults
- **No Cloud Storage**: Data never leaves your device or is transmitted to external servers
- **No Data Collection**: We do not collect, track, or analyze your personal information
- **No Third-Party Services**: We do not use analytics, tracking, or advertising services
- **Automatic Saving**: Changes are saved automatically to your device
- **No Internet Required**: Works completely offline
- **Device Protected**: Data is protected by your device's security (Face ID, Touch ID, passcode)

### 🔐 Secure Sharing
- **Encrypted Contact Sharing**: Share contacts with AES-256 encryption
- **Password Protection**: Secure contacts with custom passwords
- **Multiple Sharing Methods**: Share via encrypted files or QR codes
- **Secure Import**: Import encrypted contacts from other devices
- **File Format**: Custom .forgetze encrypted file format
- **User-Controlled**: Data is only shared when you explicitly choose to do so
- **No Automatic Sharing**: We never automatically share or transmit your data

### 🎤 Siri Integration
- **Voice Commands**: Search contacts using natural language
- **Smart Search**: Find people by workplace, car, location, or any detail
- **Contact Management**: Add new contacts with voice commands
- **Information Retrieval**: Get detailed contact information hands-free
- **Siri Shortcuts**: Create custom shortcuts for frequent actions

## Supported Social Media Platforms

The app supports the top 10 most popular social media platforms:
- Facebook
- Instagram
- Twitter
- LinkedIn
- YouTube
- TikTok
- Snapchat
- WhatsApp
- Telegram
- Discord

## How to Use

### Getting Started
1. Launch the app to see demo contacts (clearly marked as demo data)
2. Tap the "+" button to add your own contacts
3. Fill in the person's information, especially detailed notes
4. Add their social media profiles if available
5. Demo contacts can be deleted to start fresh with your own data

### Secure Sharing
1. **Export Contacts Securely**:
   - Open a contact and tap the share button
   - Select "Secure Share (Encrypted)"
   - Set a strong password
   - Choose to create a file or generate a QR code
   
2. **Import Secure Contacts**:
   - Tap the menu button (⋯) in the top left
   - Select "Import Secure Contacts"
   - Choose to import from file or scan QR code
   - Enter the password to decrypt
   - Preview and select contacts to import

### Siri Voice Commands
1. **Search Contacts**:
   - "Hey Siri, search for someone who works at Google"
   - "Hey Siri, who drives a Tesla?"
   - "Hey Siri, find someone I met at the coffee shop"
   - "Hey Siri, who has a child named Emma?"

2. **Add Contacts**:
   - "Hey Siri, add John Smith to my contacts"
   - "Hey Siri, add a new contact named Sarah"

3. **Get Contact Information**:
   - "Hey Siri, tell me about Sarah Johnson"
   - "Hey Siri, what do I know about Michael Chen?"

### Adding Contacts
1. Tap the "+" button in the top right
2. Enter basic information (name, date of birth)
3. Add children's information if applicable
4. Add social media profiles
5. Write detailed notes about the person
6. Tap "Save"

### Searching for Contacts
1. Use the search bar at the top of the contact list
2. Type any detail you remember about the person:
   - Their name
   - Where they work
   - What car they drive
   - Where you met them
   - Their children's names
   - Social media platforms they use
   - Any other details from your notes

### Example Search Scenarios
- **"Tesla"** - Find someone who drives a Tesla
- **"Google"** - Find someone who works at Google
- **"coffee shop"** - Find someone you met at a coffee shop
- **"Emma"** - Find someone whose child is named Emma
- **"LinkedIn"** - Find someone who has a LinkedIn profile

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data binding
- **UserDefaults**: Local data persistence

### Security Features
- **AES-256 Encryption**: Military-grade encryption for contact data
- **PBKDF2 Key Derivation**: Secure password-based key derivation
- **Random Salt & IV**: Cryptographically secure random values
- **Secure File Format**: Custom .forgetze encrypted file format
- **QR Code Support**: Encrypted data sharing via QR codes
- **Local Storage Only**: All data stored locally on device
- **No Network Transmission**: Data never leaves device unless explicitly shared
- **Device Security**: Protected by iOS security measures and device authentication
- **No Data Collection**: We do not collect or track any user data
- **Minimal Permissions**: Only requests necessary permissions (Contacts for export, Camera for QR scanning)

### Siri Integration Features
- **Natural Language Processing**: Understands conversational queries
- **Intent Recognition**: Maps voice commands to app actions
- **Smart Search**: Searches across all contact fields
- **Voice Response**: Provides spoken feedback for actions
- **Shortcut Integration**: Works with iOS Shortcuts app

### Privacy & Data Handling
- **Complete Privacy**: Your data belongs to you and stays on your device
- **No Tracking**: We do not track your activity or collect usage data
- **No Analytics**: No analytics services or tracking libraries used
- **No Advertising**: No advertising networks or third-party tracking
- **Data Control**: Full control over your data - add, edit, delete, export at any time
- **Transparency**: Clear privacy policy and data handling information in-app
- **GDPR Compliant**: Meets privacy requirements with local-only storage

### File Structure
```
Forgetze/
├── Models/
│   ├── Contact.swift          # Contact data model
│   ├── ContactStore.swift     # Data management
│   ├── SampleData.swift       # Sample data for demo
│   └── SecureSharing.swift    # Encryption and secure sharing
├── Views/
│   ├── ContactListView.swift  # Main contact list
│   ├── ContactDetailView.swift # Contact details
│   ├── ContactEditView.swift  # Add/edit contacts
│   ├── SearchResultsView.swift # Search results
│   ├── SecureSharingView.swift # Secure sharing interface
│   ├── SecureImportView.swift # Secure import interface
│   ├── IPadMainView.swift     # iPad-optimized main view
│   └── WelcomeView.swift      # Onboarding
├── Intents/
│   ├── SearchContactsIntent.swift      # Siri search intent
│   ├── AddContactIntent.swift          # Siri add contact intent
│   ├── GetContactInfoIntent.swift      # Siri get info intent
│   ├── SiriIntegrationManager.swift    # Siri integration manager
│   └── ForgetzeIntents.intentdefinition # Siri intent definitions
├── ContentView.swift          # Main app view
└── ForgetzeApp.swift          # App entry point
```

### Data Models
- **Contact**: Main contact entity with all personal information
- **Kid**: Child information with name and birth date
- **SocialMediaURL**: Social media profile with platform and URL
- **SocialMediaPlatform**: Enum of supported platforms

## Requirements

- iOS 16.0 or later (for Siri integration)
- Xcode 14.0 or later
- Swift 5.7 or later

## iPad Support

Forgetze is fully optimized for iPad with the following features:

### 🖥️ iPad-Specific Features
- **Split View Navigation**: Master-detail interface with contact list and detail view side by side
- **Two-Column Layouts**: Optimized detail views that make better use of iPad screen real estate
- **Responsive Design**: Automatic layout switching between iPhone and iPad interfaces
- **Touch-Friendly**: Larger touch targets and improved spacing for iPad interaction
- **Landscape & Portrait**: Optimized for both orientations on iPad

### 📱 Universal App
- **Single App**: Works seamlessly on both iPhone and iPad
- **Adaptive UI**: Automatically adjusts layout based on device type
- **Consistent Experience**: Same features and functionality across all devices

## Installation

1. Clone the repository
2. Open `Forgetze.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

## Privacy

- All data is stored locally on your device
- No data is transmitted to external servers
- No analytics or tracking
- Complete privacy and control over your data

## Future Enhancements

Potential features for future versions:
- Cloud sync with iCloud
- Photo attachments
- Reminders and follow-ups
- Advanced search filters
- Dark mode optimizations
- Contact groups and tags
- Contact backup and restore

## Contributing

This is a personal project, but suggestions and feedback are welcome!

## License

This project is for educational and personal use.

---

**Forgetze** - Because sometimes you remember everything except the name! 🧠✨ 