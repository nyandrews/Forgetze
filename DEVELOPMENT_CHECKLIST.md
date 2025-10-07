# Forgetze Development Checklist

## 🚨 Before Starting Any SwiftData-Related Work

### Pre-Development:
- [ ] Read `SWIFTDATA_BEST_PRACTICES.md`
- [ ] Use `SWIFTDATA_VIEW_TEMPLATE.swift` for new views
- [ ] Understand the detached data pattern used in ContactDetailView

### During Development:
- [ ] Never access SwiftData relationships directly in views
- [ ] Always use local variables for SwiftData property access
- [ ] Implement lazy loading for NavigationLink destinations
- [ ] Add debug logging to track view initialization patterns
- [ ] Test navigation thoroughly (tap → view → back → repeat)

### Before Committing:
- [ ] Check console logs for multiple view initializations
- [ ] Verify no SwiftData detachment errors
- [ ] Test the specific scenario that caused the original issue
- [ ] Ensure smooth navigation without crashes
- [ ] Document any SwiftData-related changes

## 🔍 Debugging Checklist

### If You See These Warning Signs:
- [ ] Multiple "View initialized" messages in console
- [ ] SwiftData/BackingData.swift fatal errors
- [ ] "detached from a context" error messages
- [ ] App crashes when navigating back

### Debugging Steps:
1. [ ] Check console logs for initialization patterns
2. [ ] Identify which SwiftData properties are being accessed
3. [ ] Look for direct relationship access in views
4. [ ] Check if NavigationLink destinations are being pre-created
5. [ ] Implement detached data solution if needed

## 📝 Code Review Checklist

### For SwiftData Views:
- [ ] Are SwiftData relationships accessed directly?
- [ ] Is lazy loading implemented?
- [ ] Are local variables used for property access?
- [ ] Is detached data used for complex views?
- [ ] Are there multiple initializations in logs?

### For Navigation:
- [ ] Are NavigationLink destinations lazy-loaded?
- [ ] Is there debug logging for navigation events?
- [ ] Does navigation work smoothly in both directions?
- [ ] Are there any pre-creation issues?

## 🚀 Success Criteria

A successful implementation should have:
- [ ] Single view initialization per user action
- [ ] No SwiftData detachment errors in console
- [ ] Smooth navigation without crashes
- [ ] Clean, maintainable code structure
- [ ] Proper debug logging for troubleshooting

## ⚠️ Red Flags - Stop and Fix Immediately

If you see any of these, stop development and fix:
- [ ] Multiple view initializations for the same entity
- [ ] SwiftData detachment errors
- [ ] App crashes during navigation
- [ ] Direct SwiftData relationship access in views
- [ ] NavigationLink destinations being created for all items

## 📚 Resources

- `SWIFTDATA_BEST_PRACTICES.md` - Best practices guide
- `SWIFTDATA_VIEW_TEMPLATE.swift` - Template for safe views
- ContactDetailView implementation - Working example of detached data pattern











