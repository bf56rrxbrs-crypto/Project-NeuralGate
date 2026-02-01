import XCTest
@testable import NeuralGateAI
@testable import NeuralGate

final class NeuralGateAITests: XCTestCase {
    var configuration: NeuralGateConfiguration!
    var decisionEngine: AIDecisionEngine!
    
    override func setUp() {
        super.setUp()
        configuration = NeuralGateConfiguration(debugMode: true)
        decisionEngine = AIDecisionEngine(configuration: configuration)
    }
    
    func testAIDecisionEngine() async throws {
        let task = Task(
            name: "High Priority Task",
            description: "Should be executed",
            priority: .high
        )
        
        let context = ExecutionContext(currentTask: task)
        let result = try await decisionEngine.makeDecision(for: task, context: context)
        
        XCTAssertEqual(result.value, .execute)
        XCTAssertGreaterThan(result.confidence, 0.0)
        XCTAssertFalse(result.explanation.isEmpty)
    }
    
    func testBaselineModel() async throws {
        let model = BaselineAIModel()
        let task = Task(
            name: "Test Task",
            description: "Test",
            priority: .critical
        )
        
        let context = ExecutionContext(currentTask: task)
        let prediction = try await model.predict(task: task, context: context)
        
        XCTAssertEqual(prediction.decision, .execute)
        XCTAssertGreaterThan(prediction.confidence, 0.9)
    }
    
    func testPredictiveAnalytics() {
        let analytics = PredictiveAnalytics(configuration: configuration)
        
        // Record some tasks
        let task1 = Task(name: "Morning Email", description: "Check email", category: .communication)
        let task2 = Task(name: "Daily Standup", description: "Team meeting", category: .communication)
        
        analytics.recordTask(task1)
        analytics.recordTask(task2)
        
        let context = ExecutionContext(currentTask: task1)
        let suggestions = analytics.getSuggestions(context: context)
        
        XCTAssertTrue(suggestions.isEmpty || suggestions.allSatisfy { $0.confidence > 0.0 })
    }
    
    func testResourceAwareModel() {
        let model = BaselineAIModel()
        
        XCTAssertGreaterThan(model.estimatedMemoryUsage, 0)
        XCTAssertGreaterThan(model.estimatedCPUUsage, 0.0)
        XCTAssertTrue(model.canExecute(configuration: configuration))
    }
}
