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
        XCTAssertGreaterThan(result.actualImprovement, 0.0)
        XCTAssertGreaterThan(result.newValue, opportunity.currentValue)
        XCTAssertLessThanOrEqual(result.newValue, opportunity.targetValue)
    }

    func testImprovementCalculation() async {
        // Test that improvement is calculated as 50% of gap
        let opportunity = ImprovementOpportunity(
            area: .userSatisfaction,
            currentValue: 3.0,
            targetValue: 5.0,
            priority: .high,
            suggestedAction: "Improve satisfaction"
        )

        let result = await improvementEngine.executeImprovement(opportunity)

        XCTAssertTrue(result.success)
        // Gap is 2.0, so 50% improvement should be ~1.0
        XCTAssertEqual(result.actualImprovement, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.newValue, 4.0, accuracy: 0.01)
    }

    func testImprovementValidation() async {
        // Test case where improvement would be invalid (target already met)
        let opportunity = ImprovementOpportunity(
            area: .accuracy,
            currentValue: 0.95,
            targetValue: 0.90, // Already exceeded target
            priority: .low,
            suggestedAction: "Test"
        )

        let result = await improvementEngine.executeImprovement(opportunity)

        // Should fail validation due to negative gap
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.actualImprovement, 0.0)
        XCTAssertEqual(result.newValue, opportunity.currentValue)
    }

    func testEfficiencyImprovement() async {
        // Test efficiency improvement (should decrease execution time)
        let opportunity = ImprovementOpportunity(
            area: .efficiency,
            currentValue: 10.0, // 10 seconds
            targetValue: 5.0,   // Target 5 seconds
            priority: .high,
            suggestedAction: "Optimize execution"
        )

        let result = await improvementEngine.executeImprovement(opportunity)

        XCTAssertTrue(result.success)
        // For efficiency, we apply reduction via multiplication
        XCTAssertGreaterThan(result.actualImprovement, 0.0)
    }
}
