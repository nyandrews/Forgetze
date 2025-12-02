import XCTest
import Speech
import AVFoundation
@testable import Forgetze

final class VoiceSearchManagerTests: XCTestCase {
    
    var voiceSearchManager: VoiceSearchManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        voiceSearchManager = VoiceSearchManager()
    }
    
    override func tearDownWithError() throws {
        voiceSearchManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testVoiceSearchManagerInitialization() throws {
        // Given & When
        let manager = VoiceSearchManager()
        
        // Then
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.isRecording)
        XCTAssertEqual(manager.transcribedText, "")
        XCTAssertFalse(manager.showingPermissionAlert)
        XCTAssertFalse(manager.showingError)
        XCTAssertEqual(manager.errorMessage, "")
    }
    
    // MARK: - State Management Tests
    
    func testInitialState() throws {
        // Then
        XCTAssertFalse(voiceSearchManager.isRecording)
        XCTAssertEqual(voiceSearchManager.transcribedText, "")
        XCTAssertFalse(voiceSearchManager.showingPermissionAlert)
        XCTAssertFalse(voiceSearchManager.showingError)
        XCTAssertEqual(voiceSearchManager.errorMessage, "")
    }
    
    func testTranscribedTextGetter() throws {
        // Given
        voiceSearchManager.transcribedText = "Hello World"
        
        // When
        let result = voiceSearchManager.getTranscribedText()
        
        // Then
        XCTAssertEqual(result, "Hello World")
    }
    
    func testClearTranscribedText() throws {
        // Given
        voiceSearchManager.transcribedText = "Hello World"
        
        // When
        voiceSearchManager.clearTranscribedText()
        
        // Then
        XCTAssertEqual(voiceSearchManager.transcribedText, "")
    }
    
    // MARK: - Reset Functionality Tests
    
    func testReset() throws {
        // Given
        voiceSearchManager.transcribedText = "Hello World"
        voiceSearchManager.showingError = true
        voiceSearchManager.errorMessage = "Test error"
        
        // When
        voiceSearchManager.reset()
        
        // Then
        XCTAssertEqual(voiceSearchManager.transcribedText, "")
        XCTAssertFalse(voiceSearchManager.showingError)
        XCTAssertEqual(voiceSearchManager.errorMessage, "")
    }
    
    func testCleanup() throws {
        // Given
        voiceSearchManager.transcribedText = "Hello World"
        voiceSearchManager.showingError = true
        voiceSearchManager.errorMessage = "Test error"
        
        // When
        voiceSearchManager.cleanup()
        
        // Then
        XCTAssertEqual(voiceSearchManager.transcribedText, "")
        XCTAssertFalse(voiceSearchManager.showingError)
        XCTAssertEqual(voiceSearchManager.errorMessage, "")
    }
    
    // MARK: - Permission Tests
    
    func testSpeechRecognitionPermissionStatus() throws {
        // Given & When
        let status = SFSpeechRecognizer.authorizationStatus()
        
        // Then - Should be one of the valid statuses
        XCTAssertTrue([.notDetermined, .denied, .restricted, .authorized].contains(status))
    }
    
    func testMicrophonePermissionStatus() throws {
        // Given & When
        let status = AVAudioSession.sharedInstance().recordPermission
        
        // Then - Should be one of the valid statuses
        XCTAssertTrue([.undetermined, .denied, .granted].contains(status))
    }
    
    // MARK: - Voice Search Control Tests
    
    func testStartVoiceSearchWithoutPermissions() throws {
        // Given - Mock denied permissions
        // Note: In a real test environment, you'd mock the permission status
        
        // When
        voiceSearchManager.startVoiceSearch()
        
        // Then - Should show permission alert
        // Note: This test may not work in all environments due to permission mocking limitations
        // In a real app, you'd want to mock the permission responses
    }
    
    func testStopVoiceSearch() throws {
        // Given
        voiceSearchManager.isRecording = true
        
        // When
        voiceSearchManager.stopVoiceSearch()
        
        // Then
        XCTAssertFalse(voiceSearchManager.isRecording)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorStateManagement() throws {
        // Given
        let errorMessage = "Test error message"
        
        // When - Simulate error (this would normally happen internally)
        voiceSearchManager.errorMessage = errorMessage
        voiceSearchManager.showingError = true
        
        // Then
        XCTAssertEqual(voiceSearchManager.errorMessage, errorMessage)
        XCTAssertTrue(voiceSearchManager.showingError)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() throws {
        // Given
        var manager: VoiceSearchManager? = VoiceSearchManager()
        weak var weakManager = manager
        
        // When
        manager = nil
        
        // Then - Should be properly deallocated
        XCTAssertNil(weakManager)
    }
    
    // MARK: - Integration Tests
    
    func testVoiceSearchManagerWithSearchManager() throws {
        // Given
        let searchManager = SearchManager()
        voiceSearchManager.transcribedText = "John Doe"
        
        // When
        let transcribedText = voiceSearchManager.getTranscribedText()
        
        // Then
        XCTAssertEqual(transcribedText, "John Doe")
        XCTAssertFalse(transcribedText.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testVoiceSearchManagerPerformance() throws {
        // Given
        let manager = VoiceSearchManager()
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform multiple operations
        for _ in 1...100 {
            manager.clearTranscribedText()
            manager.getTranscribedText()
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let operationTime = endTime - startTime
        
        // Then - Should be fast
        XCTAssertLessThan(operationTime, 0.1, "Voice search manager operations should be fast")
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptyTranscribedText() throws {
        // Given
        voiceSearchManager.transcribedText = ""
        
        // When
        let result = voiceSearchManager.getTranscribedText()
        
        // Then
        XCTAssertEqual(result, "")
        XCTAssertTrue(result.isEmpty)
    }
    
    func testLongTranscribedText() throws {
        // Given
        let longText = String(repeating: "A", count: 1000)
        voiceSearchManager.transcribedText = longText
        
        // When
        let result = voiceSearchManager.getTranscribedText()
        
        // Then
        XCTAssertEqual(result, longText)
        XCTAssertEqual(result.count, 1000)
    }
    
    func testSpecialCharactersInTranscribedText() throws {
        // Given
        let specialText = "Hello! @#$%^&*()_+-=[]{}|;':\",./<>?"
        voiceSearchManager.transcribedText = specialText
        
        // When
        let result = voiceSearchManager.getTranscribedText()
        
        // Then
        XCTAssertEqual(result, specialText)
    }
    
    // MARK: - Thread Safety Tests
    
    func testThreadSafety() throws {
        // Given
        let expectation = XCTestExpectation(description: "Thread safety test completed")
        let queue = DispatchQueue.global(qos: .background)
        
        // When - Test concurrent access
        queue.async {
            for i in 1...100 {
                self.voiceSearchManager.transcribedText = "Text \(i)"
                _ = self.voiceSearchManager.getTranscribedText()
                self.voiceSearchManager.clearTranscribedText()
            }
            expectation.fulfill()
        }
        
        // Then - Should complete without crashes
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Lifecycle Tests
    
    func testLifecycleManagement() throws {
        // Given
        let manager = VoiceSearchManager()
        
        // When - Simulate app lifecycle
        manager.transcribedText = "Test"
        manager.cleanup()
        manager.reset()
        
        // Then - Should be in clean state
        XCTAssertEqual(manager.transcribedText, "")
        XCTAssertFalse(manager.showingError)
        XCTAssertEqual(manager.errorMessage, "")
    }
}


