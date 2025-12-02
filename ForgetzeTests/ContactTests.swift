import XCTest
import SwiftData
@testable import Forgetze

final class ContactTests: XCTestCase {
    
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Create an in-memory model context for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Contact.self, Kid.self, Birthday.self, configurations: config)
        modelContext = ModelContext(container)
    }
    
    override func tearDownWithError() throws {
        modelContext = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Contact Creation Tests
    
    func testContactCreation() throws {
        // Given
        let firstName = "John"
        let lastName = "Doe"
        let notes = "Test contact"
        
        // When
        let contact = Contact(
            firstName: firstName,
            lastName: lastName,
            notes: notes
        )
        
        // Then
        XCTAssertEqual(contact.firstName, firstName)
        XCTAssertEqual(contact.lastName, lastName)
        XCTAssertEqual(contact.notes, notes)
        XCTAssertNotNil(contact.id)
        XCTAssertNotNil(contact.createdAt)
        XCTAssertNotNil(contact.updatedAt)
    }
    
    func testContactCreationWithDefaultValues() throws {
        // When
        let contact = Contact(firstName: "Jane", lastName: "Smith")
        
        // Then
        XCTAssertEqual(contact.notes, "")
        XCTAssertEqual(contact.socialMediaURLs, [])
        XCTAssertNil(contact.birthday)
        XCTAssertEqual(contact.kids, [])
    }
    
    // MARK: - Computed Properties Tests
    
    func testFullName() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When & Then
        XCTAssertEqual(contact.fullName, "John Doe")
    }
    
    func testFullNameWithEmptyFirstName() throws {
        // Given
        let contact = Contact(firstName: "", lastName: "Doe")
        
        // When & Then
        XCTAssertEqual(contact.fullName, "Doe")
    }
    
    func testFullNameWithEmptyLastName() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "")
        
        // When & Then
        XCTAssertEqual(contact.fullName, "John")
    }
    
    func testFullNameWithEmptyNames() throws {
        // Given
        let contact = Contact(firstName: "", lastName: "")
        
        // When & Then
        XCTAssertEqual(contact.fullName, "Unknown Contact")
    }
    
    func testDisplayName() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When & Then
        XCTAssertEqual(contact.displayName, "John Doe")
    }
    
    func testDisplayNameWithEmptyNames() throws {
        // Given
        let contact = Contact(firstName: "", lastName: "")
        
        // When & Then
        XCTAssertEqual(contact.displayName, "Unnamed Contact")
    }
    
    // MARK: - Validation Tests
    
    func testValidContact() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When & Then
        XCTAssertTrue(contact.isValid)
        XCTAssertTrue(contact.validationErrors.isEmpty)
    }
    
    func testInvalidContactEmptyFirstName() throws {
        // Given
        let contact = Contact(firstName: "", lastName: "Doe")
        
        // When & Then
        XCTAssertFalse(contact.isValid)
        XCTAssertTrue(contact.validationErrors.contains("First name is required"))
    }
    
    func testInvalidContactEmptyLastName() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "")
        
        // When & Then
        XCTAssertFalse(contact.isValid)
        XCTAssertTrue(contact.validationErrors.contains("Last name is required"))
    }
    
    func testInvalidContactWhitespaceNames() throws {
        // Given
        let contact = Contact(firstName: "   ", lastName: "   ")
        
        // When & Then
        XCTAssertFalse(contact.isValid)
        XCTAssertTrue(contact.validationErrors.contains("First name is required"))
        XCTAssertTrue(contact.validationErrors.contains("Last name is required"))
    }
    
    // MARK: - Kids Management Tests
    
    func testHasKids() throws {
        // Given
        let kids = [Kid(firstName: "Emma", lastName: "Doe")]
        let contact = Contact(firstName: "John", lastName: "Doe", kids: kids)
        
        // When & Then
        XCTAssertTrue(contact.hasKids)
        XCTAssertEqual(contact.kidsCount, 1)
    }
    
    func testNoKids() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When & Then
        XCTAssertFalse(contact.hasKids)
        XCTAssertEqual(contact.kidsCount, 0)
    }
    
    // MARK: - Social Media Tests
    
    func testHasSocialMedia() throws {
        // Given
        let socialMedia = ["https://linkedin.com/in/johndoe"]
        let contact = Contact(
            firstName: "John",
            lastName: "Doe",
            socialMediaURLs: socialMedia
        )
        
        // When & Then
        XCTAssertTrue(contact.hasSocialMedia)
    }
    
    func testNoSocialMedia() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When & Then
        XCTAssertFalse(contact.hasSocialMedia)
    }
    
    func testSocialMediaWithEmptyURLs() throws {
        // Given
        let socialMedia = ["", "   ", "https://linkedin.com/in/johndoe"]
        let contact = Contact(
            firstName: "John",
            lastName: "Doe",
            socialMediaURLs: socialMedia
        )
        
        // When & Then
        XCTAssertTrue(contact.hasSocialMedia)
    }
    
    // MARK: - Birthday Tests
    
    func testAgeCalculation() throws {
        // Given
        let birthday = Birthday(date: Date().addingTimeInterval(-30*365*24*60*60))
        let contact = Contact(
            firstName: "John",
            lastName: "Doe",
            birthday: birthday
        )
        
        // When & Then
        XCTAssertNotNil(contact.age)
        XCTAssertEqual(contact.age, 30)
    }
    
    func testNoBirthday() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When & Then
        XCTAssertNil(contact.age)
        XCTAssertEqual(contact.birthdayDisplay, "No birthday set")
        XCTAssertEqual(contact.shortBirthdayDisplay, "No birthday")
    }
    
    // MARK: - Data Persistence Tests
    
    func testContactPersistence() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        
        // When
        modelContext.insert(contact)
        try modelContext.save()
        
        // Then
        let fetchDescriptor = FetchDescriptor<Contact>()
        let savedContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(savedContacts.count, 1)
        XCTAssertEqual(savedContacts.first?.firstName, "John")
        XCTAssertEqual(savedContacts.first?.lastName, "Doe")
    }
    
    func testContactUpdate() throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe")
        modelContext.insert(contact)
        try modelContext.save()
        
        // When
        contact.firstName = "Jane"
        try modelContext.save()
        
        // Then
        let fetchDescriptor = FetchDescriptor<Contact>()
        let savedContacts = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(savedContacts.first?.firstName, "Jane")
    }
}


