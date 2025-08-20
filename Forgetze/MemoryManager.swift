import Foundation
import UIKit
import SwiftData

@MainActor
class MemoryManager: ObservableObject {
    static let shared = MemoryManager()
    
    @Published var currentMemoryUsage: UInt64 = 0
    @Published var memoryPressure: MemoryPressure = .normal
    @Published var isPerformingCleanup = false
    
    private var memoryWarningObserver: NSObjectProtocol?
    private var appStateObserver: NSObjectProtocol?
    private var cleanupTimer: Timer?
    
    enum MemoryPressure {
        case low, normal, high, critical
        
        var threshold: UInt64 {
            switch self {
            case .low: return 50 * 1024 * 1024      // 50 MB
            case .normal: return 100 * 1024 * 1024   // 100 MB
            case .high: return 200 * 1024 * 1024     // 200 MB
            case .critical: return 300 * 1024 * 1024 // 300 MB
            }
        }
    }
    
    private init() {
        setupMemoryMonitoring()
        startPeriodicCleanup()
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    // MARK: - Memory Monitoring Setup
    
    private func setupMemoryMonitoring() {
        // Monitor memory warnings
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task<Void, Never> { @MainActor in
                self.handleMemoryWarning()
            }
        }
        
        // Monitor app state changes
        appStateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task<Void, Never> { @MainActor in
                self.performBackgroundCleanup()
            }
        }
        
        // Monitor app becoming active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task<Void, Never> { @MainActor in
                self.checkMemoryStatus()
            }
        }
    }
    
    private func removeObservers() {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Memory Status Monitoring
    
    func checkMemoryStatus() {
        let usage = getCurrentMemoryUsage()
        currentMemoryUsage = usage
        
        // Update memory pressure level
        if usage < MemoryPressure.low.threshold {
            memoryPressure = .low
        } else if usage < MemoryPressure.normal.threshold {
            memoryPressure = .normal
        } else if usage < MemoryPressure.high.threshold {
            memoryPressure = .high
        } else {
            memoryPressure = .critical
        }
        
        // Trigger cleanup if needed
        if memoryPressure == .high || memoryPressure == .critical {
            performAggressiveCleanup()
        }
    }
    
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    // MARK: - Memory Cleanup Strategies
    
    func performLightCleanup() {
        guard !isPerformingCleanup else { return }
        isPerformingCleanup = true
        
        autoreleasepool {
            // Force immediate cleanup of autoreleased objects
        }
        
        // Clear image caches if available
        clearImageCaches()
        
        // Small delay to allow cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isPerformingCleanup = false
        }
    }
    
    func performAggressiveCleanup() {
        guard !isPerformingCleanup else { return }
        isPerformingCleanup = true
        
        print("🧹 Performing aggressive memory cleanup...")
        
        // Multiple autorelease pool cycles
        for _ in 1...3 {
            autoreleasepool {
                // Force cleanup
            }
        }
        
        // Clear all caches
        clearImageCaches()
        clearSearchCaches()
        
        // Request system cleanup
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                // Background cleanup
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task<Void, Never> { @MainActor in
                self.isPerformingCleanup = false
                self.checkMemoryStatus()
            }
        }
    }
    
    func performBackgroundCleanup() {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                // Background memory cleanup
                DispatchQueue.main.async {
                    self.clearImageCaches()
                    self.clearSearchCaches()
                }
            }
        }
    }
    
    // MARK: - Cache Management
    
    private func clearImageCaches() {
        // Clear any image caches
        URLCache.shared.removeAllCachedResponses()
    }
    
    private func clearSearchCaches() {
        // Clear search-related caches
        // This will be implemented when we add search caching
    }
    
    // MARK: - Memory Warning Handling
    
    private func handleMemoryWarning() {
        print("⚠️ Memory warning received - performing emergency cleanup")
        performAggressiveCleanup()
    }
    
    // MARK: - Periodic Cleanup
    
    private func startPeriodicCleanup() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.performLightCleanup()
            }
        }
    }
    
    // MARK: - Batch Processing Support
    
    func processBatch<T>(_ items: [T], batchSize: Int = 10, operation: @escaping (T) -> Void) async {
        let totalBatches = (items.count + batchSize - 1) / batchSize
        
        for batchIndex in 0..<totalBatches {
            let startIndex = batchIndex * batchSize
            let endIndex = min(startIndex + batchSize, items.count)
            let batch = Array(items[startIndex..<endIndex])
            
            // Process batch
            autoreleasepool {
                for item in batch {
                    operation(item)
                }
            }
            
            // Save progress if needed
            if batchIndex % 5 == 0 {
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms delay
            }
        }
    }
    
    // MARK: - Lazy Loading Support
    
    func shouldLoadMoreItems(currentCount: Int, totalAvailable: Int, memoryPressure: MemoryPressure) -> Bool {
        switch memoryPressure {
        case .low:
            return currentCount < totalAvailable
        case .normal:
            return currentCount < min(totalAvailable, 50)
        case .high:
            return currentCount < min(totalAvailable, 25)
        case .critical:
            return currentCount < min(totalAvailable, 10)
        }
    }
}

// MARK: - Memory-Efficient Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
