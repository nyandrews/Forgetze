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
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        HStack {
            HStack(alignment: .bottom, spacing: 12) {
                // Search text field constrained to match prompt text width exactly
                ZStack(alignment: .leading) {
                    Text("Search for a contact by what you recall")
                        .font(.body.weight(.bold))
                        .opacity(0)
                        .padding(.horizontal, 14) // Accounting for RoundedBorderTextFieldStyle padding
                    
                    TextField("", text: $searchManager.searchText, prompt: Text("Search for a contact by what you recall").foregroundColor(appSettings.primaryColor.color).bold())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body.weight(.bold))
                        .foregroundColor(appSettings.primaryColor.color)
                        .accentColor(appSettings.primaryColor.color)
                        .focused($isSearchFieldFocused)
                        .onChange(of: searchManager.searchText) { _, _ in
                            searchManager.performSearch(in: contacts)
                        }
                }
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityIdentifier("searchTextField")
                .accessibilityLabel("Search contacts")
                .accessibilityHint("Type to search through your contacts")
                
                // Keyboard toggle button (moved to replace magnifying glass)
                Button(action: {
                    isSearchFieldFocused = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [appSettings.primaryColor.color, appSettings.primaryColor.color.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: "keyboard")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: appSettings.primaryColor.color.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .accessibilityIdentifier("keyboardToggleButton")
                .accessibilityLabel("Toggle keyboard")
                .accessibilityHint("Tap to toggle the keyboard")
                
                // Voice search button
                Button(action: {
                    if voiceSearchManager.isRecording {
                        voiceSearchManager.stopVoiceSearch()
                    } else {
                        voiceSearchManager.startVoiceSearch()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        voiceSearchManager.isRecording ? Color.red : appSettings.primaryColor.color,
                                        (voiceSearchManager.isRecording ? Color.red : appSettings.primaryColor.color).opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: voiceSearchManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: (voiceSearchManager.isRecording ? Color.red : appSettings.primaryColor.color).opacity(0.3), radius: 2, x: 0, y: 1)
                    .scaleEffect(voiceSearchManager.isRecording ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: voiceSearchManager.isRecording)
                }
                .accessibilityIdentifier("voiceSearchButton")
                .accessibilityLabel(voiceSearchManager.isRecording ? "Stop voice search" : "Start voice search")
                .accessibilityHint("Tap to search using your voice")
                .onChange(of: voiceSearchManager.isVoiceSearchComplete) { _, isComplete in
                    if isComplete {
                        let transcribedText = voiceSearchManager.getTranscribedTextAndReset()
                        searchManager.searchText = transcribedText
                        searchManager.performSearch(in: contacts)
                    }
                }
                
                // Clear button
                if !searchManager.searchText.isEmpty {
                    Button(action: {
                        withAnimation(.spring()) {
                            searchManager.reset()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(appSettings.primaryColor.color.opacity(0.8))
                            .font(.system(size: 28, weight: .medium))
                    }
                    .accessibilityIdentifier("clearSearchButton")
                    .padding(.leading, 4)
                }
            }
            Spacer()
        }
        .padding(.leading, 20) // Line up with hamburger, contacts header and contacts list cards
        .padding(.trailing, 16)
        .padding(.top, 8)
        .padding(.bottom, 20) // Perfectly balanced with leading padding
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
