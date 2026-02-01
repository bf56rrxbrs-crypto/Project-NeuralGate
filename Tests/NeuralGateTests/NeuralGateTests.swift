import XCTest
@testable import NeuralGate

@available(iOS 16.0, *)
final class NeuralGateTests: XCTestCase {
    
    var agent: NeuralGateAgent!
    
    override func setUp() {
        super.setUp()
        agent = NeuralGateAgent()
    }
    
    override func tearDown() {
        agent = nil
        super.tearDown()
    }
    
    // MARK: - Agent Tests
    
    func testAgentInitialization() {
        XCTAssertNotNil(agent)
    }
    
    func testProcessSimpleRequest() async throws {
        let result = try await agent.processRequest("send message to John")
        XCTAssertNotNil(result)
        XCTAssertEqual(result.success, true)
    }
    
    func testCreateWorkflow() {
        let steps = [
            WorkflowStep(action: "send", parameters: ["to": "John"], isCritical: false)
        ]
        
        let workflow = agent.createWorkflow(name: "Test Workflow", steps: steps)
        
        XCTAssertNotNil(workflow)
        XCTAssertEqual(workflow.name, "Test Workflow")
        XCTAssertEqual(workflow.steps.count, 1)
    }
    
    func testGetAvailableWorkflows() {
        let workflows = agent.getAvailableWorkflows()
        
        // Should have default workflows
        XCTAssertFalse(workflows.isEmpty)
        XCTAssertTrue(workflows.contains(where: { $0.name == "Morning Routine" }))
        XCTAssertTrue(workflows.contains(where: { $0.name == "Email Digest" }))
    }
    
    func testExecuteWorkflow() async throws {
        let workflows = agent.getAvailableWorkflows()
        guard let morningRoutine = workflows.first(where: { $0.id == "morning-routine" }) else {
            XCTFail("Morning routine workflow not found")
            return
        }
        
        let result = try await agent.executeWorkflow(morningRoutine.id)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.workflowId, "morning-routine")
        XCTAssertFalse(result.stepResults.isEmpty)
    }
    
    // MARK: - Task Manager Tests
    
    func testTaskCreation() throws {
        let intent = Intent(
            action: "send",
            parameters: ["to": "John", "message": "Hello"],
            priority: .normal,
            originalText: "send message to John"
        )
        
        let task = try agent.taskManager.createTask(from: intent)
        
        XCTAssertNotNil(task)
        XCTAssertEqual(task.type, "send")
        XCTAssertEqual(task.priority, .normal)
        XCTAssertEqual(task.status, .pending)
    }
    
    func testScheduleTask() throws {
        let intent = Intent(
            action: "remind",
            parameters: ["message": "Meeting at 3pm"],
            priority: .high,
            originalText: "remind me about meeting"
        )
        
        let task = try agent.taskManager.createTask(from: intent)
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        
        try agent.scheduleTask(task, for: futureDate)
        
        let scheduledTasks = agent.taskManager.getScheduledTasks()
        XCTAssertTrue(scheduledTasks.contains(where: { $0.task.id == task.id }))
    }
    
    func testScheduleTaskInPastFails() throws {
        let intent = Intent(
            action: "test",
            parameters: [:],
            priority: .normal,
            originalText: "test"
        )
        
        let task = try agent.taskManager.createTask(from: intent)
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        XCTAssertThrowsError(try agent.scheduleTask(task, for: pastDate))
    }
    
    // MARK: - Workflow Tests
    
    func testWorkflowStepExecution() {
        let step = WorkflowStep(
            action: "send",
            parameters: ["type": "message"],
            isCritical: true
        )
        
        XCTAssertEqual(step.action, "send")
        XCTAssertTrue(step.isCritical)
    }
    
    func testWorkflowModel() {
        let steps = [
            WorkflowStep(action: "step1", parameters: [:], isCritical: false),
            WorkflowStep(action: "step2", parameters: [:], isCritical: true)
        ]
        
        let workflow = Workflow(id: "test-id", name: "Test", steps: steps)
        
        XCTAssertEqual(workflow.id, "test-id")
        XCTAssertEqual(workflow.name, "Test")
        XCTAssertEqual(workflow.steps.count, 2)
        XCTAssertTrue(workflow.isActive)
    }
}
