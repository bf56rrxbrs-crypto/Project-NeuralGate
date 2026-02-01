import Foundation
import NeuralGate
import NeuralGateAI

/// Feedback Loop System for continuous learning and improvement
public class FeedbackLoopSystem {
    private let configuration: NeuralGateConfiguration
    private var feedbackHistory: [TaskFeedback] = []
    private var adaptationRules: [AdaptationRule] = []
    private let logger = NeuralGateLogger.shared
    
    public init(configuration: NeuralGateConfiguration) {
        self.configuration = configuration
    }
    
    /// Record feedback for a completed task
    public func recordFeedback(_ feedback: TaskFeedback) {
        feedbackHistory.append(feedback)
        logger.log("Feedback recorded for task: \(feedback.taskId)", level: .info)
        
        // Analyze feedback and update adaptation rules
        analyzeFeedback()
    }
    
    /// Get adaptation suggestions based on feedback
    public func getAdaptations(for task: Task) -> [Adaptation] {
        var adaptations: [Adaptation] = []
        
        for rule in adaptationRules {
            if rule.appliesTo(task: task) {
                let adaptation = Adaptation(
                    type: rule.adaptationType,
                    description: rule.description,
                    confidence: rule.confidence,
                    impact: rule.estimatedImpact
                )
                adaptations.append(adaptation)
            }
        }
        
        return adaptations.sorted { $0.confidence > $1.confidence }
    }
    
    /// Analyze feedback to discover improvement opportunities
    private func analyzeFeedback() {
        logger.log("Analyzing feedback for improvements", level: .debug)
        
        // Group feedback by task category
        let categoryGroups = Dictionary(grouping: feedbackHistory) { $0.taskCategory }
        
        // Analyze each category
        for (category, feedbacks) in categoryGroups {
            // Calculate success rate
            let positiveCount = feedbacks.filter { $0.wasSuccessful }.count
            let successRate = Double(positiveCount) / Double(feedbacks.count)
            
            // Identify low-performing areas
            if successRate < 0.7 && feedbacks.count >= 5 {
                let rule = AdaptationRule(
                    category: category,
                    adaptationType: .increaseAttention,
                    description: "Increase attention to \(category.rawValue) tasks (current success: \(Int(successRate * 100))%)",
                    confidence: 1.0 - successRate,
                    estimatedImpact: 0.3
                )
                
                // Update or add rule
                if let index = adaptationRules.firstIndex(where: { $0.category == category && $0.adaptationType == .increaseAttention }) {
                    adaptationRules[index] = rule
                } else {
                    adaptationRules.append(rule)
                }
            }
            
            // Analyze execution time patterns
            let avgTime = feedbacks.compactMap { $0.executionTime }.reduce(0.0, +) / Double(feedbacks.count)
            if avgTime > 60.0 { // More than 1 minute average
                let rule = AdaptationRule(
                    category: category,
                    adaptationType: .optimizeExecution,
                    description: "Optimize execution for \(category.rawValue) tasks (avg time: \(Int(avgTime))s)",
                    confidence: 0.8,
                    estimatedImpact: 0.2
                )
                
                if let index = adaptationRules.firstIndex(where: { $0.category == category && $0.adaptationType == .optimizeExecution }) {
                    adaptationRules[index] = rule
                } else {
                    adaptationRules.append(rule)
                }
            }
        }
        
        logger.log("Adaptation rules updated: \(adaptationRules.count) rules", level: .info)
    }
}

/// Feedback record for a task
public struct TaskFeedback {
    public let taskId: UUID
    public let taskCategory: Task.TaskCategory
    public let wasSuccessful: Bool
    public let executionTime: TimeInterval?
    public let userRating: Int? // 1-5
    public let userComments: String?
    public let timestamp: Date
    
    public init(
        taskId: UUID,
        taskCategory: Task.TaskCategory,
        wasSuccessful: Bool,
        executionTime: TimeInterval? = nil,
        userRating: Int? = nil,
        userComments: String? = nil
    ) {
        self.taskId = taskId
        self.taskCategory = taskCategory
        self.wasSuccessful = wasSuccessful
        self.executionTime = executionTime
        self.userRating = userRating
        self.userComments = userComments
        self.timestamp = Date()
    }
}

/// Adaptation rule learned from feedback
public struct AdaptationRule {
    public let category: Task.TaskCategory
    public let adaptationType: AdaptationType
    public let description: String
    public let confidence: Double
    public let estimatedImpact: Double
    
    public func appliesTo(task: Task) -> Bool {
        return task.category == category
    }
    
    public enum AdaptationType: String {
        case increaseAttention
        case optimizeExecution
        case changeStrategy
        case addVerification
    }
}

/// Specific adaptation to apply
public struct Adaptation {
    public let type: AdaptationRule.AdaptationType
    public let description: String
    public let confidence: Double
    public let impact: Double
    
    public init(type: AdaptationRule.AdaptationType, description: String, confidence: Double, impact: Double) {
        self.type = type
        self.description = description
        self.confidence = confidence
        self.impact = impact
    }
}
