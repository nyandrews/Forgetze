import SwiftUI

struct SearchBarView: View {
    @ObservedObject var searchManager: SearchManager
    @ObservedObject var voiceSearchManager: VoiceSearchManager
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
                                TextField("Can't remember a name? Search by what you recall...", text: $searchManager.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Voice search button
            Button(action: {
                if voiceSearchManager.isRecording {
                    voiceSearchManager.stopVoiceSearch()
                } else {
                    voiceSearchManager.startVoiceSearch()
                }
            }) {
                Image(systemName: voiceSearchManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .foregroundColor(voiceSearchManager.isRecording ? .red : .blue)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("voiceSearchButton")
            
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
        .onChange(of: voiceSearchManager.transcribedText) { _, newValue in
            if !newValue.isEmpty {
                searchManager.searchText = newValue
                voiceSearchManager.clearTranscribedText()
            }
        }
    }
}

#Preview {
    SearchBarView(
        searchManager: SearchManager(),
        voiceSearchManager: VoiceSearchManager()
    )
}
