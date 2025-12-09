import SwiftUI

/**
 * Search Bar View
 * 
 * A comprehensive search bar component that integrates text search and voice search
 * functionality. This view provides a clean, accessible interface for users to
 * search through contacts using both text input and voice commands.
 * 
 * ## Features:
 * - Text search with real-time input
 * - Voice search button with recording states
 * - Accessibility support for screen readers
 * - Clean, modern design with proper spacing
 * 
 * ## Usage:
 * ```swift
 * SearchBarView(
 *     searchManager: searchManager,
 *     voiceSearchManager: voiceSearchManager
 * )
 * ```
 */
struct SearchBarView: View {
    @ObservedObject var searchManager: SearchManager
    @ObservedObject var voiceSearchManager: VoiceSearchManager
    @EnvironmentObject var appSettings: AppSettings
    let contacts: [Contact]
    
    var body: some View {
        HStack(spacing: 12) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            // Search text field
            TextField("", text: $searchManager.searchText, prompt: Text("Search for a contact by what you recall").foregroundColor(appSettings.primaryColor.color).bold())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body.weight(.bold)) // Bold text
                .foregroundColor(appSettings.primaryColor.color) // Match theme color
                .accentColor(appSettings.primaryColor.color) // Match cursor color
                .accessibilityIdentifier("searchTextField")
                .accessibilityLabel("Search contacts")
                .accessibilityHint("Type to search through your contacts")
            
            // Voice search button
            Button(action: {
                if voiceSearchManager.isRecording {
                    voiceSearchManager.stopVoiceSearch()
                } else {
                    voiceSearchManager.startVoiceSearch()
                }
            }) {
                Image(systemName: voiceSearchManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.title2)
                    .foregroundColor(voiceSearchManager.isRecording ? .red : appSettings.primaryColor.color)
                    .scaleEffect(voiceSearchManager.isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: voiceSearchManager.isRecording)
            }
            .accessibilityIdentifier("voiceSearchButton")
            .accessibilityLabel(voiceSearchManager.isRecording ? "Stop voice search" : "Start voice search")
            .accessibilityHint("Tap to search using your voice")
            .onChange(of: voiceSearchManager.isVoiceSearchComplete) { _, isComplete in
                if isComplete {
                    // Transfer transcribed text to search field
                    let transcribedText = voiceSearchManager.getTranscribedTextAndReset()
                    searchManager.searchText = transcribedText
                    // Trigger search with the transcribed text
                    searchManager.performSearch(in: contacts)
                }
            }
            
            // Clear button (only show when there's text)
            if !searchManager.searchText.isEmpty {
                Button(action: {
                    searchManager.reset()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .accessibilityIdentifier("clearSearchButton")
                .accessibilityLabel("Clear search")
                .accessibilityHint("Tap to clear the search text")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            // Bottom border
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

#Preview {
    SearchBarView(
        searchManager: SearchManager(),
        voiceSearchManager: VoiceSearchManager(),
        contacts: []
    )
    .padding()
}
