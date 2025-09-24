#!/bin/bash

# SwiftLint Test Script for Forgetze
# Run this script to test SwiftLint on your project

echo "🔍 Running SwiftLint on Forgetze project..."
echo "📁 Project directory: $(pwd)"
echo ""

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed!"
    echo "Please install SwiftLint first:"
    echo "  Option 1: brew install swiftlint"
    echo "  Option 2: Download from https://github.com/realm/SwiftLint/releases"
    echo "  Option 3: Add via Xcode Package Manager"
    exit 1
fi

echo "✅ SwiftLint found: $(swiftlint version)"
echo ""

# Run SwiftLint
echo "🚀 Running SwiftLint analysis..."
swiftlint

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SwiftLint completed successfully - no issues found!"
else
    echo ""
    echo "⚠️  SwiftLint found some issues. Check the output above for details."
    echo "💡 You can fix these issues or adjust the .swiftlint.yml configuration."
fi

echo ""
echo "📋 Configuration file: .swiftlint.yml"
echo "🔧 To customize rules, edit the .swiftlint.yml file in your project root."
