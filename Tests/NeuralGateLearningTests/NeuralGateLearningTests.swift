import XCTest
@testable import NeuralGateLearning
@testable import NeuralGate

final class NeuralGateLearningTests: XCTestCase {
    var configuration: NeuralGateConfiguration!
    var feedbackSystem: FeedbackLoopSystem!
    var improvementEngine: SelfImprovementEngine!
    
    override func setUp() {
        super.setUp()
        configuration = NeuralGateConfiguration(debugMode: true)
        feedbackSystem = FeedbackLoopSystem(configuration: configuration)
        improvementEngine = SelfImprovementEngine(configuration: configuration)
    }
    
    func testFeedbackRecording() {
        let feedback = TaskFeedback(
            taskId: UUID(),
            taskCategory: .productivity,
            wasSuccessful: true,
            executionTime: 2.5,
            userRating: 5
        )
        
        feedbackSystem.recordFeedback(feedback)
        
        let task = Task(name: "Test", description: "Test", category: .productivity)
        let adaptations = feedbackSystem.getAdaptations(for: task)
        
        XCTAssertTrue(adaptations.isEmpty || adaptations.allSatisfy { $0.confidence > 0.0 })
    }
    
    func testSelfImprovement() async {
        let evaluation = improvementEngine.evaluatePerformance()
        
        XCTAssertGreaterThanOrEqual(evaluation.overallScore, 0.0)
        XCTAssertLessThanOrEqual(evaluation.overallScore, 1.0)
    }
    
    func testPerformanceMetricsUpdate() {
        let result = TaskResult(
            taskId: UUID(),
            wasSuccessful: true,
            executionTime: 1.5,
            memoryUsed: 10,
            userRating: 4.5
        )
        
        improvementEngine.updateMetrics(taskResult: result)
        let evaluation = improvementEngine.evaluatePerformance()
        
        XCTAssertGreaterThan(evaluation.metrics.totalTasks, 0)
    }
    
    func testImprovementExecution() async {
        let opportunity = ImprovementOpportunity(
            area: .accuracy,
            currentValue: 0.75,
            targetValue: 0.90,
            priority: .high,
            suggestedAction: "Test improvement"
        )
        
        let result = await improvementEngine.executeImprovement(opportunity)
        
        XCTAssertTrue(result.success)
    }
}
