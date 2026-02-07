import Foundation

// Note: Task and Workflow models are defined in TaskModel.swift
// This file contains WorkflowStep, WorkflowResult, TaskResult and Intent models for the WorkflowEngine

/// Result of task execution
public struct TaskResult: Codable {
    public let taskId: UUID
    public let success: Bool
    public let output: String?
    public let duration: TimeInterval
    public let error: String?
    public let timestamp: Date
    
    public init(taskId: UUID, success: Bool, output: Any?, duration: TimeInterval, error: String?) {
        self.taskId = taskId
        self.success = success
        self.output = output.map { "\($0)" }
        self.duration = duration
        self.error = error
        self.timestamp = Date()
    }
}

// MARK: - Workflow Engine Support Models

/// A single step in a workflow definition
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

/// Step-based workflow definition (used internally by WorkflowEngine)
public struct StepWorkflow: Codable, Identifiable {
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

/// Result of workflow execution
public struct WorkflowResult: Codable {
    public let workflowId: UUID
    public let workflowName: String
    public let success: Bool
    public let stepResults: [TaskResult]
    public let duration: TimeInterval
    public let timestamp: Date
    
    public init(workflowId: UUID, workflowName: String, success: Bool, stepResults: [TaskResult], duration: TimeInterval) {
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
    public let priority: Task.Priority
    public let originalText: String
    public let confidence: Double
    
    public init(action: String, parameters: [String: Any], priority: Task.Priority, originalText: String, confidence: Double = 1.0) {
        self.action = action
        self.parameters = parameters
        self.priority = priority
        self.originalText = originalText
        self.confidence = confidence
    }
}
