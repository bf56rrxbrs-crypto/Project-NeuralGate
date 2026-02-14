import XCTest
@testable import NeuralGateAI
@testable import NeuralGate

final class CircuitBreakerTests: XCTestCase {
    
    // MARK: - Basic State Tests
    
    func testInitialState() async {
        let breaker = CircuitBreaker(failureThreshold: 3, timeout: 5.0)
        let status = await breaker.getStatus()
        
        XCTAssertEqual(status.state, .closed, "Circuit should start in closed state")
        XCTAssertEqual(status.failures, 0, "Should start with zero failures")
    }
    
    func testSuccessfulOperation() async {
        let breaker = CircuitBreaker()
        
        let result = await breaker.execute(
            operation: { return "success" },
            fallback: { return "fallback" }
        )
        
        XCTAssertEqual(result, "success", "Should return operation result on success")
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.state, .closed)
        XCTAssertEqual(status.failures, 0)
    }
    
    // MARK: - Failure Tracking Tests
    
    func testSingleFailure() async {
        let breaker = CircuitBreaker(failureThreshold: 3)
        
        _ = await breaker.execute(
            operation: { throw NSError(domain: "test", code: 1) },
            fallback: { return "fallback" }
        )
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.failures, 1, "Should record one failure")
        XCTAssertEqual(status.state, .closed, "Should remain closed after single failure")
    }
    
    func testFailureThresholdOpensCircuit() async {
        let breaker = CircuitBreaker(failureThreshold: 3)
        
        // Fail 3 times to reach threshold
        for _ in 0..<3 {
            _ = await breaker.execute(
                operation: { throw NSError(domain: "test", code: 1) },
                fallback: { return "fallback" }
            )
        }
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.state, .open, "Circuit should open after reaching failure threshold")
        XCTAssertEqual(status.failures, 3)
    }
    
    func testOpenCircuitUsesFallback() async {
        let breaker = CircuitBreaker(failureThreshold: 2)
        
        // Open the circuit with failures
        for _ in 0..<2 {
            _ = await breaker.execute(
                operation: { throw NSError(domain: "test", code: 1) },
                fallback: { return "fallback" }
            )
        }
        
        // Verify circuit is open
        let status = await breaker.getStatus()
        XCTAssertEqual(status.state, .open)
        
        // Next call should use fallback without trying operation
        var operationCalled = false
        let result = await breaker.execute(
            operation: {
                operationCalled = true
                return "success"
            },
            fallback: { return "fallback" }
        )
        
        XCTAssertEqual(result, "fallback", "Should use fallback when circuit is open")
        XCTAssertFalse(operationCalled, "Should not call operation when circuit is open")
    }
    
    // MARK: - Circuit Recovery Tests
    
    func testHalfOpenTransition() async {
        let breaker = CircuitBreaker(failureThreshold: 2, timeout: 0.5)
        
        // Open the circuit
        for _ in 0..<2 {
            _ = await breaker.execute(
                operation: { throw NSError(domain: "test", code: 1) },
                fallback: { return "fallback" }
            )
        }
        
        // Wait for timeout
        try? await _Concurrency.Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Next call should transition to half-open
        var operationCalled = false
        _ = await breaker.execute(
            operation: {
                operationCalled = true
                return "success"
            },
            fallback: { return "fallback" }
        )
        
        XCTAssertTrue(operationCalled, "Should attempt operation in half-open state")
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.state, .closed, "Should close after successful half-open attempt")
        XCTAssertEqual(status.failures, 0, "Failures should reset after recovery")
    }
    
    func testHalfOpenFailureReopens() async {
        let breaker = CircuitBreaker(failureThreshold: 2, timeout: 0.5)
        
        // Open the circuit
        for _ in 0..<2 {
            _ = await breaker.execute(
                operation: { throw NSError(domain: "test", code: 1) },
                fallback: { return "fallback" }
            )
        }
        
        // Wait for timeout
        try? await _Concurrency.Task.sleep(nanoseconds: 600_000_000)
        
        // Fail in half-open state
        _ = await breaker.execute(
            operation: { throw NSError(domain: "test", code: 1) },
            fallback: { return "fallback" }
        )
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.state, .open, "Should reopen after half-open failure")
    }
    
    // MARK: - Retry Logic Tests
    
    func testRetryWithSuccess() async {
        let breaker = CircuitBreaker()
        var attemptCount = 0
        
        let result = await breaker.executeWithRetry(
            maxAttempts: 3,
            operation: {
                attemptCount += 1
                if attemptCount < 2 {
                    throw NSError(domain: "test", code: 1)
                }
                return "success"
            },
            fallback: { return "fallback" }
        )
        
        XCTAssertEqual(result, "success", "Should succeed after retry")
        XCTAssertEqual(attemptCount, 2, "Should have made 2 attempts")
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.failures, 0, "Failures should reset after success")
    }
    
    func testRetryExhaustion() async {
        let breaker = CircuitBreaker()
        var attemptCount = 0
        
        let result = await breaker.executeWithRetry(
            maxAttempts: 3,
            operation: {
                attemptCount += 1
                throw NSError(domain: "test", code: 1)
            },
            fallback: { return "fallback" }
        )
        
        XCTAssertEqual(result, "fallback", "Should use fallback after retries exhausted")
        XCTAssertEqual(attemptCount, 3, "Should have made all 3 attempts")
    }
    
    func testExponentialBackoff() async {
        let breaker = CircuitBreaker()
        var timestamps: [Date] = []
        
        _ = await breaker.executeWithRetry(
            maxAttempts: 3,
            operation: {
                timestamps.append(Date())
                throw NSError(domain: "test", code: 1)
            },
            fallback: { return "fallback" }
        )
        
        XCTAssertEqual(timestamps.count, 3)
        
        if timestamps.count == 3 {
            // Check that delays increase (allow some tolerance)
            let delay1 = timestamps[1].timeIntervalSince(timestamps[0])
            let delay2 = timestamps[2].timeIntervalSince(timestamps[1])
            
            XCTAssertGreaterThan(delay1, 0.9, "First retry should wait ~1s")
            XCTAssertGreaterThan(delay2, 1.9, "Second retry should wait ~2s")
            XCTAssertLessThan(delay1, 1.5, "First delay should not be too long")
            XCTAssertLessThan(delay2, 2.5, "Second delay should not be too long")
        }
    }
    
    // MARK: - Manual Reset Tests
    
    func testManualReset() async {
        let breaker = CircuitBreaker(failureThreshold: 2)
        
        // Open the circuit
        for _ in 0..<2 {
            _ = await breaker.execute(
                operation: { throw NSError(domain: "test", code: 1) },
                fallback: { return "fallback" }
            )
        }
        
        var status = await breaker.getStatus()
        XCTAssertEqual(status.state, .open)
        
        // Reset manually
        await breaker.reset()
        
        status = await breaker.getStatus()
        XCTAssertEqual(status.state, .closed, "Manual reset should close circuit")
        XCTAssertEqual(status.failures, 0, "Manual reset should clear failures")
    }
    
    // MARK: - Fallback Generator Tests
    
    func testLocalFallbackForEmptyPrompt() {
        let response = LocalFallbackGenerator.generateFallback(for: "")
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.contains("offline") || response.contains("provide"))
    }
    
    func testLocalFallbackForHelpPrompt() {
        let response = LocalFallbackGenerator.generateFallback(for: "Help me with this task")
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.contains("offline"))
        XCTAssertTrue(response.contains("Help me with this task"))
    }
    
    func testLocalFallbackForQuestionPrompt() {
        let response = LocalFallbackGenerator.generateFallback(for: "What is machine learning?")
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.contains("offline"))
        XCTAssertTrue(response.contains("What is machine learning?"))
    }
    
    func testLocalFallbackForGenericPrompt() {
        let response = LocalFallbackGenerator.generateFallback(for: "Schedule a meeting")
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.contains("offline") || response.contains("noted"))
    }
    
    // MARK: - Edge Cases
    
    func testZeroFailureThreshold() async {
        // Should be clamped to at least 1
        let breaker = CircuitBreaker(failureThreshold: 0)
        
        _ = await breaker.execute(
            operation: { throw NSError(domain: "test", code: 1) },
            fallback: { return "fallback" }
        )
        
        let status = await breaker.getStatus()
        XCTAssertEqual(status.state, .open, "Should open after one failure with threshold 1")
    }
    
    func testConcurrentOperations() async {
        let breaker = CircuitBreaker(failureThreshold: 5)
        
        // Execute multiple operations concurrently
        await withTaskGroup(of: String.self) { group in
            for i in 0..<10 {
                group.addTask {
                    await breaker.execute(
                        operation: {
                            if i % 2 == 0 {
                                throw NSError(domain: "test", code: 1)
                            }
                            return "success"
                        },
                        fallback: { return "fallback" }
                    )
                }
            }
            
            // Collect all results
            var results: [String] = []
            for await result in group {
                results.append(result)
            }
            
            XCTAssertEqual(results.count, 10)
        }
    }
}
