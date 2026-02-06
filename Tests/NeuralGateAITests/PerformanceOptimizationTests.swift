import XCTest
@testable import NeuralGate
@testable import NeuralGateAI

final class PerformanceOptimizationTests: XCTestCase {
    var config: NeuralGateConfiguration!
    var engine: AIDecisionEngine!
    
    override func setUp() async throws {
        config = NeuralGateConfiguration(
            debugMode: false,
            maxMemoryUsage: 100,
            batteryOptimizationLevel: 2,
            enablePredictiveAnalytics: true,
            enableExplainability: true
        )
        engine = AIDecisionEngine(configuration: config)
    }
    
    func testEarlyExitOptimization() async throws {
        // Create a critical task that should trigger early exit
        let criticalTask = Task(
            name: "Urgent Communication",
            description: "Critical message",
            priority: .critical,
            category: .communication
        )
        
        let context = ExecutionContext()
        let startTime = Date()
        
        let result = try await engine.makeDecision(for: criticalTask, context: context)
        
        let executionTime = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(result.value, .execute)
        XCTAssertGreaterThanOrEqual(result.confidence, 0.9)
        // Early exit should be fast
        XCTAssertLessThan(executionTime, 0.1, "Early exit should complete in less than 100ms")
    }
    
    func testDecisionCaching() async throws {
        let task = Task(
            name: "Regular Task",
            description: "Test task",
            priority: .medium,
            category: .productivity
        )
        
        let context = ExecutionContext()
        
        // First call - not cached
        let startTime1 = Date()
        let result1 = try await engine.makeDecision(for: task, context: context)
        let time1 = Date().timeIntervalSince(startTime1)
        
        // Second call with same parameters - should use cache
        let startTime2 = Date()
        let result2 = try await engine.makeDecision(for: task, context: context)
        let time2 = Date().timeIntervalSince(startTime2)
        
        // Both should return same decision
        XCTAssertEqual(result1.value, result2.value)
        
        // Cached call should be faster
        XCTAssertLessThan(time2, time1 * 0.5, "Cached decision should be significantly faster")
    }
    
    func testModelHealthTracking() async throws {
        // Get initial health metrics
        let initialHealth = engine.getModelHealthMetrics()
        XCTAssertFalse(initialHealth.isEmpty)
        
        // All models should start healthy
        for (_, health) in initialHealth {
            XCTAssertEqual(health, 1.0, "Initial health should be 1.0")
        }
        
        // Make several decisions to update health
        for _ in 0..<5 {
            let task = Task(
                name: "Test Task",
                description: "Test",
                priority: .medium,
                category: .general
            )
            _ = try await engine.makeDecision(for: task, context: ExecutionContext())
        }
        
        // Health metrics should still exist
        let updatedHealth = engine.getModelHealthMetrics()
        XCTAssertFalse(updatedHealth.isEmpty)
    }
    
    func testParallelModelExecution() async throws {
        // Create multiple models
        let model1 = BaselineAIModel()
        let model2 = BaselineAIModel()
        let engineWithModels = AIDecisionEngine(
            configuration: config,
            models: [model1, model2]
        )
        
        let task = Task(
            name: "Parallel Test",
            description: "Test parallel execution",
            priority: .high,
            category: .automation
        )
        
        let context = ExecutionContext()
        let startTime = Date()
        
        let result = try await engineWithModels.makeDecision(for: task, context: context)
        
        let executionTime = Date().timeIntervalSince(startTime)
        
        XCTAssertNotNil(result)
        // Parallel execution should be faster than sequential would be
        XCTAssertLessThan(executionTime, 1.0, "Parallel execution should complete quickly")
    }
    
    func testPredictiveAnalyticsHashIndexing() async throws {
        let analytics = PredictiveAnalytics(configuration: config)
        
        // Record multiple tasks
        for i in 0..<100 {
            let task = Task(
                name: "Task \(i)",
                description: "Test task",
                priority: .medium,
                category: i % 2 == 0 ? .productivity : .automation
            )
            analytics.recordTask(task)
        }
        
        // Get suggestions - should use hash index
        let task = Task(
            name: "Current",
            description: "Current task",
            priority: .medium,
            category: .productivity
        )
        let context = ExecutionContext(currentTask: task)
        
        let startTime = Date()
        let suggestions = analytics.getSuggestions(context: context)
        let lookupTime = Date().timeIntervalSince(startTime)
        
        // Hash index lookup should be very fast
        XCTAssertLessThan(lookupTime, 0.01, "Hash index lookup should be under 10ms")
        
        // Get statistics
        let stats = analytics.getStatistics()
        XCTAssertEqual(stats.totalTasksRecorded, 100)
        XCTAssertGreaterThanOrEqual(stats.categoriesWithPatterns, 0)
    }
    
    func testResourceAwareDecisionMaking() async throws {
        // Test with limited memory
        let limitedConfig = NeuralGateConfiguration(
            debugMode: false,
            maxMemoryUsage: 10, // Very limited
            batteryOptimizationLevel: 3,
            enablePredictiveAnalytics: false,
            enableExplainability: false
        )
        
        let limitedEngine = AIDecisionEngine(configuration: limitedConfig)
        
        let task = Task(
            name: "Resource Test",
            description: "Test resource constraints",
            priority: .medium,
            category: .general
        )
        
        // Should still be able to make decisions with limited resources
        let result = try await limitedEngine.makeDecision(for: task, context: ExecutionContext())
        XCTAssertNotNil(result)
    }
}
