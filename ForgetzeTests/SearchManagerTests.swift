import XCTest
@testable import Forgetze

final class SearchManagerTests: XCTestCase {
    
    var searchManager: SearchManager!
    var testContacts: [Contact]!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        searchManager = SearchManager()
        testContacts = createTestContacts()
    }
    
    override func tearDownWithError() throws {
        searchManager = nil
        testContacts = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper Methods
    
    private func createTestContacts() -> [Contact] {
        return [
            Contact(firstName: "John", lastName: "Doe", notes: "Software engineer"),
            Contact(firstName: "Jane", lastName: "Smith", notes: "Designer"),
            Contact(firstName: "Mike", lastName: "Johnson", notes: "Project manager"),
            Contact(firstName: "Sarah", lastName: "Wilson", notes: "Marketing specialist"),
            Contact(firstName: "David", lastName: "Brown", notes: "Data analyst")
        ]
    }
    
    // MARK: - Search Functionality Tests
    
    func testEmptySearch() throws {
        // Given
        searchManager.searchText = ""
        
        // When
        searchManager.performSearch(in: testContacts)
        
        // Then
        XCTAssertTrue(searchManager.filteredResults.isEmpty)
        XCTAssertFalse(searchManager.isSearching)
    }
    
    func testBasicSearch() throws {
        // Given
        searchManager.searchText = "John"
        
        // When
        searchManager.performSearch(in: testContacts)
        
        // Wait for debounce
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(searchManager.filteredResults.count, 1)
        XCTAssertEqual(searchManager.filteredResults.first?.firstName, "John")
    }
    
    func testSearchByLastName() throws {
        // Given
        searchManager.searchText = "Smith"
        
        // When
        searchManager.performSearch(in: testContacts)
        
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(searchManager.filteredResults.count, 1)
        XCTAssertEqual(searchManager.filteredResults.first?.lastName, "Smith")
    }
    
    func testSearchByNotes() throws {
        // Given
        searchManager.searchText = "engineer"
        
        // When
        searchManager.performSearch(in: testContacts)
        
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(searchManager.filteredResults.count, 1)
        XCTAssertEqual(searchManager.filteredResults.first?.firstName, "John")
    }
    
    func testCaseInsensitiveSearch() throws {
        // Given
        searchManager.searchText = "JANE"
        
        // When
        searchManager.performSearch(in: testContacts)
        
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(searchManager.filteredResults.count, 1)
        XCTAssertEqual(searchManager.filteredResults.first?.firstName, "Jane")
    }
    
    func testPartialMatchSearch() throws {
        // Given
        searchManager.searchText = "Jo"
        
        // When
        searchManager.performSearch(in: testContacts)
        
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(searchManager.filteredResults.count, 2) // John and Johnson
    }
    
    // MARK: - Caching Tests
    
    func testSearchCaching() throws {
        // Given
        searchManager.searchText = "John"
        
        // When - First search
        searchManager.performSearch(in: testContacts)
        let expectation1 = XCTestExpectation(description: "First search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)
        
        let firstResults = searchManager.filteredResults
        
        // When - Second search (should use cache)
        searchManager.searchText = "John"
        searchManager.performSearch(in: testContacts)
        let expectation2 = XCTestExpectation(description: "Second search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        let secondResults = searchManager.filteredResults
        
        // Then
        XCTAssertEqual(firstResults.count, secondResults.count)
        XCTAssertEqual(searchManager.cacheSize, 1)
    }
    
    func testCacheHitRate() throws {
        // Given
        searchManager.searchText = "John"
        
        // When - Multiple searches
        for _ in 1...5 {
            searchManager.performSearch(in: testContacts)
            let expectation = XCTestExpectation(description: "Search completed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
        }
        
        // Then
        XCTAssertGreaterThan(searchManager.cacheHitRate, 0.0)
    }
    
    func testCacheSizeLimit() throws {
        // Given - Add many unique searches
        for i in 1...150 {
            searchManager.searchText = "Search\(i)"
            searchManager.performSearch(in: testContacts)
        }
        
        // Then - Cache should be limited
        XCTAssertLessThanOrEqual(searchManager.cacheSize, 100)
    }
    
    // MARK: - Performance Tests
    
    func testSearchPerformance() throws {
        // Given - Large contact list
        let largeContactList = (1...1000).map { i in
            Contact(
                firstName: "User\(i)",
                lastName: "Last\(i)",
                notes: "Notes for user \(i)"
            )
        }
        
        searchManager.searchText = "User500"
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        searchManager.performSearch(in: largeContactList)
        
        let expectation = XCTestExpectation(description: "Performance test completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let searchTime = endTime - startTime
        
        // Then - Search should complete quickly
        XCTAssertLessThan(searchTime, 0.1, "Search should complete in less than 100ms")
    }
    
    // MARK: - Debouncing Tests
    
    func testSearchDebouncing() throws {
        // Given
        var searchCount = 0
        searchManager.searchText = "John"
        
        // When - Rapid search changes
        for i in 1...10 {
            searchManager.searchText = "Search\(i)"
            searchManager.performSearch(in: testContacts)
            searchCount += 1
        }
        
        // Then - Should not execute immediately
        XCTAssertEqual(searchManager.filteredResults.count, 0)
        
        // Wait for debounce
        let expectation = XCTestExpectation(description: "Debounced search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Should have results after debounce
        XCTAssertGreaterThan(searchManager.filteredResults.count, 0)
    }
    
    // MARK: - Public Interface Tests
    
    func testUpdateSearchText() throws {
        // Given
        let newText = "New Search"
        
        // When
        searchManager.updateSearchText(newText, in: testContacts)
        
        // Then
        XCTAssertEqual(searchManager.searchText, newText)
    }
    
    func testReset() throws {
        // Given
        searchManager.searchText = "John"
        searchManager.performSearch(in: testContacts)
        
        // When
        searchManager.reset()
        
        // Then
        XCTAssertEqual(searchManager.searchText, "")
        XCTAssertTrue(searchManager.filteredResults.isEmpty)
        XCTAssertFalse(searchManager.isSearching)
    }
    
    func testHasActiveSearch() throws {
        // Given
        searchManager.searchText = ""
        
        // When & Then
        XCTAssertFalse(searchManager.hasActiveSearch())
        
        // Given
        searchManager.searchText = "John"
        
        // When & Then
        XCTAssertTrue(searchManager.hasActiveSearch())
    }
    
    func testGetResults() throws {
        // Given
        searchManager.searchText = "John"
        searchManager.performSearch(in: testContacts)
        
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // When
        let results = searchManager.getResults()
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.firstName, "John")
    }
    
    func testClearCache() throws {
        // Given
        searchManager.searchText = "John"
        searchManager.performSearch(in: testContacts)
        
        let expectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // When
        searchManager.clearCache()
        
        // Then
        XCTAssertEqual(searchManager.cacheSize, 0)
    }
}


