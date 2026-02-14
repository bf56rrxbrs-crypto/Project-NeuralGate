import Foundation

/// Manages task creation, scheduling, and execution
@available(iOS 16.0, *)
public class TaskManager {
    
    // MARK: - Properties
    
    private var tasks: [UUID: Task] = [:]
    private var scheduledTasks: [UUID: (task: Task, date: Date)] = [:]
    
    // MARK: - Public Methods
    
    /// Create a task from a parsed intent
    /// - Parameter intent: User intent parsed from natural language
    /// - Returns: Executable task
    public func createTask(from intent: Intent) throws -> Task {
        // Convert intent parameters to metadata strings
        let metadata = intent.parameters.mapValues { "\($0)" }
        
        let task = Task(
            name: intent.action,
            description: intent.originalText,
            priority: intent.priority,
            category: .general,
            metadata: metadata
        )
        
        tasks[task.id] = task
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
    public func getTask(_ taskId: UUID) -> Task? {
        return tasks[taskId]
    }
    
    /// Get all scheduled tasks
    /// - Returns: Array of scheduled tasks
    public func getScheduledTasks() -> [(task: Task, date: Date)] {
        return Array(scheduledTasks.values)
    }
    
    /// Cancel a scheduled task
    /// - Parameter taskId: ID of task to cancel
    public func cancelTask(_ taskId: UUID) {
        scheduledTasks.removeValue(forKey: taskId)
    }
}

// MARK: - Task Error

public enum TaskError: Error {
    case invalidScheduleDate
    case taskNotFound
    case executionFailed
}
