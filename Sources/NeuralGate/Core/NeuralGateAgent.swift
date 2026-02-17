import Foundation

/// Core AI agent that manages task and workflow automation for iPhone users
@available(iOS 16.0, *)
public class NeuralGateAgent {
    
    // MARK: - Properties
    
    public let taskManager: TaskManager
    public let workflowEngine: WorkflowEngine
    private let nlpProcessor: NaturalLanguageProcessor
    private let iosIntegration: iOSIntegration
    
    // MARK: - Initialization
    
    public init() {
        self.taskManager = TaskManager()
        self.workflowEngine = WorkflowEngine()
        self.nlpProcessor = NaturalLanguageProcessor()
        self.iosIntegration = iOSIntegration()
    }
    
    // MARK: - Public Methods
    
    /// Process a natural language request and execute appropriate tasks
    /// - Parameter request: Natural language task request from user
    /// - Returns: Result of task execution
    public func processRequest(_ request: String) async throws -> TaskResult {
        // Parse natural language to understand intent
        let intent = try await nlpProcessor.parseIntent(request)
        
        // Convert intent to executable task
        let task = try taskManager.createTask(from: intent)
        
        // Execute task using workflow engine
        let result = try await workflowEngine.executeTask(task)
        
        return result
    }
    
    /// Execute a predefined workflow by ID
    /// - Parameter workflowId: Unique identifier for the workflow
    /// - Returns: Result of workflow execution
    public func executeWorkflow(_ workflowId: String) async throws -> WorkflowResult {
        let stepWorkflow = try workflowEngine.getWorkflow(workflowId)
        // Convert StepWorkflow to Workflow for execution
        let tasks = stepWorkflow.steps.map { step in
            Task(
                name: step.action,
                description: "Workflow step: \(step.action)",
                priority: step.isCritical ? .high : .medium,
                category: .automation,
                metadata: step.parameters
            )
        }
        let workflow = Workflow(
            name: stepWorkflow.name,
            description: "Step-based workflow: \(stepWorkflow.name)",
            tasks: tasks
        )
        return try await workflowEngine.executeWorkflow(workflow)
    }
    
    /// Create a new custom workflow
    /// - Parameters:
    ///   - name: Name of the workflow
    ///   - steps: Array of workflow steps
    /// - Returns: Created workflow
    public func createWorkflow(name: String, steps: [WorkflowStep]) throws -> StepWorkflow {
        return try workflowEngine.createWorkflow(name: name, steps: steps)
    }
    
    /// Get all available workflows
    /// - Returns: Array of available workflows
    public func getAvailableWorkflows() -> [StepWorkflow] {
        return workflowEngine.getAllWorkflows()
    }
    
    /// Integrate with iOS Shortcuts
    /// - Parameter shortcutName: Name of the iOS Shortcut
    public func integrateWithShortcut(_ shortcutName: String) async throws {
        try await iosIntegration.connectToShortcut(shortcutName)
    }
    
    /// Enable Siri integration for voice-activated tasks
    public func enableSiriIntegration() async throws {
        try await iosIntegration.enableSiri()
    }
    
    /// Schedule a task for future execution
    /// - Parameters:
    ///   - task: Task to schedule
    ///   - date: Date and time to execute
    public func scheduleTask(_ task: Task, for date: Date) throws {
        try taskManager.scheduleTask(task, for: date)
    }
}
