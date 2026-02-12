import XCTest
@testable import NeuralGateAI
@testable import NeuralGate

final class TelemetryTests: XCTestCase {
    var telemetry: Telemetry!
    
    override func setUp() {
        telemetry = Telemetry.shared
        telemetry.clear()
    }
    
    override func tearDown() {
        telemetry.clear()
    }
    
    // MARK: - Initialization Tests
    
    func testTelemetryEnabled() {
        #if DISABLE_TELEMETRY
        XCTAssertFalse(telemetry.isEnabled, "Telemetry should be disabled with DISABLE_TELEMETRY flag")
        #else
        XCTAssertTrue(telemetry.isEnabled, "Telemetry should be enabled by default")
        #endif
    }
    
    // MARK: - Routing Decision Tests
    
    func testRecordRoutingDecision() {
        telemetry.recordRoutingDecision(
            mode: .local,
            score: 0.45,
            thermalState: .nominal,
            timestamp: Date()
        )
        
        let stats = telemetry.getRoutingStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            if let stats = stats {
                XCTAssertEqual(stats.totalDecisions, 1)
                XCTAssertEqual(stats.medianComplexity, 0.45, accuracy: 0.01)
                XCTAssertEqual(stats.modeCounts["local"], 1)
            }
        } else {
            XCTAssertNil(stats)
        }
    }
    
    func testMultipleRoutingDecisions() {
        let decisions: [(ExecutionMode, Double)] = [
            (.local, 0.3),
            (.remote, 0.8),
            (.local, 0.2),
            (.remote, 0.9),
            (.local, 0.4)
        ]
        
        for (mode, score) in decisions {
            telemetry.recordRoutingDecision(
                mode: mode,
                score: score,
                thermalState: .nominal
            )
        }
        
        let stats = telemetry.getRoutingStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            if let stats = stats {
                XCTAssertEqual(stats.totalDecisions, 5)
                XCTAssertEqual(stats.modeCounts["local"], 3)
                XCTAssertEqual(stats.modeCounts["remote"], 2)
                
                // Median of [0.2, 0.3, 0.4, 0.8, 0.9] = 0.4
                XCTAssertEqual(stats.medianComplexity, 0.4, accuracy: 0.01)
                
                // Average = (0.2 + 0.3 + 0.4 + 0.8 + 0.9) / 5 = 2.6 / 5 = 0.52
                XCTAssertEqual(stats.averageComplexity, 0.52, accuracy: 0.01)
            }
        }
    }
    
    // MARK: - Remote Call Tests
    
    func testRecordRemoteCallSuccess() {
        telemetry.recordRemoteCallResult(
            success: true,
            latency: 0.5
        )
        
        let stats = telemetry.getRemoteCallStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            if let stats = stats {
                XCTAssertEqual(stats.totalCalls, 1)
                XCTAssertEqual(stats.successRate, 1.0)
                XCTAssertEqual(stats.medianLatency, 0.5, accuracy: 0.01)
            }
        }
    }
    
    func testRecordRemoteCallFailure() {
        telemetry.recordRemoteCallResult(
            success: false,
            latency: 2.0,
            failureReason: "Timeout"
        )
        
        let stats = telemetry.getRemoteCallStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            if let stats = stats {
                XCTAssertEqual(stats.totalCalls, 1)
                XCTAssertEqual(stats.successRate, 0.0)
            }
        }
    }
    
    func testMixedRemoteCalls() {
        let calls: [(Bool, TimeInterval)] = [
            (true, 0.5),
            (true, 0.3),
            (false, 2.0),
            (true, 0.4),
            (false, 1.5)
        ]
        
        for (success, latency) in calls {
            telemetry.recordRemoteCallResult(success: success, latency: latency)
        }
        
        let stats = telemetry.getRemoteCallStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            if let stats = stats {
                XCTAssertEqual(stats.totalCalls, 5)
                
                // 3 successes out of 5 = 0.6 success rate
                XCTAssertEqual(stats.successRate, 0.6, accuracy: 0.01)
                
                // Median of [0.3, 0.4, 0.5, 1.5, 2.0] = 0.5
                XCTAssertEqual(stats.medianLatency, 0.5, accuracy: 0.01)
                
                // Average = (0.5 + 0.3 + 2.0 + 0.4 + 1.5) / 5 = 4.7 / 5 = 0.94
                XCTAssertEqual(stats.averageLatency, 0.94, accuracy: 0.01)
            }
        }
    }
    
    // MARK: - Power State Tests
    
    func testRecordPowerStateChange() {
        telemetry.recordPowerStateChange(
            thermalState: .fair,
            isLowPowerMode: true
        )
        
        // Power state events are recorded but don't have specific statistics
        // Just verify it doesn't crash
    }
    
    // MARK: - Statistics Tests
    
    func testEmptyStatistics() {
        let routingStats = telemetry.getRoutingStatistics()
        let callStats = telemetry.getRemoteCallStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNil(routingStats, "Should return nil when no data")
            XCTAssertNil(callStats, "Should return nil when no data")
        }
    }
    
    func testClearEvents() {
        // Record some events
        telemetry.recordRoutingDecision(mode: .local, score: 0.5, thermalState: .nominal)
        telemetry.recordRemoteCallResult(success: true, latency: 0.5)
        
        // Clear
        telemetry.clear()
        
        // Should have no statistics
        let routingStats = telemetry.getRoutingStatistics()
        let callStats = telemetry.getRemoteCallStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNil(routingStats)
            XCTAssertNil(callStats)
        }
    }
    
    // MARK: - Median Calculation Tests
    
    func testMedianCalculationOddCount() {
        let scores = [0.1, 0.3, 0.5, 0.7, 0.9]
        
        for score in scores {
            telemetry.recordRoutingDecision(mode: .local, score: score, thermalState: .nominal)
        }
        
        let stats = telemetry.getRoutingStatistics()
        
        if telemetry.isEnabled {
            // Median of odd count should be middle value: 0.5
            if let stats = stats {
                XCTAssertEqual(stats.medianComplexity, 0.5, accuracy: 0.01)
            }
        }
    }
    
    func testMedianCalculationEvenCount() {
        let scores = [0.2, 0.4, 0.6, 0.8]
        
        for score in scores {
            telemetry.recordRoutingDecision(mode: .local, score: score, thermalState: .nominal)
        }
        
        let stats = telemetry.getRoutingStatistics()
        
        if telemetry.isEnabled {
            // Median of even count should be average of two middle values: (0.4 + 0.6) / 2 = 0.5
            if let stats = stats {
                XCTAssertEqual(stats.medianComplexity, 0.5, accuracy: 0.01)
            }
        }
    }
    
    // MARK: - Event Storage Limit Tests
    
    func testEventStorageLimit() {
        // Record more than maxStoredEvents (1000)
        for i in 0..<1500 {
            telemetry.recordRoutingDecision(
                mode: .local,
                score: Double(i) / 1500.0,
                thermalState: .nominal
            )
        }
        
        let stats = telemetry.getRoutingStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            // Should only keep last 1000 events
            if let stats = stats {
                XCTAssertEqual(stats.totalDecisions, 1000)
            }
        }
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentRecording() async {
        await withTaskGroup(of: Void.self) { group in
            // Record events from multiple tasks concurrently
            for _ in 0..<10 {
                group.addTask {
                    for _ in 0..<10 {
                        self.telemetry.recordRoutingDecision(
                            mode: .local,
                            score: 0.5,
                            thermalState: .nominal
                        )
                    }
                }
            }
        }
        
        let stats = telemetry.getRoutingStatistics()
        
        if telemetry.isEnabled {
            XCTAssertNotNil(stats)
            if let stats = stats {
                XCTAssertEqual(stats.totalDecisions, 100)
            }
        }
    }
    
    func testConcurrentReadsAndWrites() async {
        await withTaskGroup(of: Void.self) { group in
            // Write events
            for _ in 0..<5 {
                group.addTask {
                    for _ in 0..<20 {
                        self.telemetry.recordRoutingDecision(
                            mode: .local,
                            score: 0.5,
                            thermalState: .nominal
                        )
                    }
                }
            }
            
            // Read statistics concurrently
            for _ in 0..<5 {
                group.addTask {
                    for _ in 0..<10 {
                        let _ = self.telemetry.getRoutingStatistics()
                    }
                }
            }
        }
        
        // Should not crash
    }
}
