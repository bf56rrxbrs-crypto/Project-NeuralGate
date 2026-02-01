import Foundation

/// Manages task creation, scheduling, and execution
@available(iOS 16.0, *)
public class TaskManager {
    
    // MARK: - Properties
    
    private var tasks: [String: Task] = [:]
    private var scheduledTasks: [String: (task: Task, date: Date)] = [:]
    
    // MARK: - Public Methods
    
    /// Create a task from a parsed intent
    /// - Parameter intent: User intent parsed from natural language
    /// - Returns: Executable task
    public func createTask(from intent: Intent) throws -> Task {
        let taskId = UUID().uuidString
        
        let task = Task(
            id: taskId,
            type: intent.action,
            parameters: intent.parameters,
            priority: intent.priority
        )
        
        tasks[taskId] = task
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
        
        scheduledTasks[task.id] = (task, date)
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
}

// MARK: - Task Error

public enum TaskError: Error {
    case invalidScheduleDate
    case taskNotFound
    case executionFailed
}
