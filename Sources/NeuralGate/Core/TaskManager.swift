import Foundation

/// Manages task creation, scheduling, and execution (Legacy)
@available(iOS 16.0, *)
public class LegacyTaskManager {
    
    // MARK: - Properties
    
    private var tasks: [String: LegacyTask] = [:]
    private var scheduledTasks: [String: (task: LegacyTask, date: Date)] = [:]
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Create a task from a parsed intent
    /// - Parameter intent: User intent parsed from natural language
    /// - Returns: Executable task
    public func createTask(from intent: Intent) throws -> LegacyTask {
        let taskId = UUID().uuidString
        
        let task = LegacyTask(
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
    public func scheduleTask(_ task: LegacyTask, for date: Date) throws {
        guard date > Date() else {
            throw TaskError.invalidScheduleDate
        }
        
        scheduledTasks[task.id] = (task, date)
    }
    
    /// Get a task by ID
    /// - Parameter taskId: Task identifier
    /// - Returns: Task if found
    public func getTask(_ taskId: String) -> LegacyTask? {
        return tasks[taskId]
    }
    
    /// Get all scheduled tasks
    /// - Returns: Array of scheduled tasks
    public func getScheduledTasks() -> [(task: LegacyTask, date: Date)] {
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
