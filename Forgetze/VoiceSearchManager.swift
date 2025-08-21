import Foundation
import Speech
import AVFoundation
import SwiftUI

@MainActor
class VoiceSearchManager: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var showingPermissionAlert = false
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var isVoiceSearchComplete = false
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var searchTimeoutTimer: Timer?
    
    deinit {
        // Note: deinit cannot be async, so we do minimal cleanup here
        // Only do synchronous cleanup operations
        searchTimeoutTimer?.invalidate()
        searchTimeoutTimer = nil
        
        // Stop audio engine if running (synchronous operation)
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Cancel recognition task (synchronous operation)
        recognitionTask?.cancel()
    }
    
    init() {
        print("🔧 Initializing VoiceSearchManager...")
        
        // Try to create speech recognizer with US English
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        print("US English speech recognizer: \(speechRecognizer != nil ? "✅ Created" : "❌ Failed")")
        
        // If US English fails, try system locale
        if speechRecognizer == nil {
            print("Trying system locale speech recognizer...")
            speechRecognizer = SFSpeechRecognizer()
            print("System locale speech recognizer: \(speechRecognizer != nil ? "✅ Created" : "❌ Failed")")
        }
        
        if let recognizer = speechRecognizer {
            print("Speech recognizer available: \(recognizer.isAvailable)")
            print("Speech recognizer locale: \(recognizer.locale)")
        } else {
            print("❌ No speech recognizer available")
        }
        
        requestSpeechPermissions()
    }
    
    // MARK: - Permission Management
    
    private func requestSpeechPermissions() {
        print("Requesting speech recognition permissions...")
        SFSpeechRecognizer.requestAuthorization { authStatus in
            Task { @MainActor in
                print("Speech recognition authorization status: \(authStatus)")
                switch authStatus {
                case .authorized:
                    print("✅ Speech recognition authorized")
                case .denied:
                    print("❌ Speech recognition denied")
                    self.showingPermissionAlert = true
                case .restricted:
                    print("❌ Speech recognition restricted")
                    self.showingPermissionAlert = true
                case .notDetermined:
                    print("⏳ Speech recognition not determined")
                @unknown default:
                    print("❓ Unknown authorization status: \(authStatus)")
                }
            }
        }
        
        print("Requesting microphone permissions...")
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in
                if granted {
                    print("✅ Microphone permission granted")
                } else {
                    print("❌ Microphone permission denied")
                    self.showingPermissionAlert = true
                }
            }
        }
    }
    
    // MARK: - Voice Search Control
    
    func startVoiceSearch() {
        print("🎤 Starting voice search...")
        // Reset completion flag for new search
        isVoiceSearchComplete = false
        

        
        // Check permissions first
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        print("Speech recognition status: \(speechStatus)")
        
        guard speechStatus == .authorized else {
            print("❌ Speech recognition not authorized, showing permission alert")
            showingPermissionAlert = true
            return
        }
        
        // Check microphone permission
        print("Checking microphone permission...")
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in
                if granted {
                    print("✅ Microphone permission granted, proceeding with voice search")
                    self.proceedWithVoiceSearch()
                } else {
                    print("❌ Microphone permission denied, showing permission alert")
                    self.showingPermissionAlert = true
                }
            }
        }
    }
    
    func stopVoiceSearch() {
        cleanup()
        isRecording = false
    }
    
    @MainActor
    private func cleanup() {
        stopTimeoutTimer()
        
        // Stop audio engine and remove tap
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Don't clear completion flag if we have successful transcription
        // Only clear errors, not the completion status
        if !transcribedText.isEmpty {
            print("🔍 Cleanup: Has transcription, preserving completion flag")
            // Clear errors but preserve completion status
            showingError = false
            errorMessage = ""
            // Don't call clearErrors() as it clears isVoiceSearchComplete
        } else {
            print("🔍 Cleanup: No transcription, clearing completion flag")
            clearErrors()
        }
        
        // Reset audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.isOtherAudioPlaying {
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    @MainActor
    private func cleanupAudioOnly() {
        stopTimeoutTimer()
        
        // Stop audio engine and remove tap
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Reset audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.isOtherAudioPlaying {
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        // DO NOT touch completion flag or transcription - preserve them for SearchBarView
        print("🔍 CleanupAudioOnly: Preserving completion flag and transcription")
    }
    
    private func proceedWithVoiceSearch() {
        print("🚀 Proceeding with voice search...")
        
        // Check speech recognition permission first
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            print("❌ Speech recognition not authorized in proceedWithVoiceSearch")
            showingPermissionAlert = true
            return
        }
        
        // Check if speech recognition is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ Speech recognition not available")
            showError("Speech recognition is not available on this device. Please try on a physical device or check your iOS settings.")
            return
        }
        
        print("✅ Speech recognition is available and authorized")
        
        // Stop any existing recording
        if isRecording {
            stopVoiceSearch()
            return
        }
        
        // Configure audio session
        print("🎵 Configuring audio session...")
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
            showError("Failed to configure audio session: \(error.localizedDescription)")
            return
        }
        
        // Start recording
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            showError("Unable to create speech recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            print("🎤 Starting audio engine...")
            try audioEngine.start()
            isRecording = true
            print("✅ Audio engine started, isRecording set to true")
            
            print("🎯 Creating speech recognition task...")
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                print("🎯 Speech recognition callback triggered - result: \(result != nil), error: \(error != nil)")
                Task { @MainActor in
                    if let error = error {
                        print("❌ Speech recognition callback received error: \(error.localizedDescription)")
                        
                        // Check if this is a post-success cleanup error (common with speech recognition)
                        if !self.transcribedText.isEmpty {
                            print("Ignoring error - we have successful transcription: \(self.transcribedText)")
                            self.isVoiceSearchComplete = true
                            // Don't call stopVoiceSearch here since it clears isVoiceSearchComplete
                            self.cleanup()
                            self.isRecording = false
                            return
                        }
                        
                        // Check if this is a timeout or cancellation error (not a real failure)
                        let errorDescription = error.localizedDescription.lowercased()
                        if errorDescription.contains("timeout") || 
                           errorDescription.contains("cancelled") ||
                           errorDescription.contains("no speech detected") {
                            print("Ignoring cleanup error: \(errorDescription)")
                            if !self.transcribedText.isEmpty {
                                self.isVoiceSearchComplete = true
                            }
                            self.stopVoiceSearch()
                            return
                        }
                        
                        // Only show error for real failures
                        print("Showing error for real failure: \(error.localizedDescription)")
                        self.showError("Speech recognition failed: \(error.localizedDescription)")
                        self.stopVoiceSearch()
                        return
                    }
                    
                    if let result = result {
                        print("✅ Speech recognition result received: '\(result.bestTranscription.formattedString)'")
                        self.transcribedText = result.bestTranscription.formattedString
                        
                        // Check if this is the final result
                        if result.isFinal {
                            print("🏁 Final result received, completing voice search")
                            // Set completion flag immediately for final results
                            self.isVoiceSearchComplete = true
                            print("✅ Completion flag set to true: \(self.isVoiceSearchComplete)")
                            // Small delay to ensure final result is captured, then cleanup
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Reduced from 0.5 to 0.2
                                print("⏰ Timer fired, cleaning up voice search")
                                print("🔍 Completion flag before cleanup: \(self.isVoiceSearchComplete)")
                                // Only cleanup audio, preserve completion state
                                self.cleanupAudioOnly()
                                self.isRecording = false
                                print("🔍 Completion flag after cleanup: \(self.isVoiceSearchComplete)")
                            }
                        } else {
                            print("📝 Partial result received, continuing...")
                            // Send partial results for real-time updates
                            self.isVoiceSearchComplete = true
                            // Reset after a short delay to allow for more partial results
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.isVoiceSearchComplete = false
                            }
                        }
                    }
                }
            }
            
            // Start timeout timer to prevent hanging
            startTimeoutTimer()
            
        } catch {
            showError("Failed to start audio engine: \(error.localizedDescription)")
            stopVoiceSearch()
        }
    }
    
    // MARK: - Timeout Management
    private func startTimeoutTimer() {
        searchTimeoutTimer?.invalidate()
        searchTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            Task { @MainActor in
                // Only show timeout error if we don't have transcription
                if self.transcribedText.isEmpty {
                    print("Voice search timeout with no transcription")
                    self.showError("Voice search timed out. Please try again.")
                } else {
                    print("Voice search timeout but we have transcription: \(self.transcribedText)")
                    self.isVoiceSearchComplete = true
                }
                // Don't call stopVoiceSearch here since it clears isVoiceSearchComplete
                self.cleanup()
                self.isRecording = false
            }
        }
    }
    
    private func stopTimeoutTimer() {
        searchTimeoutTimer?.invalidate()
        searchTimeoutTimer = nil
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        // Don't show error if we have successful transcription
        if !transcribedText.isEmpty {
            return
        }
        
        errorMessage = message
        showingError = true
    }
    
    // MARK: - Public Interface
    
    func getTranscribedText() -> String {
        return transcribedText
    }
    
    func clearTranscribedText() {
        transcribedText = ""
    }
    
    func wasSuccessful() -> Bool {
        return !transcribedText.isEmpty
    }
    
    func reset() {
        stopVoiceSearch()
        clearTranscribedText()
        clearErrors()
    }
    
    func clearErrors() {
        showingError = false
        errorMessage = ""
        isVoiceSearchComplete = false
    }
    
    func getTranscribedTextAndReset() -> String {
        let text = transcribedText
        // Don't clear completion flag here - let SearchBarView handle it
        clearTranscribedText()
        // Only clear error states, preserve completion status
        showingError = false
        errorMessage = ""
        return text
    }
}
