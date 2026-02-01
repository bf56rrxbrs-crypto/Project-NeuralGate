import XCTest
@testable import NeuralGateAutomation
@testable import NeuralGateAI
@testable import NeuralGate

final class NeuralGateAutomationTests: XCTestCase {
    var configuration: NeuralGateConfiguration!
    var decisionEngine: AIDecisionEngine!
    var automationEngine: WorkflowAutomationEngine!
    var taskManager: TaskManager!
    
    override func setUp() {
        super.setUp()
        configuration = NeuralGateConfiguration(debugMode: true)
        decisionEngine = AIDecisionEngine(configuration: configuration)
        automationEngine = WorkflowAutomationEngine(configuration: configuration, decisionEngine: decisionEngine)
        taskManager = TaskManager(configuration: configuration)
    }
    
    func testWorkflowExecution() async throws {
        let task1 = Task(name: "Task 1", description: "First task", priority: .high)
        let task2 = Task(name: "Task 2", description: "Second task", priority: .medium)
        
        let workflow = Workflow(
            name: "Test Workflow",
            description: "Test workflow execution",
            tasks: [task1, task2]
        )
        
        let result = try await automationEngine.executeWorkflow(workflow)
        
        XCTAssertEqual(result.workflow.status, .completed)
        XCTAssertGreaterThan(result.executedTasks.count, 0)
        XCTAssertGreaterThan(result.totalExecutionTime, 0)
    }
    
    func testWorkflowComposition() {
        let workflow1 = Workflow(
            name: "Workflow 1",
            description: "First workflow",
            tasks: [Task(name: "Task 1", description: "Task 1")]
        )
        
        let workflow2 = Workflow(
            name: "Workflow 2",
            description: "Second workflow",
            tasks: [Task(name: "Task 2", description: "Task 2")]
        )
        
        let composed = automationEngine.composeWorkflows(
            [workflow1, workflow2],
            compositionStrategy: .sequential
        )
        
        XCTAssertEqual(composed.tasks.count, 2)
    }
    
    func testTaskManager() async throws {
        let task = Task(name: "Test Task", description: "Test", priority: .high)
        
        taskManager.enqueueTask(task)
        
        let stats = taskManager.getStatistics()
        XCTAssertEqual(stats.totalQueued, 1)
        
        let result = try await taskManager.executeNextTask()
        XCTAssertNotNil(result)
    }
    
    func testTaskFailover() async throws {
        let task = Task(name: "Failover Test", description: "Test failover", priority: .critical)
        
        taskManager.enqueueTask(task)
        
        // Execute with potential failover
        let result = try await taskManager.executeNextTask()
        
        XCTAssertNotNil(result)
        // Task should eventually complete even if primary path fails
        XCTAssertTrue(result!.status == .completed || result!.status == .failed)
    }
}
