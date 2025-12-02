# SwiftData Best Practices for Forgetze

## 🚨 Critical Rules to Prevent Detachment Issues

### 1. **Never Access SwiftData Relationships Directly in Views**
```swift
// ❌ BAD - Can cause detachment errors
ForEach(contact.socialMediaURLs, id: \.self) { url in
    Text(url)
}

// ✅ GOOD - Use local variables
let urls = contact.socialMediaURLs
ForEach(urls, id: \.self) { url in
    Text(url)
}
```

### 2. **Use Detached Data Structures for Complex Views**
```swift
// ✅ GOOD - Detached data structure
struct DetachedContactData {
    let socialMediaURLs: [String]
    let kids: [Kid]
    // ... other properties
    
    init(from contact: Contact) {
        // Capture all data immediately
        self.socialMediaURLs = contact.socialMediaURLs
        self.kids = Array(contact.kids)
    }
}
```

### 3. **Implement Lazy Loading for Navigation Destinations**
```swift
// ✅ GOOD - Lazy loading prevents pre-creation
struct LazyContactDetailView: View {
    @State private var detachedData: DetachedContactData?
    
    var body: some View {
        Group {
            if let data = detachedData {
                DetachedContactDetailView(data: data)
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            detachedData = DetachedContactData(from: contact)
        }
    }
}
```

### 4. **Safe Property Access Patterns**
```swift
// ✅ GOOD - Safe access with local variables
var hasSocialMedia: Bool {
    let urls = socialMediaURLs
    return !urls.filter { !$0.isEmpty }.isEmpty
}

// ✅ GOOD - Safe access in computed properties
var kidsCount: Int {
    let children = kids
    return children.count
}
```

## 🔍 Debugging SwiftData Issues

### Warning Signs:
- Multiple view initializations in console logs
- SwiftData/BackingData.swift fatal errors
- "detached from a context" error messages
- App crashes when navigating back

### Debug Tools:
```swift
// Add to view initializers
init(contact: Contact) {
    self.contact = contact
    print("📱 View initialized for: \(contact.displayName)")
}

// Add to onAppear
.onAppear {
    print("📱 View appeared for: \(contact.displayName)")
}
```

## 📝 Code Review Checklist

Before committing SwiftData-related changes:
- [ ] Are SwiftData relationships accessed directly in views?
- [ ] Are there multiple view initializations in logs?
- [ ] Is lazy loading implemented for navigation destinations?
- [ ] Are local variables used for SwiftData property access?
- [ ] Is detached data used for complex views?

## 🚀 Implementation Guidelines

### For New Features:
1. **Always use detached data structures** for views that display SwiftData relationships
2. **Implement lazy loading** for NavigationLink destinations
3. **Use local variables** for SwiftData property access
4. **Add debug logging** to track view initialization patterns

### For Bug Fixes:
1. **Identify the root cause** - is it SwiftData detachment?
2. **Use detached data approach** - don't try to fix SwiftData access
3. **Test thoroughly** - ensure no multiple initializations
4. **Document the fix** - explain why detached data was used

## ⚠️ Common Pitfalls to Avoid

1. **Don't try to fix SwiftData detachment with do-catch blocks** - property access doesn't throw errors
2. **Don't use complex wrappers** - keep solutions simple and direct
3. **Don't ignore multiple initializations** - they indicate pre-creation issues
4. **Don't access SwiftData relationships in computed properties** - use local variables instead

## 🎯 Success Metrics

A successful SwiftData implementation should have:
- Single view initialization per user action
- No SwiftData detachment errors in console
- Smooth navigation without crashes
- Clean, maintainable code structure







































