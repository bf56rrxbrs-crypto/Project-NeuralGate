import Foundation

/// Core AI agent that manages task and workflow automation for iPhone users.
///
/// `NeuralGateAgent` is the main entry point for interacting with the NeuralGate
/// automation framework. It provides a unified interface for:
/// - Processing natural language requests into executable tasks
/// - Managing workflows and task execution
/// - Integrating with iOS features (Siri, Shortcuts, Notifications)
/// - Scheduling and tracking tasks
///
/// Example:
/// ```swift
/// let agent = NeuralGateAgent()
///
/// Swift.Task {
///     do {
///         // Process natural language
///         let result = try await agent.processRequest("Send a message to John")
///
///         // Execute a workflow
///         let workflowResult = try await agent.executeWorkflow("morning-routine")
///
///         // Schedule a task for tomorrow
///         let task = NeuralGate.Task(name: "Daily Report", description: "Generate report", priority: .medium)
///         let calendar = Calendar.current
///         let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
///         try agent.scheduleTask(task, for: tomorrow)
///     } catch {
///         // Handle any errors from processing, workflow execution, or scheduling
///         print("NeuralGateAgent example failed with error: \(error)")
///     }
/// }
/// ```
@available(iOS 16.0, *)
public class NeuralGateAgent {
    
    // MARK: - Properties
    
    /// Task manager for task lifecycle and scheduling
    public let taskManager: TaskManager
    
    /// Workflow engine for orchestrating complex automations
    public let workflowEngine: WorkflowEngine
    
    /// Natural language processor for understanding user intent
    private let nlpProcessor: NaturalLanguageProcessor
    
    /// iOS integration for platform-specific features
    private let iosIntegration: iOSIntegration
    
    // MARK: - Initialization
    
    /// Creates a new NeuralGate agent with default configuration.
    ///
    /// Initializes all internal components including task manager,
    /// workflow engine, NLP processor, and iOS integrations.
    public init() {
        self.taskManager = TaskManager()
        self.workflowEngine = WorkflowEngine()
        self.nlpProcessor = NaturalLanguageProcessor()
        self.iosIntegration = iOSIntegration()
    }
    
    // MARK: - Natural Language Processing
    
    /// Process a natural language request and execute appropriate tasks.
    ///
    /// Parses the user's natural language input, converts it to a structured
    /// task, and executes it through the workflow engine.
    ///
    /// - Parameter request: Natural language task request from user
    /// - Returns: Result of task execution including status and output
    /// - Throws: `NeuralGateError` if parsing or execution fails
    ///
    /// Example:
    /// ```swift
    /// let result = try await agent.processRequest("Schedule meeting with team tomorrow at 3pm")
    /// print(result.success ? "Task completed" : "Task failed")
    /// ```
    public func processRequest(_ request: String) async throws -> TaskResult {
        // Parse natural language to understand intent
        let intent = try await nlpProcessor.parseIntent(request)
        
        // Convert intent to executable task
        let task = try taskManager.createTask(from: intent)
        
        // Execute task using workflow engine
        let result = try await workflowEngine.executeTask(task)
        
        return result
    }
    
    // MARK: - Workflow Management
    
    /// Execute a predefined workflow by its unique identifier.
    ///
    /// Retrieves and executes a workflow that has been registered with
    /// the workflow engine. Workflows are composed of multiple tasks
    /// executed in sequence or parallel.
    ///
    /// - Parameter workflowId: Unique identifier for the workflow
    /// - Returns: Result of workflow execution including task results
    /// - Throws: `WorkflowError` if workflow not found or execution fails
    ///
    /// Example:
    /// ```swift
    /// let result = try await agent.executeWorkflow("morning-routine")
    /// print("Completed \(result.completedTasks.count) tasks")
    /// ```
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
    
    /// Create a new custom workflow with specified steps.
    ///
    /// - Parameters:
    ///   - name: Human-readable name for the workflow
    ///   - steps: Array of workflow steps defining the automation sequence
    /// - Returns: Created workflow with unique identifier
    ///
    /// Example:
    /// ```swift
    /// let workflow = agent.createWorkflow(
    ///     name: "Daily Briefing",
    ///     steps: [checkEmailStep, weatherStep, newsStep]
    /// )
    /// ```
    public func createWorkflow(name: String, steps: [WorkflowStep]) -> StepWorkflow {
        return workflowEngine.createWorkflow(name: name, steps: steps)
    }
    
    /// Get all available workflows registered in the system.
    ///
    /// - Returns: Array of all registered workflows
    ///
    /// Example:
    /// ```swift
    /// let workflows = agent.getAvailableWorkflows()
    /// workflows.forEach { print($0.name) }
    /// ```
    public func getAvailableWorkflows() -> [StepWorkflow] {
        return workflowEngine.getAllWorkflows()
    }
    
    // MARK: - iOS Integration
    
    /// Integrate with iOS Shortcuts app for cross-app automation.
    ///
    /// Connects the agent to an existing iOS Shortcut, enabling
    /// seamless integration with other iOS apps and system features.
    ///
    /// - Parameter shortcutName: Name of the iOS Shortcut to connect
    /// - Throws: `IntegrationError` if shortcut not found or connection fails
    ///
    /// Example:
    /// ```swift
    /// try await agent.integrateWithShortcut("Morning Routine")
    /// ```
    public func integrateWithShortcut(_ shortcutName: String) async throws {
        try await iosIntegration.connectToShortcut(shortcutName)
    }
    
    /// Enable Siri integration for voice-activated task execution.
    ///
    /// Configures the agent to respond to Siri voice commands,
    /// enabling hands-free task automation.
    ///
    /// - Throws: `IntegrationError` if Siri permissions not granted
    ///
    /// Example:
    /// ```swift
    /// try await agent.enableSiriIntegration()
    /// // User can now say: "Hey Siri, run my morning routine"
    /// ```
    public func enableSiriIntegration() async throws {
        try await iosIntegration.enableSiri()
    }
    
    // MARK: - Task Scheduling
    
    /// Schedule a task for future execution at a specific date and time.
    ///
    /// - Parameters:
    ///   - task: Task to schedule for execution
    ///   - date: Date and time when the task should be executed
    /// - Throws: `TaskError.invalidScheduleDate` if the date is in the past or otherwise invalid
    ///
    /// Example:
    /// ```swift
    /// let task = NeuralGate.Task(name: "Send Report", description: "Send weekly report", priority: .medium)
    /// let friday = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
    /// try agent.scheduleTask(task, for: friday)
    /// ```
    public func scheduleTask(_ task: Task, for date: Date) throws {
        try taskManager.scheduleTask(task, for: date)
    }
}
