# Database Migration Guide

## Overview

This guide explains how to safely modify the database schema in Forgetze without losing user data. The app uses SwiftData with a custom migration system that ensures data preservation during schema changes.

## Migration System Components

### 1. SchemaVersionManager
- Tracks current database schema version
- Detects when migrations are needed
- Stores version information in UserDefaults

### 2. DatabaseMigrationManager
- Executes migration logic
- Creates pre-migration backups
- Handles rollback on failure
- Verifies data integrity

### 3. DataProtectionManager
- Enhanced with migration-specific backup methods
- Creates special migration backups with metadata
- Provides rollback capabilities

## Safe Schema Changes

These changes are **automatically handled** by SwiftData and **will NOT lose data**:

### ✅ Adding Optional Properties
```swift
// Before
@Model
class Contact {
    var name: String = ""
}

// After - SAFE
@Model
class Contact {
    var name: String = ""
    var newField: String? = nil  // Optional with default
}
```

### ✅ Adding Default Values
```swift
// Before
@Model
class Contact {
    var name: String = ""
}

// After - SAFE
@Model
class Contact {
    var name: String = ""
    var isActive: Bool = true  // Default value
}
```

### ✅ Adding New Models
```swift
// Adding a new model is always safe
@Model
class NewModel {
    var id = UUID()
    var data: String = ""
}
```

### ✅ Adding New Relationships
```swift
// Before
@Model
class Contact {
    var name: String = ""
}

// After - SAFE
@Model
class Contact {
    var name: String = ""
    @Relationship var newItems: [NewItem]? = []  // New relationship
}
```

## Risky Schema Changes

These changes **require migration code** and **could lose data** without proper handling:

### ⚠️ Renaming Properties
```swift
// Before
@Model
class Contact {
    var firstName: String = ""
}

// After - RISKY (needs migration)
@Model
class Contact {
    var givenName: String = ""  // Renamed from firstName
}
```

**Migration Code Required:**
```swift
private func migrateToV2(context: ModelContext) async throws {
    let contacts = try context.fetch(FetchDescriptor<Contact>())
    
    for contact in contacts {
        // Copy data from old property to new property
        contact.givenName = contact.firstName  // This won't work - need different approach
        // Actually, you'd need to read from the old schema and write to new
    }
}
```

### ⚠️ Changing Property Types
```swift
// Before
@Model
class Contact {
    var age: String = ""  // Stored as string
}

// After - RISKY (needs migration)
@Model
class Contact {
    var age: Int = 0  // Changed to integer
}
```

### ⚠️ Making Optional → Required
```swift
// Before
@Model
class Contact {
    var email: String? = nil  // Optional
}

// After - RISKY (needs migration)
@Model
class Contact {
    var email: String = ""  // Required with default
}
```

### ⚠️ Removing Properties
```swift
// Before
@Model
class Contact {
    var oldField: String = ""
    var name: String = ""
}

// After - RISKY (data will be lost)
@Model
class Contact {
    var name: String = ""
    // oldField removed
}
```

## Breaking Changes

These changes require **careful planning** and **extensive testing**:

### 🚨 Changing Relationship Types
- One-to-one → One-to-many
- Many-to-many → One-to-many
- Adding/removing cascade rules

### 🚨 Removing Models
- Deleting entire model classes
- Changing model inheritance

### 🚨 Major Structural Changes
- Changing primary keys
- Modifying SwiftData annotations

## How to Add a New Migration

### Step 1: Update Schema Version
```swift
// In SchemaVersioning.swift
static let currentSchemaVersion = 2  // Increment from 1 to 2
```

### Step 2: Add Migration Logic
```swift
// In DatabaseMigrations.swift
private func performMigrationSteps(from: Int, to: Int, context: ModelContext) async throws {
    // Existing migrations...
    
    // Add new migration
    if from == 1 && to == 2 {
        try await migrateToV2(context: context)
    }
}

private func migrateToV2(context: ModelContext) async throws {
    print("🔄 Migrating to v2: [Describe your changes]")
    
    // Your migration logic here
    let contacts = try context.fetch(FetchDescriptor<Contact>())
    
    for contact in contacts {
        // Transform data as needed
        contact.schemaVersion = 2  // Update version
        contact.updatedAt = Date()
    }
    
    try context.save()
    print("✅ v2 migration completed")
}
```

### Step 3: Update Schema History
```swift
// In SchemaVersioning.swift - update the history comment
/**
 * Schema Version History
 * 
 * Version 1: Initial schema with Contact, Kid, Birthday, Address models
 * Version 2: Added newField to Contact model, updated validation rules
 * Version 3: [Future changes]
 */
```

### Step 4: Test Migration
1. Create test data with old schema
2. Run migration
3. Verify all data preserved
4. Test rollback scenario

## Migration Checklist

Before making any schema changes:

- [ ] **Backup current data** (automatic with our system)
- [ ] **Determine if migration is needed**
  - [ ] Safe change? → No migration needed
  - [ ] Risky change? → Write migration code
  - [ ] Breaking change? → Plan carefully
- [ ] **Update schema version** if needed
- [ ] **Write migration logic** if needed
- [ ] **Test migration thoroughly**
  - [ ] Test with empty database
  - [ ] Test with sample data
  - [ ] Test with real user data patterns
  - [ ] Test rollback scenario
- [ ] **Update documentation**
- [ ] **Deploy with monitoring**

## Testing Migrations

### Create Test Data
```swift
// Create test contacts with old schema
let testContact = Contact(
    firstName: "Test",
    lastName: "User",
    // ... other fields
)
```

### Run Migration
```swift
// Test migration
let success = await DatabaseMigrationManager.shared.executeMigrationIfNeeded(context: context)
XCTAssertTrue(success, "Migration should succeed")
```

### Verify Data
```swift
// Verify data preserved
let contacts = try context.fetch(FetchDescriptor<Contact>())
XCTAssertEqual(contacts.count, expectedCount)
// Verify specific fields
```

## Error Handling

The migration system includes comprehensive error handling:

1. **Pre-migration backup** - Always created before migration
2. **Rollback on failure** - Restores backup if migration fails
3. **Data integrity verification** - Checks data after migration
4. **User notification** - Shows migration status and errors

## Best Practices

### Do's ✅
- Always test migrations with real data patterns
- Keep migrations simple and focused
- Use descriptive migration names and comments
- Verify data integrity after migration
- Plan for rollback scenarios
- Document all schema changes

### Don'ts ❌
- Never make breaking changes without migration code
- Don't skip testing with real user data
- Don't assume SwiftData handles everything automatically
- Don't ignore migration failures
- Don't remove properties without preserving data first

## Emergency Procedures

### If Migration Fails
1. Check console logs for specific error
2. Migration system will automatically rollback
3. User data should be preserved
4. Fix migration code and try again

### If Data is Lost
1. Check for migration backup files
2. Use DataProtectionManager to restore
3. Contact user if necessary
4. Implement additional safeguards

## Future Considerations

- Consider implementing schema validation
- Add migration progress indicators for users
- Implement automatic migration testing in CI/CD
- Add migration performance monitoring
- Consider schema versioning in backups

---

**Remember: User data is sacred. When in doubt, err on the side of caution and preserve data.**
























