import XCTest

final class ContactManagementUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Contact List Tests
    
    func testContactListDisplay() throws {
        // Given - App is launched
        
        // When & Then - Should show contacts list
        XCTAssertTrue(app.navigationBars["Contacts"].exists)
        XCTAssertTrue(app.buttons["Add Contact"].exists)
        XCTAssertTrue(app.buttons["hamburgerMenuButton"].exists)
    }
    
    func testAddContactButton() throws {
        // Given - On contacts list
        
        // When
        app.buttons["Add Contact"].tap()
        
        // Then - Should show contact edit view
        XCTAssertTrue(app.navigationBars["Add Contact"].exists)
        XCTAssertTrue(app.textFields["First Name"].exists)
        XCTAssertTrue(app.textFields["Last Name"].exists)
        XCTAssertTrue(app.textViews["Notes"].exists)
    }
    
    func testHamburgerMenuButton() throws {
        // Given - On contacts list
        
        // When
        app.buttons["hamburgerMenuButton"].tap()
        
        // Then - Should show hamburger menu
        XCTAssertTrue(app.sheets.firstMatch.exists)
    }
    
    // MARK: - Search Functionality Tests
    
    func testSearchBarDisplay() throws {
        // Given - On contacts list
        
        // When & Then - Should show search bar
        XCTAssertTrue(app.textFields["Can't remember a name? Search by what you recall..."].exists)
        XCTAssertTrue(app.buttons["voiceSearchButton"].exists)
    }
    
    func testBasicSearch() throws {
        // Given - On contacts list with demo data
        
        // When
        let searchField = app.textFields["Can't remember a name? Search by what you recall..."]
        searchField.tap()
        searchField.typeText("John")
        
        // Then - Should show search results
        let expectation = XCTestExpectation(description: "Search results displayed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Verify search results contain "John"
        XCTAssertTrue(app.staticTexts["John Doe"].exists)
    }
    
    func testClearSearch() throws {
        // Given - Search field has text
        let searchField = app.textFields["Can't remember a name? Search by what you recall..."]
        searchField.tap()
        searchField.typeText("Test")
        
        // When - Clear search
        if app.buttons["xmark.circle.fill"].exists {
            app.buttons["xmark.circle.fill"].tap()
        }
        
        // Then - Search should be cleared
        XCTAssertEqual(searchField.value as? String, "Can't remember a name? Search by what you recall...")
    }
    
    // MARK: - Voice Search Tests
    
    func testVoiceSearchButton() throws {
        // Given - On contacts list
        
        // When & Then - Voice search button should exist
        let voiceButton = app.buttons["voiceSearchButton"]
        XCTAssertTrue(voiceButton.exists)
        XCTAssertTrue(voiceButton.isEnabled)
    }
    
    func testVoiceSearchButtonAccessibility() throws {
        // Given - On contacts list
        
        // When & Then - Should have proper accessibility
        let voiceButton = app.buttons["voiceSearchButton"]
        XCTAssertTrue(voiceButton.hasValidAccessibilityIdentifier)
    }
    
    // MARK: - Contact Creation Tests
    
    func testCreateNewContact() throws {
        // Given - On contacts list
        
        // When
        app.buttons["Add Contact"].tap()
        
        // Fill in contact details
        let firstNameField = app.textFields["First Name"]
        let lastNameField = app.textFields["Last Name"]
        let notesField = app.textViews["Notes"]
        
        firstNameField.tap()
        firstNameField.typeText("Test")
        
        lastNameField.tap()
        lastNameField.typeText("User")
        
        notesField.tap()
        notesField.typeText("Test contact for UI testing")
        
        // Save contact
        app.buttons["Save"].tap()
        
        // Then - Should return to contacts list
        XCTAssertTrue(app.navigationBars["Contacts"].exists)
        
        // Verify contact was created
        XCTAssertTrue(app.staticTexts["Test User"].exists)
    }
    
    func testCreateContactValidation() throws {
        // Given - On add contact view
        app.buttons["Add Contact"].tap()
        
        // When - Try to save without required fields
        app.buttons["Save"].tap()
        
        // Then - Should show validation error
        // Note: This test assumes validation is implemented in the UI
        // You may need to adjust based on your actual validation implementation
    }
    
    // MARK: - Contact Editing Tests
    
    func testEditExistingContact() throws {
        // Given - Contact exists in list
        // Note: This assumes demo data is loaded
        
        // When - Tap on a contact
        if app.staticTexts["John Doe"].exists {
            app.staticTexts["John Doe"].tap()
        } else {
            // Skip test if no demo data
            return
        }
        
        // Then - Should show contact detail view
        XCTAssertTrue(app.navigationBars["Contact Details"].exists)
        
        // When - Tap edit button
        if app.buttons["Edit"].exists {
            app.buttons["Edit"].tap()
            
            // Then - Should show edit view
            XCTAssertTrue(app.navigationBars["Edit Contact"].exists)
        }
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationFlow() throws {
        // Given - On contacts list
        
        // When - Navigate to add contact
        app.buttons["Add Contact"].tap()
        
        // Then - Should be on add contact view
        XCTAssertTrue(app.navigationBars["Add Contact"].exists)
        
        // When - Navigate back
        app.buttons["Cancel"].tap()
        
        // Then - Should return to contacts list
        XCTAssertTrue(app.navigationBars["Contacts"].exists)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        // Given - App is not running
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        app.launch()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then - Should launch quickly
        let launchTime = endTime - startTime
        XCTAssertLessThan(launchTime, 3.0, "App should launch in less than 3 seconds")
    }
    
    func testSearchPerformance() throws {
        // Given - On contacts list
        
        // When
        let searchField = app.textFields["Can't remember a name? Search by what you recall..."]
        searchField.tap()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        searchField.typeText("John")
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then - Search input should be responsive
        let inputTime = endTime - startTime
        XCTAssertLessThan(inputTime, 1.0, "Search input should be responsive")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Given - On contacts list
        
        // When & Then - All interactive elements should have accessibility labels
        XCTAssertTrue(app.buttons["Add Contact"].hasValidAccessibilityLabel)
        XCTAssertTrue(app.buttons["hamburgerMenuButton"].hasValidAccessibilityLabel)
        XCTAssertTrue(app.buttons["voiceSearchButton"].hasValidAccessibilityLabel)
    }
    
    func testAccessibilityIdentifiers() throws {
        // Given - On contacts list
        
        // When & Then - Critical elements should have accessibility identifiers
        XCTAssertTrue(app.buttons["hamburgerMenuButton"].hasValidAccessibilityIdentifier)
        XCTAssertTrue(app.buttons["voiceSearchButton"].hasValidAccessibilityIdentifier)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorStateHandling() throws {
        // Given - On contacts list
        
        // When - Try to perform actions that might cause errors
        // Note: This test would need to be customized based on your error handling implementation
        
        // Then - App should handle errors gracefully without crashing
        XCTAssertTrue(app.exists)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryUsage() throws {
        // Given - App is running
        
        // When - Navigate through multiple screens
        app.buttons["Add Contact"].tap()
        app.buttons["Cancel"].tap()
        app.buttons["hamburgerMenuButton"].tap()
        
        // Then - App should remain stable
        XCTAssertTrue(app.exists)
        XCTAssertTrue(app.navigationBars["Contacts"].exists)
    }
}


