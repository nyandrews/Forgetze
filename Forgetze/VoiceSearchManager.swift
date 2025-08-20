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
        // Try to create speech recognizer with US English
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        // If US English fails, try system locale
        if speechRecognizer == nil {
            speechRecognizer = SFSpeechRecognizer()
        }
        
        requestSpeechPermissions()
    }
    
    // MARK: - Permission Management
    
    private func requestSpeechPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            Task { @MainActor in
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized: \(authStatus)")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
        
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in
                if !granted {
                    print("Microphone permission denied")
                }
            }
        }
    }
    
    // MARK: - Voice Search Control
    
    func startVoiceSearch() {
        // Check permissions first
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            showingPermissionAlert = true
            return
        }
        
        // Check microphone permission
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in
                if granted {
                    self.proceedWithVoiceSearch()
                } else {
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
        
        // Clear any pending errors if we have transcription
        if !transcribedText.isEmpty {
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
    
    private func proceedWithVoiceSearch() {
        // Check speech recognition permission first
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            showingPermissionAlert = true
            return
        }
        
        // Check if speech recognition is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            showError("Speech recognition is not available on this device. Please try on a physical device or check your iOS settings.")
            return
        }
        
        // Stop any existing recording
        if isRecording {
            stopVoiceSearch()
            return
        }
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
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
            try audioEngine.start()
            isRecording = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                Task { @MainActor in
                    if let error = error {
                        print("Speech recognition callback received error: \(error.localizedDescription)")
                        
                        // Check if this is a post-success cleanup error (common with speech recognition)
                        if !self.transcribedText.isEmpty {
                            print("Ignoring error - we have successful transcription: \(self.transcribedText)")
                            self.isVoiceSearchComplete = true
                            self.stopVoiceSearch()
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
                        print("Speech recognition result: \(result.bestTranscription.formattedString)")
                        self.transcribedText = result.bestTranscription.formattedString
                        
                        // Check if this is the final result
                        if result.isFinal {
                            print("Final result received, completing voice search")
                            // Small delay to ensure final result is captured
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.stopVoiceSearch()
                                self.isVoiceSearchComplete = true
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
                self.stopVoiceSearch()
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
        clearTranscribedText()
        clearErrors()
        return text
    }
}
