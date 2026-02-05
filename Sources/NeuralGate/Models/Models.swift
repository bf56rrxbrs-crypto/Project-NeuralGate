import Foundation

// MARK: - Workflow Execution Models (for WorkflowEngine)

/// Represents a single executable workflow task (legacy model for workflow engine)
public struct WorkflowTask: Codable, Identifiable {
    public let id: String
    public let type: String
    public let parameters: [String: String]
    public let priority: TaskPriority
    public var status: TaskStatus
    public let createdAt: Date
    
    public init(id: String, type: String, parameters: [String: Any], priority: TaskPriority) {
        self.id = id
        self.type = type
        // Convert Any to String for Codable support
        self.parameters = parameters.mapValues { "\($0)" }
        self.priority = priority
        self.status = .pending
        self.createdAt = Date()
    }
}

/// Task execution priority
public enum TaskPriority: String, Codable {
    case low
    case normal
    case high
    case critical
}

/// Task execution status
public enum TaskStatus: String, Codable {
    case pending
    case running
    case completed
    case failed
    case cancelled
}

/// Result of task execution
public struct TaskResult: Codable {
    public let taskId: String
    public let success: Bool
    public let output: String?
    public let duration: TimeInterval
    public let error: String?
    public let timestamp: Date
    
    public init(taskId: String, success: Bool, output: Any?, duration: TimeInterval, error: String?) {
        self.taskId = taskId
        self.success = success
        self.output = output.map { "\($0)" }
        self.duration = duration
        self.error = error
        self.timestamp = Date()
    }
}

// MARK: - Workflow Engine Models

/// Represents a workflow containing multiple steps (for workflow engine)
public struct WorkflowDefinition: Codable, Identifiable {
    public let id: String
    public let name: String
    public let steps: [WorkflowStep]
    public let createdAt: Date
    public var isActive: Bool
    
    public init(id: String, name: String, steps: [WorkflowStep]) {
        self.id = id
        self.name = name
        self.steps = steps
        self.createdAt = Date()
        self.isActive = true
    }
}

/// A single step in a workflow
public struct WorkflowStep: Codable {
    public let action: String
    public let parameters: [String: String]
    public let isCritical: Bool
    
    public init(action: String, parameters: [String: Any], isCritical: Bool) {
        self.action = action
        self.parameters = parameters.mapValues { "\($0)" }
        self.isCritical = isCritical
    }
}

/// Result of workflow execution
public struct WorkflowResult: Codable {
    public let workflowId: String
    public let workflowName: String
    public let success: Bool
    public let stepResults: [TaskResult]
    public let duration: TimeInterval
    public let timestamp: Date
    
    public init(workflowId: String, workflowName: String, success: Bool, stepResults: [TaskResult], duration: TimeInterval) {
        self.workflowId = workflowId
        self.workflowName = workflowName
        self.success = success
        self.stepResults = stepResults
        self.duration = duration
        self.timestamp = Date()
    }
}

// MARK: - Intent Models

/// Represents user intent parsed from natural language
public struct Intent {
    public let action: String
    public let parameters: [String: Any]
    public let priority: TaskPriority
    public let originalText: String
    public let confidence: Double
    
    public init(action: String, parameters: [String: Any], priority: TaskPriority, originalText: String, confidence: Double = 1.0) {
        self.action = action
        self.parameters = parameters
        self.priority = priority
        self.originalText = originalText
        self.confidence = confidence
    }
}
