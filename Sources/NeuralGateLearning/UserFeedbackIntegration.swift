import Foundation
import NeuralGate

/// User Feedback Integration System
public class UserFeedbackIntegration {
    private let configuration: NeuralGateConfiguration
    private var feedbackQueue: [UserFeedback] = []
    private let logger = NeuralGateLogger.shared
    
    public init(configuration: NeuralGateConfiguration) {
        self.configuration = configuration
    }
    
    /// Submit user feedback for a task or behavior
    public func submitFeedback(_ feedback: UserFeedback) {
        feedbackQueue.append(feedback)
        logger.log("User feedback received: \(feedback.type.rawValue)", level: .info)
        
        // Process feedback immediately for critical issues
        if feedback.severity == .critical {
            processCriticalFeedback(feedback)
        }
    }
    
    /// Get all pending feedback
    public func getPendingFeedback() -> [UserFeedback] {
        return feedbackQueue
    }
    
    /// Process and clear feedback queue
    public func processFeedbackQueue() -> FeedbackAnalysis {
        logger.log("Processing \(feedbackQueue.count) feedback items", level: .info)
        
        let analysis = analyzeFeedback(feedbackQueue)
        
        // Clear processed feedback
        feedbackQueue.removeAll()
        
        return analysis
    }
    
    /// Analyze feedback to extract insights
    private func analyzeFeedback(_ feedbacks: [UserFeedback]) -> FeedbackAnalysis {
        var positiveCount = 0
        var negativeCount = 0
        var bugReports = 0
        var featureRequests = 0
        var improvements: [String] = []
        
        for feedback in feedbacks {
            switch feedback.type {
            case .positive:
                positiveCount += 1
            case .negative:
                negativeCount += 1
            case .bugReport:
                bugReports += 1
            case .featureRequest:
                featureRequests += 1
            case .improvement:
                improvements.append(feedback.message)
            }
        }
        
        let satisfactionScore = feedbacks.isEmpty ? 0.0 : 
            Double(positiveCount) / Double(feedbacks.count)
        
        return FeedbackAnalysis(
            totalFeedback: feedbacks.count,
            positiveCount: positiveCount,
            negativeCount: negativeCount,
            bugReports: bugReports,
            featureRequests: featureRequests,
            satisfactionScore: satisfactionScore,
            topImprovements: improvements.prefix(5).map { $0 }
        )
    }
    
    /// Handle critical feedback immediately
    private func processCriticalFeedback(_ feedback: UserFeedback) {
        logger.log("Processing critical feedback: \(feedback.message)", level: .error)
        
        // In production, this would trigger immediate alerts or failsafe mechanisms
        // For now, we log and mark for urgent review
    }
}

/// User feedback record
public struct UserFeedback {
    public let id: UUID
    public let type: FeedbackType
    public let severity: Severity
    public let message: String
    public let taskId: UUID?
    public let timestamp: Date
    public var metadata: [String: String]
    
    public init(
        type: FeedbackType,
        severity: Severity = .normal,
        message: String,
        taskId: UUID? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = UUID()
        self.type = type
        self.severity = severity
        self.message = message
        self.taskId = taskId
        self.timestamp = Date()
        self.metadata = metadata
    }
    
    public enum FeedbackType: String {
        case positive
        case negative
        case bugReport
        case featureRequest
        case improvement
    }
    
    public enum Severity: String {
        case low
        case normal
        case high
        case critical
    }
}

/// Analysis result of user feedback
public struct FeedbackAnalysis {
    public let totalFeedback: Int
    public let positiveCount: Int
    public let negativeCount: Int
    public let bugReports: Int
    public let featureRequests: Int
    public let satisfactionScore: Double
    public let topImprovements: [String]
}
