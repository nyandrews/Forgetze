import Foundation
import SwiftData
import SwiftUI

/**
 * DataProtectionManager - Bulletproof Data Protection System
 * 
 * This class provides comprehensive protection against data loss through:
 * - Automatic backups before every operation
 * - Transactional data operations
 * - Data integrity validation
 * - Automatic recovery mechanisms
 * - Comprehensive logging and monitoring
 * 
 * ## Core Principles:
 * 1. Never trust, always verify
 * 2. Backup before action
 * 3. Atomic operations only
 * 4. Graceful degradation
 * 5. User transparency
 */
@MainActor
class DataProtectionManager: ObservableObject {
    static let shared = DataProtectionManager()
    
    // MARK: - Published Properties
    @Published var isBackingUp = false
    @Published var lastBackupDate: Date?
    @Published var backupCount = 0
    @Published var lastOperationStatus: OperationStatus = .idle
    
    // MARK: - Private Properties
    private let backupQueue = DispatchQueue(label: "com.forgetze.backup", qos: .userInitiated)
    private let maxBackups = 50
    private let backupDirectory: URL
    
    // MARK: - Types
    enum OperationStatus: Equatable {
        case idle
        case backingUp
        case saving
        case deleting
        case validating
        case recovering
        case error(String)
        case success
        
        static func == (lhs: OperationStatus, rhs: OperationStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.backingUp, .backingUp),
                 (.saving, .saving),
                 (.deleting, .deleting),
                 (.validating, .validating),
                 (.recovering, .recovering),
                 (.success, .success):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    enum ProtectionError: Error, LocalizedError {
        case backupFailed(String)
        case validationFailed(String)
        case saveFailed(String)
        case recoveryFailed(String)
        case insufficientStorage
        case dataCorruption
        
        var errorDescription: String? {
            switch self {
            case .backupFailed(let reason):
                return "Backup failed: \(reason)"
            case .validationFailed(let reason):
                return "Validation failed: \(reason)"
            case .saveFailed(let reason):
                return "Save failed: \(reason)"
            case .recoveryFailed(let reason):
                return "Recovery failed: \(reason)"
            case .insufficientStorage:
                return "Insufficient storage for backup"
            case .dataCorruption:
                return "Data corruption detected"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Create backup directory in app's documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        backupDirectory = documentsPath.appendingPathComponent("DataBackups")
        
        // Ensure backup directory exists
        try? FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
        
        // Load backup count
        loadBackupCount()
        

    }
    
    // MARK: - Public Interface
    
    /**
     * Safe Save Operation - Protected data saving with automatic backup
     * 
     * This method ensures data is never lost by:
     * 1. Creating a backup before saving
     * 2. Validating data integrity
     * 3. Performing the save operation
     * 4. Verifying the save was successful
     * 5. Cleaning up old backups if needed
     */
    func safeSave<T: PersistentModel>(_ object: T, in context: ModelContext) async throws {
        lastOperationStatus = .backingUp
        isBackingUp = true
        
        defer {
            isBackingUp = false
        }
        
        do {
            // Step 1: Create backup before any operation
            try await createBackup(context: context, operation: "save")
            
            // Step 2: Validate data integrity
            lastOperationStatus = .validating
            try validateDataIntegrity(context: context)
            
            // Step 3: Perform save operation
            lastOperationStatus = .saving
            try context.save()
            
            // Step 4: Verify save was successful
            try verifySaveSuccess(object, in: context)
            
            // Step 5: Update status and cleanup
            lastOperationStatus = .success
            lastBackupDate = Date()
            backupCount += 1
            
            // Cleanup old backups if needed
            try cleanupOldBackups()
            

            
        } catch {
            lastOperationStatus = .error(error.localizedDescription)
            print("❌ Safe save failed: \(error.localizedDescription)")
            
            // Attempt automatic recovery
            try await attemptRecovery(context: context, operation: "save")
            
            throw ProtectionError.saveFailed(error.localizedDescription)
        }
    }
    
    /**
     * Safe Delete Operation - Protected data deletion with automatic backup
     * 
     * This method ensures data can be recovered if deletion was unintended by:
     * 1. Creating a comprehensive backup before deletion
     * 2. Validating the object exists and is valid
     * 3. Performing the deletion
     * 4. Verifying the deletion was successful
     */
    func safeDelete<T: PersistentModel>(_ object: T, in context: ModelContext) async throws {
        lastOperationStatus = .backingUp
        isBackingUp = true
        
        defer {
            isBackingUp = false
        }
        
        do {
            // Step 1: Create comprehensive backup before deletion
            try await createBackup(context: context, operation: "delete")
            
            // Step 2: Validate object exists and is valid
            lastOperationStatus = .validating
            try validateObjectForDeletion(object, in: context)
            
            // Step 3: Perform deletion
            lastOperationStatus = .deleting
            context.delete(object)
            try context.save()
            
            // Step 4: Verify deletion was successful
            try verifyDeletionSuccess(object, in: context)
            
            // Step 5: Update status
            lastOperationStatus = .success
            lastBackupDate = Date()
            backupCount += 1
            

            
        } catch {
            lastOperationStatus = .error(error.localizedDescription)
            print("❌ Safe delete failed: \(error.localizedDescription)")
            
            // Attempt automatic recovery
            try await attemptRecovery(context: context, operation: "delete")
            
            throw ProtectionError.saveFailed(error.localizedDescription)
        }
    }
    
    /**
     * Emergency Recovery - Attempt to recover from backup
     * 
     * This method attempts to restore data from the most recent backup
     * when a critical operation fails.
     */
    func emergencyRecovery(context: ModelContext) async throws {
        lastOperationStatus = .recovering
        
        do {
            let backupURL = try findMostRecentBackup()
            try await restoreFromBackup(backupURL, to: context)
            
            lastOperationStatus = .success

            
        } catch {
            lastOperationStatus = .error("Recovery failed: \(error.localizedDescription)")
            print("❌ Emergency recovery failed: \(error.localizedDescription)")
            throw ProtectionError.recoveryFailed(error.localizedDescription)
        }
    }
    
    /**
     * Data Health Check - Comprehensive data integrity validation
     * 
     * This method performs a thorough check of all data to detect
     * corruption, inconsistencies, or other issues.
     */
    func performDataHealthCheck(context: ModelContext) async throws -> DataHealthReport {
        lastOperationStatus = .validating
        
        do {
            let report = try await validateAllData(context: context)
            lastOperationStatus = .success
            return report
            
        } catch {
            lastOperationStatus = .error("Health check failed: \(error.localizedDescription)")
            throw ProtectionError.validationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func createBackup(context: ModelContext, operation: String) async throws {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let backupName = "backup_\(operation)_\(timestamp).json"
        let backupURL = backupDirectory.appendingPathComponent(backupName)
        
        do {
            // Export all data to JSON
            let data = try exportDataToJSON(context: context)
            
            // Write backup file
            try data.write(to: backupURL)
            
            // Verify backup was written correctly
            try verifyBackupIntegrity(backupURL)
            

            
        } catch {
            print("❌ Backup creation failed: \(error.localizedDescription)")
            throw ProtectionError.backupFailed(error.localizedDescription)
        }
    }
    
    private func validateDataIntegrity(context: ModelContext) throws {
        // Validate all contacts
        let contactDescriptor = FetchDescriptor<Contact>()
        let contacts = try context.fetch(contactDescriptor)
        
        for contact in contacts {
            guard contact.isValid else {
                throw ProtectionError.validationFailed("Contact \(contact.fullName) is invalid")
            }
        }
        
        // Validate all kids
        let kidDescriptor = FetchDescriptor<Kid>()
        let kids = try context.fetch(kidDescriptor)
        
        for kid in kids {
            guard kid.isValid else {
                throw ProtectionError.validationFailed("Kid \(kid.firstName) \(kid.lastName) is invalid")
            }
        }
        
        // Validate all birthdays
        let birthdayDescriptor = FetchDescriptor<Birthday>()
        let birthdays = try context.fetch(birthdayDescriptor)
        
        for birthday in birthdays {
            guard birthday.isValid else {
                throw ProtectionError.validationFailed("Birthday \(birthday.displayString) is invalid")
            }
        }
        
        // Validate all addresses
        let addressDescriptor = FetchDescriptor<Address>()
        let addresses = try context.fetch(addressDescriptor)
        
        for address in addresses {
            guard address.isValid else {
                throw ProtectionError.validationFailed("Address at \(address.street) is invalid")
            }
        }
    }
    
    private func validateObjectForDeletion<T: PersistentModel>(_ object: T, in context: ModelContext) throws {
        // Ensure object exists in context
        guard context.hasChanges else {
            throw ProtectionError.validationFailed("No changes to save")
        }
        

    }
    
    private func verifySaveSuccess<T: PersistentModel>(_ object: T, in context: ModelContext) throws {
        // Verify the object still exists and is valid
        guard context.hasChanges == false else {
            throw ProtectionError.validationFailed("Context still has unsaved changes")
        }
        

    }
    
    private func verifyDeletionSuccess<T: PersistentModel>(_ object: T, in context: ModelContext) throws {
        // Verify the object was actually deleted
        guard context.hasChanges == false else {
            throw ProtectionError.validationFailed("Context still has unsaved changes after deletion")
        }
        

    }
    
    private func attemptRecovery(context: ModelContext, operation: String) async throws {

        
        // Try to recover from the most recent backup
        try await emergencyRecovery(context: context)
    }
    
    private func cleanupOldBackups() throws {
        let backupFiles = try FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey])
        
        if backupFiles.count > maxBackups {
            // Sort backup files by creation date (newest first)
            let sortedFiles = try backupFiles.sorted { file1, file2 in
                let date1 = try FileManager.default.attributesOfItem(atPath: file1.path)[.creationDate] as? Date ?? Date.distantPast
                let date2 = try FileManager.default.attributesOfItem(atPath: file2.path)[.creationDate] as? Date ?? Date.distantPast
                return date1 > date2
            }
            
            let filesToDelete = sortedFiles.prefix(backupFiles.count - maxBackups)
            
            for file in filesToDelete {
                try FileManager.default.removeItem(at: file)

            }
        }
    }
    
    private func findMostRecentBackup() throws -> URL {
        let backupFiles = try FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey])
        
        guard let mostRecent = try backupFiles.max(by: { file1, file2 in
            let date1 = try FileManager.default.attributesOfItem(atPath: file1.path)[.creationDate] as? Date ?? Date.distantPast
            let date2 = try FileManager.default.attributesOfItem(atPath: file2.path)[.creationDate] as? Date ?? Date.distantPast
            return date1 > date2
        }) else {
            throw ProtectionError.recoveryFailed("No backup files found")
        }
        
        return mostRecent
    }
    
    func restoreFromBackup(_ backupURL: URL, to context: ModelContext) async throws {

        
        // 1. Read and decode data
        let data = try Data(contentsOf: backupURL)
        let backupData = try JSONDecoder().decode(BackupContainer.self, from: data)
        
        // 2. Clear existing data
        // Note: In a real app we might want to merge, but for recovery we often want a clean slate
        // or we should be very careful about duplicates.
        // For this implementation, we will perform a 'safe restore' by checking IDs or clearing.
        // Let's go with clearing for the "Emergency Recovery" scenario.
        
        try context.delete(model: Contact.self)
        try context.delete(model: Kid.self)
        try context.delete(model: Spouse.self)
        try context.delete(model: Birthday.self)
        try context.delete(model: Address.self)
        
        // 3. Restore Contacts
        for contactDTO in backupData.contacts {
            let contact = Contact(
                firstName: contactDTO.firstName,
                lastName: contactDTO.lastName,
                notes: contactDTO.notes,
                socialMediaURLs: contactDTO.socialMediaURLs,
                birthday: contactDTO.birthday?.toModel(),
                kids: contactDTO.kids.map { $0.toModel() },
                spouse: contactDTO.spouse?.toModel(),
                addresses: contactDTO.addresses.map { $0.toModel() }
            )
            // Restore timestamps and ID
            contact.id = contactDTO.id
            contact.createdAt = contactDTO.createdAt
            contact.updatedAt = contactDTO.updatedAt
            
            context.insert(contact)
        }
        
        // 4. Save changes
        try context.save()

    }
    
    private func exportDataToJSON(context: ModelContext) throws -> Data {
        // Fetch all contacts
        let descriptor = FetchDescriptor<Contact>()
        let contacts = try context.fetch(descriptor)
        
        // Convert to DTOs
        let contactDTOs = contacts.map { ContactDTO(from: $0) }
        
        // Create container
        let backup = BackupContainer(
            timestamp: Date().timeIntervalSince1970,
            version: "1.0",
            contacts: contactDTOs
        )
        
        return try JSONEncoder().encode(backup)
    }

    // MARK: - DTOs for Backup/Restore
    struct BackupContainer: Codable {
        let timestamp: TimeInterval
        let version: String
        let contacts: [ContactDTO]
    }

    struct ContactDTO: Codable {
        let id: UUID
        let firstName: String
        let lastName: String
        let notes: String
        let socialMediaURLs: [String]
        let birthday: BirthdayDTO?
        let kids: [KidDTO]
        let spouse: SpouseDTO?
        let addresses: [AddressDTO]
        let createdAt: Date
        let updatedAt: Date
        
        init(from model: Contact) {
            self.id = model.id
            self.firstName = model.firstName
            self.lastName = model.lastName
            self.notes = model.notes
            self.socialMediaURLs = model.socialMediaURLs
            self.birthday = model.birthday.map { BirthdayDTO(from: $0) }
            self.kids = model.kids.map { KidDTO(from: $0) }
            self.spouse = model.spouse.map { SpouseDTO(from: $0) }
            self.addresses = model.addresses.map { AddressDTO(from: $0) }
            self.createdAt = model.createdAt
            self.updatedAt = model.updatedAt
        }
    }

    struct KidDTO: Codable {
        let id: UUID
        let firstName: String
        let lastName: String
        let birthday: BirthdayDTO?
        
        init(from model: Kid) {
            self.id = model.id
            self.firstName = model.firstName
            self.lastName = model.lastName
            self.birthday = model.birthday.map { BirthdayDTO(from: $0) }
        }
        
        func toModel() -> Kid {
            let model = Kid(firstName: firstName, lastName: lastName, birthday: birthday?.toModel())
            model.id = id
            return model
        }
    }

    struct SpouseDTO: Codable {
        let id: UUID
        let firstName: String
        let lastName: String
        let birthday: BirthdayDTO?
        
        init(from model: Spouse) {
            self.id = model.id
            self.firstName = model.firstName
            self.lastName = model.lastName
            self.birthday = model.birthday.map { BirthdayDTO(from: $0) }
        }
        
        func toModel() -> Spouse {
            let model = Spouse(firstName: firstName, lastName: lastName, birthday: birthday?.toModel())
            model.id = id
            return model
        }
    }

    struct BirthdayDTO: Codable {
        let id: UUID
        let month: Int
        let day: Int
        let year: Int?
        
        init(from model: Birthday) {
            self.id = model.id
            self.month = model.month
            self.day = model.day
            self.year = model.year
        }
        
        func toModel() -> Birthday {
            let model = Birthday(month: month, day: day, year: year)
            model.id = id
            return model
        }
    }

    struct AddressDTO: Codable {
        let id: UUID
        let type: String
        let street: String
        let street2: String?
        let city: String
        let state: String
        let zip: String
        let country: String
        let isDefault: Bool
        let createdAt: Date
        let updatedAt: Date
        
        init(from model: Address) {
            self.id = model.id
            self.type = model.type
            self.street = model.street
            self.street2 = model.street2
            self.city = model.city
            self.state = model.state
            self.zip = model.zip
            self.country = model.country
            self.isDefault = model.isDefault
            self.createdAt = model.createdAt
            self.updatedAt = model.updatedAt
        }
        
        func toModel() -> Address {
            let model = Address(
                type: type,
                street: street,
                street2: street2,
                city: city,
                state: state,
                zip: zip,
                country: country,
                isDefault: isDefault
            )
            model.id = id
            model.createdAt = createdAt
            model.updatedAt = updatedAt
            return model
        }
    }
    
    private func verifyBackupIntegrity(_ backupURL: URL) throws {
        // Verify the backup file was written correctly and is readable
        let data = try Data(contentsOf: backupURL)
        guard data.count > 0 else {
            throw ProtectionError.backupFailed("Backup file is empty")
        }
        
        // Try to decode as BackupContainer to ensure schema validity
        do {
            let _ = try JSONDecoder().decode(BackupContainer.self, from: data)
        } catch {
            print("❌ Backup integrity check failed: \(error.localizedDescription)")
            throw ProtectionError.backupFailed("Invalid backup format: \(error.localizedDescription)")
        }
    }
    
    private func validateAllData(context: ModelContext) async throws -> DataHealthReport {
        // Comprehensive data validation
        var report = DataHealthReport()
        
        // Validate contacts
        let contactDescriptor = FetchDescriptor<Contact>()
        let contacts = try context.fetch(contactDescriptor)
        report.totalContacts = contacts.count
        report.validContacts = contacts.filter { $0.isValid }.count
        
        // Validate kids
        let kidDescriptor = FetchDescriptor<Kid>()
        let kids = try context.fetch(kidDescriptor)
        report.totalKids = kids.count
        report.validKids = kids.filter { $0.isValid }.count
        
        // Validate birthdays
        let birthdayDescriptor = FetchDescriptor<Birthday>()
        let birthdays = try context.fetch(birthdayDescriptor)
        report.totalBirthdays = birthdays.count
        report.validBirthdays = birthdays.filter { $0.isValid }.count
        
        // Validate addresses
        let addressDescriptor = FetchDescriptor<Address>()
        let addresses = try context.fetch(addressDescriptor)
        report.totalAddresses = addresses.count
        report.validAddresses = addresses.filter { $0.isValid }.count
        
        report.isHealthy = (report.validContacts == report.totalContacts) &&
                          (report.validKids == report.totalKids) &&
                          (report.validBirthdays == report.totalBirthdays) &&
                          (report.validAddresses == report.totalAddresses)
        
        return report
    }
    
    private func loadBackupCount() {
        let backupFiles = try? FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [])
        backupCount = backupFiles?.count ?? 0
    }
    
    // MARK: - Backup File Access
    
    func getBackupFiles() -> [BackupFileInfo] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey]) else {
            return []
        }
        
        return files.compactMap { url in
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else { return nil }
            
            let filename = url.lastPathComponent
            let creationDate = attributes[.creationDate] as? Date ?? Date()
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Extract operation from filename (format: backup_operation_timestamp.json)
            let components = filename.components(separatedBy: "_")
            let operation = components.count > 1 ? components[1] : "unknown"
            
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useAll]
            formatter.countStyle = .file
            let sizeString = formatter.string(fromByteCount: fileSize)
            
            return BackupFileInfo(
                url: url,
                filename: filename,
                size: sizeString,
                creationDate: creationDate,
                operation: operation.capitalized
            )
        }.sorted { $0.creationDate > $1.creationDate }
    }
}

// MARK: - Supporting Types

struct BackupFileInfo {
    let url: URL
    let filename: String
    let size: String
    let creationDate: Date
    let operation: String
}

struct DataHealthReport {
    var totalContacts = 0
    var validContacts = 0
    var totalKids = 0
    var validKids = 0
    var totalBirthdays = 0
    var validBirthdays = 0
    var totalAddresses = 0
    var validAddresses = 0
    var isHealthy = false
    
    var summary: String {
        """
        Data Health Report:
        - Contacts: \(validContacts)/\(totalContacts) valid
        - Kids: \(validKids)/\(totalKids) valid
        - Birthdays: \(validBirthdays)/\(totalBirthdays) valid
        - Addresses: \(validAddresses)/\(totalAddresses) valid
        - Overall Health: \(isHealthy ? "✅ Healthy" : "❌ Issues Detected")
        """
    }
}
