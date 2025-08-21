import SwiftUI

struct SearchBarView: View {
    @ObservedObject var searchManager: SearchManager
    @ObservedObject var voiceSearchManager: VoiceSearchManager
    @EnvironmentObject var appSettings: AppSettings
    let contacts: [Contact]
    

    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
                                TextField("Can't remember a name? Search by what you recall...", text: $searchManager.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Voice search button
            Button(action: {
                print("🎤 Voice search button tapped, current state: \(voiceSearchManager.isRecording ? "recording" : "not recording")")
                if voiceSearchManager.isRecording {
                    print("🛑 Stopping voice search...")
                    voiceSearchManager.stopVoiceSearch()
                } else {
                    print("▶️ Starting voice search...")
                    voiceSearchManager.startVoiceSearch()
                }
            }) {
                Image(systemName: voiceSearchManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .foregroundColor(voiceSearchManager.isRecording ? .red : appSettings.primaryColor.color)
                    .font(.title2)
                    .scaleEffect(voiceSearchManager.isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: voiceSearchManager.isRecording)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("voiceSearchButton")
            .accessibilityLabel(voiceSearchManager.isRecording ? "Stop voice search" : "Start voice search")
            
                                if !searchManager.searchText.isEmpty {
                        Button(action: {
                            searchManager.reset()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .onChange(of: searchManager.searchText) { _, newText in
            print("🔍 Search text changed to: '\(newText)'")
            // Trigger search when text changes
            searchManager.performSearch(in: contacts)
        }
        .onReceive(voiceSearchManager.$isVoiceSearchComplete) { isComplete in
            print("🔄 onReceive detected completion: \(isComplete)")
            if isComplete {
                print("✅ onReceive: Voice search completed, getting transcribed text...")
                let transcribedText = voiceSearchManager.getTranscribedTextAndReset()
                print("📝 onReceive: Transcribed text: '\(transcribedText)'")
                if !transcribedText.isEmpty {
                    print("🔍 onReceive: Setting search text to: '\(transcribedText)'")
                    searchManager.searchText = transcribedText
                    // Manually reset completion flag after successful processing
                    voiceSearchManager.isVoiceSearchComplete = false
                } else {
                    print("⚠️ onReceive: Transcribed text is empty")
                    // Reset completion flag even for empty results
                    voiceSearchManager.isVoiceSearchComplete = false
                }
            }
        }
        .alert("Microphone Permission Required", isPresented: $voiceSearchManager.showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Voice search requires microphone access. Please enable it in Settings > Privacy & Security > Microphone.")
        }
        .alert("Voice Search Error", isPresented: $voiceSearchManager.showingError) {
            Button("OK") { }
        } message: {
            Text(voiceSearchManager.errorMessage)
        }
    }
}

}

#Preview {
    SearchBarView(
        searchManager: SearchManager(),
        voiceSearchManager: VoiceSearchManager(),
        contacts: []
    )
}
