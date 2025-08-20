import XCTest
import Foundation

/// Test Configuration for Forgetze App
/// This file configures automated test execution and reporting
final class TestConfiguration {
    
    // MARK: - Test Execution Configuration
    
    /// Enable automatic test execution on build
    static let enableAutoTestExecution = true
    
    /// Enable test coverage reporting
    static let enableTestCoverage = true
    
    /// Enable performance testing
    static let enablePerformanceTesting = true
    
    /// Test timeout configuration
    static let defaultTimeout: TimeInterval = 10.0
    static let searchTimeout: TimeInterval = 5.0
    static let uiTimeout: TimeInterval = 15.0
    
    // MARK: - Test Data Configuration
    
    /// Number of test contacts to create for performance testing
    static let performanceTestContactCount = 1000
    
    /// Test search queries for performance testing
    static let performanceTestQueries = [
        "John",
        "Smith",
        "Engineer",
        "Manager",
        "Designer"
    ]
    
    // MARK: - Performance Thresholds
    
    /// Maximum acceptable app launch time (seconds)
    static let maxAppLaunchTime: TimeInterval = 3.0
    
    /// Maximum acceptable search response time (seconds)
    static let maxSearchResponseTime: TimeInterval = 0.5
    
    /// Maximum acceptable UI navigation time (seconds)
    static let maxNavigationTime: TimeInterval = 1.0
    
    // MARK: - Test Categories
    
    enum TestCategory: String, CaseIterable {
        case unit = "Unit Tests"
        case integration = "Integration Tests"
        case ui = "UI Tests"
        case performance = "Performance Tests"
        case accessibility = "Accessibility Tests"
    }
    
    /// Get test categories to run
    static func getTestCategories() -> [TestCategory] {
        return TestCategory.allCases
    }
    
    // MARK: - Test Environment
    
    /// Check if running in test environment
    static var isTestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    /// Check if running in UI test environment
    static var isUITestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCUIApplication"] != nil
    }
    
    // MARK: - Test Reporting
    
    /// Generate test report summary
    static func generateTestReport() -> String {
        let categories = getTestCategories()
        let environment = isTestEnvironment ? "Test" : "Production"
        let uiTest = isUITestEnvironment ? "UI Test" : "Unit Test"
        
        return """
        🧪 Forgetze Test Report
        
        Environment: \(environment)
        Test Type: \(uiTest)
        Categories: \(categories.map { $0.rawValue }.joined(separator: ", "))
        
        Performance Thresholds:
        - App Launch: \(maxAppLaunchTime)s
        - Search Response: \(maxSearchResponseTime)s
        - Navigation: \(maxNavigationTime)s
        
        Auto-execution: \(enableAutoTestExecution ? "Enabled" : "Disabled")
        Coverage: \(enableTestCoverage ? "Enabled" : "Disabled")
        Performance Testing: \(enablePerformanceTesting ? "Enabled" : "Disabled")
        """
    }
}

// MARK: - Test Helper Extensions

extension XCTestCase {
    
    /// Wait for a condition with custom timeout
    func waitForCondition(_ condition: @escaping () -> Bool, timeout: TimeInterval = TestConfiguration.defaultTimeout) {
        let expectation = XCTestExpectation(description: "Condition met")
        
        DispatchQueue.global(qos: .background).async {
            while !condition() {
                Thread.sleep(forTimeInterval: 0.1)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Measure performance with custom threshold
    func measurePerformance(threshold: TimeInterval, operation: String, block: @escaping () -> Void) {
        measure(metrics: [XCTClockMetric()]) {
            block()
        }
        
        // Additional threshold check
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        XCTAssertLessThan(executionTime, threshold, "\(operation) exceeded threshold of \(threshold)s")
    }
    
    /// Create test contacts for performance testing
    func createTestContacts(count: Int) -> [Contact] {
        return (1...count).map { i in
            Contact(
                firstName: "Test\(i)",
                lastName: "User\(i)",
                notes: "Test contact \(i) for performance testing"
            )
        }
    }
    
    /// Verify test environment
    func verifyTestEnvironment() {
        XCTAssertTrue(TestConfiguration.isTestEnvironment, "Tests should run in test environment")
    }
}


