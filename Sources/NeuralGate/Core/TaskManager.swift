import Foundation

/// Manages task creation, scheduling, and execution
@available(iOS 16.0, *)
public class TaskManager {
    
    // MARK: - Properties
    
    private var tasks: [String: Task] = [:]
    private var workflowTasks: [String: WorkflowTask] = [:]
    private var scheduledTasks: [String: (task: Task, date: Date)] = [:]
    
    // MARK: - Public Methods
    
    /// Create a task from a parsed intent (for Task model)
    /// - Parameter intent: User intent parsed from natural language
    /// - Returns: Executable task
    public func createTask(from intent: Intent) throws -> Task {
        let task = Task(
            name: intent.action,
            description: intent.originalText,
            priority: convertPriority(intent.priority),
            category: .general
        )
        
        tasks[task.id.uuidString] = task
        return task
    }
    
    /// Create a workflow task from a parsed intent (for WorkflowEngine)
    /// - Parameter intent: User intent parsed from natural language
    /// - Returns: Executable workflow task
    public func createWorkflowTask(from intent: Intent) throws -> WorkflowTask {
        let taskId = UUID().uuidString
        
        let task = WorkflowTask(
            id: taskId,
            type: intent.action,
            parameters: intent.parameters,
            priority: intent.priority
        )
        
        workflowTasks[taskId] = task
        return task
    }
    
    /// Schedule a task for future execution
    /// - Parameters:
    ///   - task: Task to schedule
    ///   - date: Execution date
    public func scheduleTask(_ task: Task, for date: Date) throws {
        guard date > Date() else {
            throw TaskError.invalidScheduleDate
        }
        
        scheduledTasks[task.id.uuidString] = (task, date)
    }
    
    /// Get a task by ID
    /// - Parameter taskId: Task identifier
    /// - Returns: Task if found
    public func getTask(_ taskId: String) -> Task? {
        return tasks[taskId]
    }
    
    /// Get all scheduled tasks
    /// - Returns: Array of scheduled tasks
    public func getScheduledTasks() -> [(task: Task, date: Date)] {
        return Array(scheduledTasks.values)
    }
    
    /// Cancel a scheduled task
    /// - Parameter taskId: ID of task to cancel
    public func cancelTask(_ taskId: String) {
        scheduledTasks.removeValue(forKey: taskId)
    }
    
    // MARK: - Helper Methods
    
    /// Convert TaskPriority to Task.Priority
    private func convertPriority(_ priority: TaskPriority) -> Task.Priority {
        switch priority {
        case .low:
            return .low
        case .normal:
            return .medium  // TaskPriority.normal maps to Task.Priority.medium
        case .high:
            return .high
        case .critical:
            return .critical
        }
    }
}

// MARK: - Task Error

public enum TaskError: Error {
    case invalidScheduleDate
    case taskNotFound
    case executionFailed
}
