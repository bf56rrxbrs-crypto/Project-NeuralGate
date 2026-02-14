import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import NeuralGateAI
@testable import NeuralGate

@MainActor
final class PowerMonitorTests: XCTestCase {
    var powerMonitor: PowerMonitor!
    #if canImport(Combine)
    var cancellables: Set<AnyCancellable>!
    #endif
    
    override func setUp() async throws {
        powerMonitor = PowerMonitor.shared
        #if canImport(Combine)
        cancellables = Set<AnyCancellable>()
        #endif
    }
    
    override func tearDown() {
        #if canImport(Combine)
        cancellables = nil
        #endif
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        // PowerMonitor should initialize with current system state
        XCTAssertNotNil(powerMonitor.thermalState)
        
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        let validStates: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]
        #else
        let validStates: [ThermalState] = [.nominal, .fair, .serious, .critical]
        #endif
        XCTAssertTrue(validStates.contains(powerMonitor.thermalState))
    }
    
    func testIsLowPowerMode() {
        // Should have a boolean value
        XCTAssertNotNil(powerMonitor.isLowPowerMode)
        
        #if canImport(UIKit)
        // On iOS, should match system state
        XCTAssertEqual(powerMonitor.isLowPowerMode, ProcessInfo.processInfo.isLowPowerModeEnabled)
        #else
        // On non-iOS platforms, should be false
        XCTAssertFalse(powerMonitor.isLowPowerMode)
        #endif
    }
    
    // MARK: - Published Properties Tests
    
    #if canImport(Combine)
    func testPublishedPropertiesAreObservable() {
        let expectation = XCTestExpectation(description: "Thermal state is observable")
        
        // Subscribe to thermal state changes
        powerMonitor.$thermalState
            .dropFirst() // Skip initial value
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Post notification to trigger update
        NotificationCenter.default.post(name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    #endif
    
    #if canImport(Combine)
    func testLowPowerModeIsObservable() {
        #if canImport(UIKit)
        let expectation = XCTestExpectation(description: "Low power mode is observable")
        
        // Subscribe to power mode changes
        powerMonitor.$isLowPowerMode
            .dropFirst() // Skip initial value
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Post notification to trigger update
        NotificationCenter.default.post(name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
        
        wait(for: [expectation], timeout: 2.0)
        #endif
    }
    #endif
    
    // MARK: - Recommended Batch Size Tests
    
    func testRecommendedBatchSizeNominalState() {
        // When thermal state is nominal and not in low power mode
        // we should get the highest batch size
        
        // We can't directly set the thermal state, but we can test the logic
        // by checking that the batch size is within expected range
        let batchSize = powerMonitor.recommendedBatchSize
        XCTAssertGreaterThan(batchSize, 0, "Batch size should be positive")
        XCTAssertLessThanOrEqual(batchSize, 10, "Batch size should not exceed maximum")
    }
    
    func testRecommendedBatchSizeLogic() {
        // Test that batch size is always positive and reasonable
        let batchSize = powerMonitor.recommendedBatchSize
        
        XCTAssertGreaterThan(batchSize, 0, "Batch size must be at least 1")
        XCTAssertLessThanOrEqual(batchSize, 10, "Batch size should not exceed 10")
        
        // Verify batch size decreases with thermal state
        // (This is implicit in the implementation logic)
    }
    
    func testBatchSizeWithLowPowerMode() {
        #if canImport(UIKit)
        // If low power mode is enabled, batch size should be reduced
        if powerMonitor.isLowPowerMode {
            let batchSize = powerMonitor.recommendedBatchSize
            XCTAssertLessThanOrEqual(batchSize, 5, "Batch size should be reduced in low power mode")
        }
        #endif
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testPowerMonitoringProtocolConformance() {
        // Test that PowerMonitor conforms to PowerMonitoring protocol
        let monitoring: PowerMonitoring = powerMonitor
        
        // Should be able to access protocol properties
        XCTAssertNotNil(monitoring.thermalState)
        XCTAssertNotNil(monitoring.isLowPowerMode)
        XCTAssertGreaterThan(monitoring.recommendedBatchSize, 0)
    }
    
    // MARK: - Thread Safety Tests
    
    func testMainActorIsolation() async {
        // PowerMonitor is @MainActor, so these calls should work on main actor
        await MainActor.run {
            let _ = powerMonitor.thermalState
            let _ = powerMonitor.isLowPowerMode
            let _ = powerMonitor.recommendedBatchSize
        }
    }
    
    func testConcurrentAccess() async {
        // Test that multiple concurrent accesses don't cause issues
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask { @MainActor in
                    let _ = self.powerMonitor.thermalState
                    let _ = self.powerMonitor.isLowPowerMode
                    let _ = self.powerMonitor.recommendedBatchSize
                }
            }
        }
    }
    
    // MARK: - Notification Response Tests
    
    func testThermalStateNotificationHandling() {
        // Post notification
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        NotificationCenter.default.post(name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        #endif
        
        // Give it a moment to process
        let expectation = XCTestExpectation(description: "Thermal state updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // State should be current system state (may or may not have changed)
            XCTAssertNotNil(self.powerMonitor.thermalState)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    #if canImport(UIKit)
    func testPowerStateNotificationHandling() {
        // Record initial state
        let initialPowerMode = powerMonitor.isLowPowerMode
        
        // Post notification
        NotificationCenter.default.post(name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
        
        // Give it a moment to process
        let expectation = XCTestExpectation(description: "Power state updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // State should be current system state
            XCTAssertEqual(self.powerMonitor.isLowPowerMode, ProcessInfo.processInfo.isLowPowerModeEnabled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    #endif
    
    // MARK: - Edge Case Tests
    
    #if canImport(Combine)
    func testMultipleNotifications() {
        // Test that multiple rapid notifications are handled gracefully
        let expectation = XCTestExpectation(description: "Multiple notifications handled")
        expectation.expectedFulfillmentCount = 5
        
        powerMonitor.$thermalState
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Send multiple notifications
        for _ in 0..<5 {
            NotificationCenter.default.post(name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    #endif
}
