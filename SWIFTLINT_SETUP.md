# SwiftLint Setup for Forgetze

This document explains how to set up SwiftLint for the Forgetze iOS project to maintain code quality and consistency.

## What is SwiftLint?

SwiftLint is a tool to enforce Swift style and conventions. It helps catch potential bugs, maintain consistent code style, and enforce best practices across your codebase.

## Installation Options

### Option 1: Xcode Package Manager (Recommended)

1. Open `Forgetze.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter: `https://github.com/realm/SwiftLint`
4. Click **Add Package**
5. Select **SwiftLint** and click **Add Package**

### Option 2: Homebrew

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install SwiftLint
brew install swiftlint
```

### Option 3: Download Binary

1. Go to [SwiftLint Releases](https://github.com/realm/SwiftLint/releases)
2. Download the latest `.pkg` file
3. Install it

## Xcode Integration

### Add Build Phase

1. Select your **Forgetze** target in Xcode
2. Go to **Build Phases** tab
3. Click **"+"** button → **New Run Script Phase**
4. Name it: **"SwiftLint"**
5. Add this script:

```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

6. **Move the SwiftLint phase** to run before "Compile Sources"

### Test the Setup

Run the test script:
```bash
./run_swiftlint.sh
```

Or run SwiftLint manually:
```bash
swiftlint
```

## Configuration

The project includes a `.swiftlint.yml` configuration file with rules tailored for Forgetze:

### Key Configuration Features

- **Line Length**: 120 characters warning, 150 error
- **File Length**: 400 lines warning, 600 error
- **Function Length**: 50 lines warning, 100 error
- **Custom Rules**: Specific to iOS development patterns
- **Excluded Paths**: Preview Content, Assets, etc.

### Custom Rules

The configuration includes custom rules for:
- Proper error handling (avoiding `fatalError`)
- Memory management best practices
- SwiftUI-specific patterns

## Common Issues and Fixes

### Long Lines
```swift
// ❌ Too long
let veryLongVariableNameThatExceedsTheRecommendedLength = "value"

// ✅ Better
let shortName = "value"
```

### Force Unwrapping
```swift
// ❌ Dangerous
let value = optionalValue!

// ✅ Safer
guard let value = optionalValue else { return }
```

### Unused Variables
```swift
// ❌ Unused
let unusedVariable = "hello"

// ✅ Remove or use
let usedVariable = "hello"
print(usedVariable)
```

## Running SwiftLint

### Command Line
```bash
# Run on entire project
swiftlint

# Run on specific files
swiftlint --path Forgetze/Forgetze/ContactListView.swift

# Auto-fix issues
swiftlint --fix

# Generate report
swiftlint --reporter html > swiftlint-report.html
```

### Xcode Integration

SwiftLint will run automatically during build if you've added the build phase. Issues will appear in Xcode's Issue Navigator.

## Disabling Rules

### For Specific Lines
```swift
// swiftlint:disable:next line_length
let veryLongLine = "This is a very long line that exceeds the recommended length"
```

### For Specific Files
```swift
// swiftlint:disable all
// This file is excluded from SwiftLint
```

### In Configuration
Edit `.swiftlint.yml` to disable rules globally:
```yaml
disabled_rules:
  - trailing_whitespace
  - todo
```

## Benefits for Forgetze

1. **Code Consistency**: All developers follow the same style
2. **Bug Prevention**: Catches potential issues early
3. **Maintainability**: Easier to read and maintain code
4. **Best Practices**: Enforces iOS development best practices
5. **Team Collaboration**: Consistent code across the team

## Troubleshooting

### SwiftLint Not Found
- Ensure SwiftLint is installed: `swiftlint version`
- Check PATH: `which swiftlint`
- Reinstall if necessary

### Build Phase Issues
- Ensure the script is in the correct target
- Check that SwiftLint phase runs before Compile Sources
- Verify script syntax

### Configuration Issues
- Validate YAML syntax in `.swiftlint.yml`
- Check file paths in included/excluded sections
- Test with `swiftlint --config .swiftlint.yml`

## Next Steps

1. Install SwiftLint using one of the methods above
2. Add the build phase to Xcode
3. Run `./run_swiftlint.sh` to test
4. Fix any issues found
5. Customize `.swiftlint.yml` as needed

## Resources

- [SwiftLint GitHub](https://github.com/realm/SwiftLint)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Configuration Options](https://github.com/realm/SwiftLint#configuration)
