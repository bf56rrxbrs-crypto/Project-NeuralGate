import XCTest
@testable import NeuralGate

final class NeuralGateTests: XCTestCase {
    
    // MARK: - Configuration Tests
    
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
    
    func testConfigurationDefaults() {
        let config = NeuralGateConfiguration()
        
        XCTAssertFalse(config.debugMode)
        XCTAssertEqual(config.maxMemoryUsage, 100)
        XCTAssertEqual(config.batteryOptimizationLevel, 2)
    }
    
    func testConfigurationBoundaries() {
        // Test edge cases for configuration values
        let config1 = NeuralGateConfiguration(maxMemoryUsage: 0, batteryOptimizationLevel: 0)
        XCTAssertEqual(config1.maxMemoryUsage, 0)
        XCTAssertEqual(config1.batteryOptimizationLevel, 0)
        
        let config2 = NeuralGateConfiguration(maxMemoryUsage: 1000, batteryOptimizationLevel: 5)
        XCTAssertEqual(config2.maxMemoryUsage, 1000)
        XCTAssertEqual(config2.batteryOptimizationLevel, 5)
    }
    
    // MARK: - Task Model Tests
    
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
    
    func testTaskPriorities() {
        let lowTask = Task(name: "Low", description: "Low priority", priority: .low)
        let mediumTask = Task(name: "Medium", description: "Medium priority", priority: .medium)
        let highTask = Task(name: "High", description: "High priority", priority: .high)
        let criticalTask = Task(name: "Critical", description: "Critical priority", priority: .critical)
        
        XCTAssertEqual(lowTask.priority.weight, 1)
        XCTAssertEqual(mediumTask.priority.weight, 2)
        XCTAssertEqual(highTask.priority.weight, 3)
        XCTAssertEqual(criticalTask.priority.weight, 4)
    }
    
    func testTaskCategories() {
        let categories: [Task.TaskCategory] = [.general, .communication, .productivity, .automation, .learning, .analytics]
        
        for category in categories {
            let task = Task(name: "Test", description: "Test", category: category)
            XCTAssertEqual(task.category, category)
        }
    }
    
    func testTaskStatuses() {
        var task = Task(name: "Test", description: "Test")
        XCTAssertEqual(task.status, .pending)
        
        task.status = .inProgress
        XCTAssertEqual(task.status, .inProgress)
        
        task.status = .completed
        XCTAssertEqual(task.status, .completed)
        
        task.status = .failed
        XCTAssertEqual(task.status, .failed)
        
        task.status = .cancelled
        XCTAssertEqual(task.status, .cancelled)
    }
    
    func testTaskMetadata() {
        let metadata = ["key1": "value1", "key2": "value2", "key3": "value3"]
        let task = Task(name: "Test", description: "Test", metadata: metadata)
        
        XCTAssertEqual(task.metadata.count, 3)
        XCTAssertEqual(task.metadata["key1"], "value1")
        XCTAssertEqual(task.metadata["key2"], "value2")
        XCTAssertEqual(task.metadata["key3"], "value3")
    }
    
    func testTaskIdentifiability() {
        let task1 = Task(name: "Task 1", description: "First")
        let task2 = Task(name: "Task 2", description: "Second")
        
        XCTAssertNotEqual(task1.id, task2.id)
        XCTAssertTrue(task1.id.uuidString.count > 0)
    }
    
    // MARK: - Workflow Tests
    
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
    
    func testWorkflowStatuses() {
        var workflow = Workflow(name: "Test", description: "Test", tasks: [])
        
        XCTAssertEqual(workflow.status, .pending)
        
        workflow.status = .running
        XCTAssertEqual(workflow.status, .running)
        
        workflow.status = .completed
        XCTAssertEqual(workflow.status, .completed)
        
        workflow.status = .failed
        XCTAssertEqual(workflow.status, .failed)
        
        workflow.status = .paused
        XCTAssertEqual(workflow.status, .paused)
    }
    
    func testEmptyWorkflow() {
        let workflow = Workflow(name: "Empty", description: "Empty workflow", tasks: [])
        
        XCTAssertEqual(workflow.tasks.count, 0)
        XCTAssertEqual(workflow.status, .pending)
    }
    
    func testWorkflowWithManyTasks() {
        let tasks = (1...100).map { i in
            Task(name: "Task \(i)", description: "Task number \(i)")
        }
        
        let workflow = Workflow(name: "Large Workflow", description: "Workflow with many tasks", tasks: tasks)
        
        XCTAssertEqual(workflow.tasks.count, 100)
    }
    
    // MARK: - Execution Context Tests
    
    func testExecutionContextCreation() {
        let task = Task(name: "Test", description: "Test")
        let context = ExecutionContext(currentTask: task)
        
        XCTAssertNotNil(context.currentTask)
        XCTAssertEqual(context.currentTask?.name, "Test")
        XCTAssertEqual(context.resourceUsage.memoryUsed, 0)
        XCTAssertEqual(context.resourceUsage.cpuUsed, 0.0)
    }
    
    func testExecutionContextWithWorkflow() {
        let task = Task(name: "Test", description: "Test")
        let workflow = Workflow(name: "Test Workflow", description: "Test", tasks: [task])
        let context = ExecutionContext(currentTask: task, workflow: workflow)
        
        XCTAssertNotNil(context.currentTask)
        XCTAssertNotNil(context.workflow)
        XCTAssertEqual(context.workflow?.name, "Test Workflow")
    }
    
    func testExecutionContextWithUserData() {
        let userData: [String: Any] = ["user": "test_user", "session": "abc123"]
        let context = ExecutionContext(userData: userData)
        
        XCTAssertEqual(context.userData.count, 2)
        XCTAssertEqual(context.userData["user"] as? String, "test_user")
    }
    
    // MARK: - Explainable Result Tests
    
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
    
    func testExplainableResultConfidenceBounds() {
        let lowConfidence = ExplainableResult(value: "low", explanation: "Test", confidence: 0.0, factors: [:])
        let highConfidence = ExplainableResult(value: "high", explanation: "Test", confidence: 1.0, factors: [:])
        
        XCTAssertEqual(lowConfidence.confidence, 0.0)
        XCTAssertEqual(highConfidence.confidence, 1.0)
    }
    
    func testExplainableResultWithNoFactors() {
        let result = ExplainableResult(value: "test", explanation: "Test", confidence: 0.5, factors: [:])
        
        XCTAssertEqual(result.factors.count, 0)
        XCTAssertTrue(result.factors.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorDescriptions() {
        let error1 = NeuralGateError.invalidConfiguration("Invalid memory setting")
        let error2 = NeuralGateError.taskExecutionFailed("test")
        
        XCTAssertTrue(error1.localizedDescription.contains("configuration"))
        XCTAssertTrue(error2.localizedDescription.contains("test"))
    }
    
    func testAllErrorCases() {
        let errors: [NeuralGateError] = [
            .invalidConfiguration("test"),
            .resourceLimitExceeded("memory"),
            .modelLoadingFailed("test"),
            .taskExecutionFailed("test error"),
            .dataPipelineError("test"),
            .failoverRequired,
            .invalidInput("empty string"),
            .networkError("connection failed"),
            .permissionDenied("camera")
        ]
        
        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }
    
    // MARK: - Task Manager Tests
    
    @available(iOS 16.0, *)
    func testTaskManagerTaskCreation() throws {
        let intent = Intent(
            action: "send_message",
            parameters: ["recipient": "John", "message": "Hello"],
            priority: .high,
            originalText: "Send message to John saying Hello"
        )
        
        let taskManager = NeuralGate.TaskManager()
        let task = try taskManager.createTask(from: intent)
        
        XCTAssertEqual(task.name, "send_message")
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.metadata["recipient"], "John")
        XCTAssertEqual(task.metadata["message"], "Hello")
    }
    
    @available(iOS 16.0, *)
    func testTaskManagerScheduling() throws {
        let taskManager = NeuralGate.TaskManager()
        let task = Task(name: "Scheduled Task", description: "Task to be scheduled")
        
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        try taskManager.scheduleTask(task, for: futureDate)
        
        let scheduledTasks = taskManager.getScheduledTasks()
        XCTAssertEqual(scheduledTasks.count, 1)
        XCTAssertEqual(scheduledTasks[0].task.name, "Scheduled Task")
    }
    
    @available(iOS 16.0, *)
    func testTaskManagerInvalidScheduleDate() {
        let taskManager = NeuralGate.TaskManager()
        let task = Task(name: "Test", description: "Test")
        
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        XCTAssertThrowsError(try taskManager.scheduleTask(task, for: pastDate)) { error in
            XCTAssertTrue(error is TaskError)
        }
    }
    
    @available(iOS 16.0, *)
    func testTaskManagerCancelTask() throws {
        let taskManager = NeuralGate.TaskManager()
        let task = Task(name: "Test", description: "Test")
        
        let futureDate = Date().addingTimeInterval(3600)
        try taskManager.scheduleTask(task, for: futureDate)
        
        XCTAssertEqual(taskManager.getScheduledTasks().count, 1)
        
        taskManager.cancelTask(task.id)
        
        XCTAssertEqual(taskManager.getScheduledTasks().count, 0)
    }
    
    // MARK: - Intent Tests
    
    func testIntentCreation() {
        let intent = Intent(
            action: "create_reminder",
            parameters: ["title": "Meeting", "time": "3pm"],
            priority: .medium,
            originalText: "Create a reminder for meeting at 3pm"
        )
        
        XCTAssertEqual(intent.action, "create_reminder")
        XCTAssertEqual(intent.priority, .medium)
        XCTAssertEqual(intent.confidence, 1.0)
        XCTAssertEqual(intent.originalText, "Create a reminder for meeting at 3pm")
    }
    
    func testIntentWithCustomConfidence() {
        let intent = Intent(
            action: "test",
            parameters: [:],
            priority: .low,
            originalText: "test",
            confidence: 0.75
        )
        
        XCTAssertEqual(intent.confidence, 0.75)
    }
}
