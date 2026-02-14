import Foundation

/// Engine for executing workflows and managing workflow lifecycle
@available(iOS 16.0, *)
public class WorkflowEngine {
    
    // MARK: - Properties
    
    private var workflows: [String: StepWorkflow] = [:]
    private var executionHistory: [String: [WorkflowResult]] = [:]
    
    // MARK: - Initialization
    
    public init() {
        loadDefaultWorkflows()
    }
    
    // MARK: - Public Methods
    
    /// Execute a single task
    /// - Parameter task: Task to execute
    /// - Returns: Result of task execution
    public func executeTask(_ task: Task) async throws -> TaskResult {
        let startTime = Date()
        
        do {
            // Execute the task based on its type
            let output = try await performTaskAction(task)
            
            let duration = Date().timeIntervalSince(startTime)
            
            return TaskResult(
                taskId: task.id,
                success: true,
                output: output,
                duration: duration,
                error: nil
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            
            return TaskResult(
                taskId: task.id,
                success: false,
                output: nil,
                duration: duration,
                error: error.localizedDescription
            )
        }
    }
    
    /// Execute a complete workflow
    /// - Parameter workflow: Workflow to execute
    /// - Returns: Result of workflow execution
    public func executeWorkflow(_ workflow: Workflow) async throws -> WorkflowResult {
        let startTime = Date()
        var stepResults: [TaskResult] = []
        
        for task in workflow.tasks {
            let result = try await executeTask(task)
            stepResults.append(result)
            
            // Stop execution if a critical task fails
            if !result.success && task.priority == .critical {
                break
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let allSuccessful = stepResults.allSatisfy { $0.success }
        
        let workflowResult = WorkflowResult(
            workflowId: workflow.id,
            workflowName: workflow.name,
            success: allSuccessful,
            stepResults: stepResults,
            duration: duration
        )
        
        // Store execution history (convert UUID to String for storage)
        let historyKey = workflow.id.uuidString
        if executionHistory[historyKey] == nil {
            executionHistory[historyKey] = []
        }
        executionHistory[historyKey]?.append(workflowResult)
        
        return workflowResult
    }
    
    /// Create a new workflow (step-based)
    /// - Parameters:
    ///   - name: Workflow name
    ///   - steps: Workflow steps
    /// - Returns: Created workflow
    public func createWorkflow(name: String, steps: [WorkflowStep]) throws -> StepWorkflow {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkflowError.invalidInput("Workflow name cannot be empty")
        }
        
        guard !steps.isEmpty else {
            throw WorkflowError.invalidInput("Workflow must have at least one step")
        }
        
        let workflowId = UUID().uuidString
        let workflow = StepWorkflow(id: workflowId, name: name, steps: steps)
        workflows[workflowId] = workflow
        return workflow
    }
    
    /// Get workflow by ID
    /// - Parameter id: Workflow identifier
    /// - Returns: Workflow if found
    public func getWorkflow(_ id: String) throws -> StepWorkflow {
        guard let workflow = workflows[id] else {
            throw WorkflowError.workflowNotFound
        }
        return workflow
    }
    
    /// Get all available workflows
    /// - Returns: Array of workflows
    public func getAllWorkflows() -> [StepWorkflow] {
        return Array(workflows.values)
    }
    
    /// Get execution history for a workflow
    /// - Parameter workflowId: Workflow identifier
    /// - Returns: Array of workflow results
    public func getExecutionHistory(for workflowId: String) -> [WorkflowResult] {
        return executionHistory[workflowId] ?? []
    }
    
    // MARK: - Private Methods
    
    private func performTaskAction(_ task: Task) async throws -> Any {
        // Get action type from task metadata or use task name
        let actionType = task.metadata["action"] ?? task.name.lowercased()
        
        // Simulate task execution based on action type
        switch actionType.lowercased() {
        case "send":
            return try await sendMessage(task)
        case "create":
            return try await createItem(task)
        case "schedule":
            return try await scheduleEvent(task)
        case "remind":
            return try await setReminder(task)
        default:
            return "Task executed: \(task.name)"
        }
    }
    
    private func sendMessage(_ task: Task) async throws -> String {
        // iPhone-specific message sending logic would go here
        return "Message sent successfully"
    }
    
    private func createItem(_ task: Task) async throws -> String {
        return "Item created successfully"
    }
    
    private func scheduleEvent(_ task: Task) async throws -> String {
        return "Event scheduled successfully"
    }
    
    private func setReminder(_ task: Task) async throws -> String {
        return "Reminder set successfully"
    }
    
    private func loadDefaultWorkflows() {
        // Load pre-defined iPhone workflow definitions
        let morningRoutine = StepWorkflow(
            id: "morning-routine",
            name: "Morning Routine",
            steps: [
                WorkflowStep(action: "check", parameters: ["type": "weather"], isCritical: false),
                WorkflowStep(action: "check", parameters: ["type": "calendar"], isCritical: false),
                WorkflowStep(action: "read", parameters: ["type": "news"], isCritical: false)
            ]
        )
        workflows[morningRoutine.id] = morningRoutine
        
        let emailDigest = StepWorkflow(
            id: "email-digest",
            name: "Email Digest",
            steps: [
                WorkflowStep(action: "fetch", parameters: ["type": "emails"], isCritical: true),
                WorkflowStep(action: "summarize", parameters: ["count": "10"], isCritical: false)
            ]
        )
        workflows[emailDigest.id] = emailDigest
    }
}

// MARK: - Workflow Error

public enum WorkflowError: Error {
    case workflowNotFound
    case executionFailed(String)
    case invalidStep(String)
    case invalidInput(String)
    case timeout(String)
    case networkError(String)
    case unauthorized(String)
    
    public var localizedDescription: String {
        switch self {
        case .workflowNotFound:
            return "Workflow not found"
        case .executionFailed(let message):
            return "Workflow execution failed: \(message)"
        case .invalidStep(let message):
            return "Invalid workflow step: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .timeout(let message):
            return "Workflow timeout: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        }
    }
}
