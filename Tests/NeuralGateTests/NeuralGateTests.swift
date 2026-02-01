import XCTest
@testable import NeuralGate

final class NeuralGateTests: XCTestCase {
    func testConfigurationInitialization() {
        let config = NeuralGateConfiguration(
            debugMode: true,
            maxMemoryUsage: 50,
            batteryOptimizationLevel: 3
        )
        
        XCTAssertTrue(config.debugMode)
        XCTAssertEqual(config.maxMemoryUsage, 50)
        XCTAssertEqual(config.batteryOptimizationLevel, 3)
    }
    
    func testTaskCreation() {
        let task = Task(
            name: "Test Task",
            description: "A test task",
            priority: .high,
            category: .productivity
        )
        
        XCTAssertEqual(task.name, "Test Task")
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.category, .productivity)
        XCTAssertEqual(task.status, .pending)
    }
    
    func testWorkflowCreation() {
        let task1 = Task(name: "Task 1", description: "First task")
        let task2 = Task(name: "Task 2", description: "Second task")
        
        let workflow = Workflow(
            name: "Test Workflow",
            description: "A test workflow",
            tasks: [task1, task2]
        )
        
        XCTAssertEqual(workflow.name, "Test Workflow")
        XCTAssertEqual(workflow.tasks.count, 2)
        XCTAssertEqual(workflow.status, .pending)
    }
    
    func testExplainableResult() {
        let result = ExplainableResult(
            value: "test",
            explanation: "This is a test",
            confidence: 0.85,
            factors: ["factor1": 0.5, "factor2": 0.3]
        )
        
        XCTAssertEqual(result.value, "test")
        XCTAssertEqual(result.confidence, 0.85)
        XCTAssertEqual(result.factors.count, 2)
    }
    
    func testErrorDescriptions() {
        let error1 = NeuralGateError.invalidConfiguration
        let error2 = NeuralGateError.taskExecutionFailed("test")
        
        XCTAssertTrue(error1.localizedDescription.contains("configuration"))
        XCTAssertTrue(error2.localizedDescription.contains("test"))
    }
}
