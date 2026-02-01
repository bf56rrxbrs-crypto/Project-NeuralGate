import Foundation
import NeuralGate
import NeuralGateAI

/// Task Manager with failover and redundancy
public class TaskManager {
    private let configuration: NeuralGateConfiguration
    private var taskQueue: [Task] = []
    private var completedTasks: [Task] = []
    private var failedTasks: [(task: Task, error: Error)] = []
    private let logger = NeuralGateLogger.shared
    
    // Redundancy settings
    private let maxRetries = 3
    private var retryCount: [UUID: Int] = [:]
    
    public init(configuration: NeuralGateConfiguration) {
        self.configuration = configuration
    }
    
    /// Add task to queue
    public func enqueueTask(_ task: Task) {
        taskQueue.append(task)
        taskQueue.sort { $0.priority.weight > $1.priority.weight }
        logger.log("Task enqueued: \(task.name) (priority: \(task.priority.rawValue))", level: .info)
    }
    
    /// Execute next task with failover support
    public func executeNextTask() async throws -> TaskExecutionResult? {
        guard let task = taskQueue.first else {
            return nil
        }
        
        taskQueue.removeFirst()
        
        logger.log("Executing task: \(task.name)", level: .info)
        
        do {
            let result = try await executeTaskWithFailover(task)
            
            if result.status == .completed {
                completedTasks.append(task)
                retryCount.removeValue(forKey: task.id)
            }
            
            return result
            
        } catch {
            logger.log("Task failed: \(task.name) - \(error.localizedDescription)", level: .error)
            
            // Handle failover
            let currentRetries = retryCount[task.id, default: 0]
            
            if currentRetries < maxRetries {
                logger.log("Retrying task \(task.name) (attempt \(currentRetries + 1)/\(maxRetries))", level: .warning)
                retryCount[task.id] = currentRetries + 1
                
                // Re-enqueue with slight delay
                try await _Concurrency.Task.sleep(nanoseconds: 1_000_000_000 * UInt64(currentRetries + 1))
                taskQueue.insert(task, at: 0)
                
                return try await executeNextTask()
            } else {
                // Max retries exceeded, mark as failed
                failedTasks.append((task, error))
                retryCount.removeValue(forKey: task.id)
                
                return TaskExecutionResult(
                    task: task,
                    status: .failed,
                    executionTime: 0,
                    explanation: "Failed after \(maxRetries) attempts: \(error.localizedDescription)",
                    error: error
                )
            }
        }
    }
    
    /// Execute task with automatic failover
    private func executeTaskWithFailover(_ task: Task) async throws -> TaskExecutionResult {
        let startTime = Date()
        
        // Primary execution path
        do {
            return try await executePrimary(task, startTime: startTime)
        } catch {
            logger.log("Primary execution failed, attempting fallback", level: .warning)
            
            // Fallback execution path
            return try await executeFallback(task, startTime: startTime, primaryError: error)
        }
    }
    
    /// Primary execution path
    private func executePrimary(_ task: Task, startTime: Date) async throws -> TaskExecutionResult {
        // Simulate primary execution
        // In production, this would use the main AI pipeline
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000)
        
        // Simulate random failures for testing failover (10% chance)
        if Int.random(in: 0...9) == 0 {
            throw NeuralGateError.taskExecutionFailed("Random primary failure")
        }
        
        let executionTime = Date().timeIntervalSince(startTime)
        
        return TaskExecutionResult(
            task: task,
            status: .completed,
            executionTime: executionTime,
            explanation: "Executed via primary path"
        )
    }
    
    /// Fallback execution path
    private func executeFallback(_ task: Task, startTime: Date, primaryError: Error) async throws -> TaskExecutionResult {
        logger.log("Executing fallback for task: \(task.name)", level: .info)
        
        // Simulate fallback execution with simpler, more reliable approach
        try await _Concurrency.Task.sleep(nanoseconds: 50_000_000)
        
        let executionTime = Date().timeIntervalSince(startTime)
        
        return TaskExecutionResult(
            task: task,
            status: .completed,
            executionTime: executionTime,
            explanation: "Executed via fallback path after primary failure: \(primaryError.localizedDescription)"
        )
    }
    
    /// Get task statistics
    public func getStatistics() -> TaskStatistics {
        return TaskStatistics(
            totalQueued: taskQueue.count,
            totalCompleted: completedTasks.count,
            totalFailed: failedTasks.count,
            completionRate: calculateCompletionRate()
        )
    }
    
    private func calculateCompletionRate() -> Double {
        let total = completedTasks.count + failedTasks.count
        guard total > 0 else { return 0.0 }
        return Double(completedTasks.count) / Double(total)
    }
}

/// Task statistics
public struct TaskStatistics {
    public let totalQueued: Int
    public let totalCompleted: Int
    public let totalFailed: Int
    public let completionRate: Double
}
