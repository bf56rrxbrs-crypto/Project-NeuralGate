import Foundation

/// Background task queue for efficient parallel task processing
public actor BackgroundTaskQueue {
    public static let shared = BackgroundTaskQueue()
    
    private var queue: [QueuedTask] = []
    private var runningTasks: Set<UUID> = []
    private let maxConcurrentTasks: Int
    private let logger = NeuralGateLogger.shared
    
    private init(maxConcurrentTasks: Int = 4) {
        self.maxConcurrentTasks = maxConcurrentTasks
    }
    
    /// Add task to background queue
    public func enqueue(
        id: UUID = UUID(),
        priority: TaskPriority = .medium,
        operation: @escaping () async throws -> Void
    ) {
        let task = QueuedTask(
            id: id,
            priority: priority,
            operation: operation,
            enqueuedAt: Date()
        )
        
        queue.append(task)
        queue.sort { $0.priority.value > $1.priority.value }
        
        logger.log("Background task enqueued: \(id) (priority: \(priority))", level: .debug)
        
        // Start processing if under capacity
        _Concurrency.Task {
            await processQueue()
        }
    }
    
    /// Process queued tasks with concurrency limit
    private func processQueue() async {
        while !queue.isEmpty && runningTasks.count < maxConcurrentTasks {
            guard let task = queue.first else { break }
            queue.removeFirst()
            
            runningTasks.insert(task.id)
            
            // Execute task in detached task
            _Concurrency.Task.detached { [weak self] in
                await self?.executeTask(task)
            }
        }
    }
    
    /// Execute individual task
    private func executeTask(_ task: QueuedTask) async {
        let startTime = Date()
        logger.log("Executing background task: \(task.id)", level: .debug)
        
        do {
            try await task.operation()
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Background task completed: \(task.id) (\(duration)s)", level: .debug)
            
            // Record metrics
            await HealthMonitor.shared.recordTaskExecution(duration: duration, success: true)
            
        } catch {
            logger.log("Background task failed: \(task.id) - \(error.localizedDescription)", level: .error)
            
            // Record metrics
            let duration = Date().timeIntervalSince(startTime)
            await HealthMonitor.shared.recordTaskExecution(duration: duration, success: false)
        }
        
        runningTasks.remove(task.id)
        
        // Continue processing queue
        await processQueue()
    }
    
    /// Get queue status
    public func getStatus() -> QueueStatus {
        QueueStatus(
            queuedTasks: queue.count,
            runningTasks: runningTasks.count,
            maxConcurrentTasks: maxConcurrentTasks
        )
    }
    
    /// Cancel all tasks
    public func cancelAll() {
        queue.removeAll()
        logger.log("All background tasks cancelled", level: .info)
    }
}

/// Queued task information
private struct QueuedTask {
    let id: UUID
    let priority: TaskPriority
    let operation: () async throws -> Void
    let enqueuedAt: Date
}

/// Task priority levels
public enum TaskPriority: String {
    case critical
    case high
    case medium
    case low
    
    var value: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

/// Queue status information
public struct QueueStatus {
    public let queuedTasks: Int
    public let runningTasks: Int
    public let maxConcurrentTasks: Int
    
    public var availableCapacity: Int {
        maxConcurrentTasks - runningTasks
    }
    
    public var utilizationPercentage: Double {
        Double(runningTasks) / Double(maxConcurrentTasks) * 100
    }
}
