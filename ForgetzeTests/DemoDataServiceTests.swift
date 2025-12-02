import XCTest
import SwiftData
@testable import Forgetze

final class DemoDataServiceTests: XCTestCase {
    
    var modelContext: ModelContext!
    var demoDataService: DemoDataService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Create an in-memory model context for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Contact.self, Kid.self, Birthday.self, configurations: config)
        modelContext = ModelContext(container)
        demoDataService = DemoDataService.shared
    }
    
    override func tearDownWithError() throws {
        modelContext = nil
        demoDataService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Demo Data Loading Tests
    
    func testLoadDemoDataWhenEmpty() async throws {
        // Given - Empty context
        let fetchDescriptor = FetchDescriptor<Contact>()
        let initialContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertTrue(initialContacts.isEmpty)
        
        // When
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: initialContacts
        )
        
        // Then - Should have loaded demo data
        let finalContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(finalContacts.count, 9) // 9 demo contacts
        
        // Verify specific contacts exist
        let johnDoe = finalContacts.first { $0.firstName == "John" && $0.lastName == "Doe" }
        XCTAssertNotNil(johnDoe)
        XCTAssertEqual(johnDoe?.notes.contains("hiking"), true)
        
        let sarahSmith = finalContacts.first { $0.firstName == "Sarah" && $0.lastName == "Smith" }
        XCTAssertNotNil(sarahSmith)
        XCTAssertEqual(sarahSmith?.notes.contains("project manager"), true)
    }
    
    func testLoadDemoDataWhenContactsExist() async throws {
        // Given - Existing contacts
        let existingContact = Contact(firstName: "Test", lastName: "User")
        modelContext.insert(existingContact)
        try modelContext.save()
        
        let fetchDescriptor = FetchDescriptor<Contact>()
        let existingContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(existingContacts.count, 1)
        
        // When
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: existingContacts
        )
        
        // Then - Should not load demo data, but should update existing
        let finalContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(finalContacts.count, 1) // Still only 1 contact
        
        // Should have updated existing contact with social media
        let updatedContact = finalContacts.first
        XCTAssertNotNil(updatedContact)
    }
    
    // MARK: - Contact Creation Tests
    
    func testDemoContactProperties() async throws {
        // Given - Load demo data
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: []
        )
        
        // When
        let fetchDescriptor = FetchDescriptor<Contact>()
        let contacts = try modelContext.fetch(fetchDescriptor)
        
        // Then - Verify contact properties
        let johnDoe = contacts.first { $0.firstName == "John" && $0.lastName == "Doe" }
        XCTAssertNotNil(johnDoe)
        
        if let john = johnDoe {
            // Check social media URLs
            XCTAssertTrue(john.hasSocialMedia)
            XCTAssertEqual(john.socialMediaURLs.count, 2)
            XCTAssertTrue(john.socialMediaURLs.contains("https://linkedin.com/in/johndoe"))
            XCTAssertTrue(john.socialMediaURLs.contains("https://twitter.com/johndoe"))
            
            // Check birthday
            XCTAssertNotNil(john.birthday)
            XCTAssertNotNil(john.age)
            
            // Check kids
            XCTAssertTrue(john.hasKids)
            XCTAssertEqual(john.kidsCount, 3)
        }
    }
    
    func testDemoContactKids() async throws {
        // Given - Load demo data
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: []
        )
        
        // When
        let fetchDescriptor = FetchDescriptor<Contact>()
        let contacts = try modelContext.fetch(fetchDescriptor)
        
        // Then - Verify kids information
        let mikeJohnson = contacts.first { $0.firstName == "Mike" && $0.lastName == "Johnson" }
        XCTAssertNotNil(mikeJohnson)
        
        if let mike = mikeJohnson {
            XCTAssertTrue(mike.hasKids)
            XCTAssertEqual(mike.kidsCount, 3)
            
            // Check specific kids
            let alex = mike.kids.first { $0.firstName == "Alex" }
            XCTAssertNotNil(alex)
            XCTAssertEqual(alex?.lastName, "Johnson")
        }
    }
    
    func testDemoContactBirthdays() async throws {
        // Given - Load demo data
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: []
        )
        
        // When
        let fetchDescriptor = FetchDescriptor<Contact>()
        let contacts = try modelContext.fetch(fetchDescriptor)
        
        // Then - Verify birthday information
        let lisaBrown = contacts.first { $0.firstName == "Lisa" && $0.lastName == "Brown" }
        XCTAssertNotNil(lisaBrown)
        
        if let lisa = lisaBrown {
            XCTAssertNotNil(lisa.birthday)
            XCTAssertEqual(lisa.birthday?.month, 6)
            XCTAssertEqual(lisa.birthday?.day, 15)
        }
        
        let rachelClark = contacts.first { $0.firstName == "Rachel" && $0.lastName == "Clark" }
        XCTAssertNotNil(rachelClark)
        
        if let rachel = rachelClark {
            XCTAssertNotNil(rachel.birthday)
            XCTAssertEqual(rachel.birthday?.month, 12)
            XCTAssertEqual(rachel.birthday?.day, 3)
        }
    }
    
    // MARK: - Social Media Update Tests
    
    func testSocialMediaUpdateForExistingContacts() async throws {
        // Given - Create contact without social media
        let contact = Contact(
            firstName: "John",
            lastName: "Doe",
            notes: "Test contact"
        )
        modelContext.insert(contact)
        try modelContext.save()
        
        let fetchDescriptor = FetchDescriptor<Contact>()
        let existingContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(existingContacts.count, 1)
        XCTAssertFalse(existingContacts.first!.hasSocialMedia)
        
        // When
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: existingContacts
        )
        
        // Then - Should have updated with social media
        let updatedContacts = try modelContext.fetch(fetchDescriptor)
        let updatedContact = updatedContacts.first
        XCTAssertNotNil(updatedContact)
        XCTAssertTrue(updatedContact!.hasSocialMedia)
        XCTAssertTrue(updatedContact!.socialMediaURLs.contains("https://linkedin.com/in/johndoe"))
    }
    
    // MARK: - Data Integrity Tests
    
    func testDemoDataConsistency() async throws {
        // Given - Load demo data
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: []
        )
        
        // When
        let fetchDescriptor = FetchDescriptor<Contact>()
        let contacts = try modelContext.fetch(fetchDescriptor)
        
        // Then - Verify all contacts are valid
        for contact in contacts {
            XCTAssertTrue(contact.isValid, "Contact \(contact.displayName) should be valid")
            XCTAssertFalse(contact.validationErrors.isEmpty == false && !contact.isValid, "Contact \(contact.displayName) validation mismatch")
        }
    }
    
    func testDemoDataUniqueness() async throws {
        // Given - Load demo data
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: []
        )
        
        // When
        let fetchDescriptor = FetchDescriptor<Contact>()
        let contacts = try modelContext.fetch(fetchDescriptor)
        
        // Then - Verify no duplicate contacts
        let names = contacts.map { "\($0.firstName) \($0.lastName)" }
        let uniqueNames = Set(names)
        XCTAssertEqual(names.count, uniqueNames.count, "Should have no duplicate names")
    }
    
    // MARK: - Performance Tests
    
    func testDemoDataLoadingPerformance() async throws {
        // Given - Empty context
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        try await demoDataService.loadDemoDataIfNeeded(
            context: modelContext,
            existingContacts: []
        )
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then - Should load quickly
        let loadTime = endTime - startTime
        XCTAssertLessThan(loadTime, 1.0, "Demo data loading should complete in less than 1 second")
        
        // Verify data was loaded
        let fetchDescriptor = FetchDescriptor<Contact>()
        let contacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(contacts.count, 9)
    }
    
    // MARK: - Error Handling Tests
    
    func testDemoDataServiceSingleton() throws {
        // Given & When
        let instance1 = DemoDataService.shared
        let instance2 = DemoDataService.shared
        
        // Then - Should be the same instance
        XCTAssertTrue(instance1 === instance2, "DemoDataService should be a singleton")
    }
    
    func testDemoDataServiceInitialization() throws {
        // Given & When
        let service = DemoDataService.shared
        
        // Then - Should be properly initialized
        XCTAssertNotNil(service)
    }
}


