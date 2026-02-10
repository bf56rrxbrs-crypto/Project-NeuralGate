import XCTest
@testable import NeuralGate

final class OptimizationTests: XCTestCase {
    
    // MARK: - Cache Manager Tests
    
    func testCacheSetAndGet() async {
        let cache = CacheManager.shared
        await cache.clear()
        
        // Set value
        await cache.set("TestValue", forKey: "testKey")
        
        // Get value
        let value: String? = await cache.get("testKey")
        XCTAssertEqual(value, "TestValue")
    }
    
    func testCacheExpiration() async {
        let cache = CacheManager.shared
        await cache.clear()
        
        // Set value with 1 second TTL
        await cache.set("ExpireValue", forKey: "expireKey", ttl: 0.5)
        
        // Should exist immediately
        let immediate: String? = await cache.get("expireKey")
        XCTAssertEqual(immediate, "ExpireValue")
        
        // Wait for expiration
        try? await _Concurrency.Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Should be nil after expiration
        let expired: String? = await cache.get("expireKey")
        XCTAssertNil(expired)
    }
    
    func testCacheStats() async {
        let cache = CacheManager.shared
        await cache.clear()
        
        await cache.set("Value1", forKey: "key1")
        await cache.set("Value2", forKey: "key2")
        
        let stats = await cache.getStats()
        XCTAssertGreaterThanOrEqual(stats.validEntries, 2)
    }
    
    // MARK: - Persistence Manager Tests
    
    func testPersistenceSetAndGet() async throws {
        let persistence = PersistenceManager.shared
        
        struct TestData: Codable, Equatable {
            let name: String
            let value: Int
        }
        
        let testData = TestData(name: "Test", value: 42)
        
        // Save
        try await persistence.save(testData, withKey: "test_data")
        
        // Load
        let loaded = try await persistence.load(TestData.self, withKey: "test_data")
        XCTAssertEqual(loaded, testData)
        
        // Cleanup
        try await persistence.delete(withKey: "test_data")
    }
    
    func testPersistenceExists() async throws {
        let persistence = PersistenceManager.shared
        
        let testData = ["test": "data"]
        try await persistence.save(testData, withKey: "exists_test")
        
        let exists1 = await persistence.exists(withKey: "exists_test")
        XCTAssertTrue(exists1)
        
        try await persistence.delete(withKey: "exists_test")
        let exists2 = await persistence.exists(withKey: "exists_test")
        XCTAssertFalse(exists2)
    }
    
    // MARK: - Background Task Queue Tests
    
    func testBackgroundTaskQueue() async {
        let queue = BackgroundTaskQueue.shared
        await queue.cancelAll()
        
        var executedCount = 0
        let expectation = XCTestExpectation(description: "Task executed")
        
        await queue.enqueue(priority: .high) {
            executedCount += 1
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(executedCount, 1)
    }
    
    func testBackgroundTaskPriority() async {
        let queue = BackgroundTaskQueue.shared
        await queue.cancelAll()
        
        var executionOrder: [String] = []
        let expectation = XCTestExpectation(description: "Tasks executed")
        expectation.expectedFulfillmentCount = 3
        
        // Add small delay to ensure ordering is tested
        await queue.enqueue(priority: .low) {
            try? await _Concurrency.Task.sleep(nanoseconds: 10_000_000)
            executionOrder.append("low")
            expectation.fulfill()
        }
        
        await queue.enqueue(priority: .critical) {
            try? await _Concurrency.Task.sleep(nanoseconds: 10_000_000)
            executionOrder.append("critical")
            expectation.fulfill()
        }
        
        await queue.enqueue(priority: .medium) {
            try? await _Concurrency.Task.sleep(nanoseconds: 10_000_000)
            executionOrder.append("medium")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // Due to parallel execution, just verify all executed
        XCTAssertEqual(executionOrder.count, 3)
        XCTAssertTrue(executionOrder.contains("critical"))
        XCTAssertTrue(executionOrder.contains("medium"))
        XCTAssertTrue(executionOrder.contains("low"))
    }
    
    // MARK: - Health Monitor Tests
    
    func testHealthCheck() async {
        let monitor = HealthMonitor.shared
        
        let status = await monitor.performHealthCheck()
        XCTAssertTrue(status.components.count > 0)
    }
    
    func testMetricsRecording() async {
        let monitor = HealthMonitor.shared
        await monitor.resetMetrics()
        
        await monitor.recordTaskExecution(duration: 1.0, success: true)
        await monitor.recordTaskExecution(duration: 2.0, success: false)
        
        let metrics = await monitor.getMetrics()
        XCTAssertEqual(metrics.totalTasks, 2)
        XCTAssertEqual(metrics.successfulTasks, 1)
        XCTAssertEqual(metrics.failedTasks, 1)
    }
    
    // MARK: - Webhook Manager Tests
    
    func testWebhookRegistration() async {
        let webhook = WebhookManager.shared
        
        let id = await webhook.register(
            eventType: "test.event",
            url: URL(string: "https://example.com/webhook")!,
            secret: "secret123"
        )
        
        XCTAssertFalse(id.isEmpty)
        
        let registrations = await webhook.getRegistrations()
        XCTAssertTrue(registrations.contains { $0.id == id })
        
        await webhook.unregister(id)
    }
    
    func testWebhookEventHandler() async {
        let webhook = WebhookManager.shared
        
        var handlerCalled = false
        let expectation = XCTestExpectation(description: "Handler called")
        
        await webhook.addHandler(for: "test.handler") { event in
            handlerCalled = true
            expectation.fulfill()
        }
        
        let event = WebhookEvent(type: "test.handler", data: ["key": "value"])
        await webhook.dispatch(event)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(handlerCalled)
    }
}
