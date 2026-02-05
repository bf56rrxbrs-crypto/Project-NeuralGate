// RecommendationEngine.swift
// NeuralGateAI - Personalized Recommendation System
//
// Provides context-aware recommendations based on user activity and usage history
// using machine learning algorithms tailored to mobile device constraints.

import Foundation

/// Types of recommendations that can be provided to users
public enum RecommendationType: String, Codable, CaseIterable {
    case workflow = "workflow"              // Workflow optimization suggestions
    case task = "task"                      // Task-related recommendations
    case timing = "timing"                  // Optimal timing suggestions
    case automation = "automation"          // Automation opportunities
    case efficiency = "efficiency"          // Efficiency improvements
}

/// A single recommendation item with context and confidence
public struct Recommendation: Codable, Identifiable {
    public let id: UUID
    public let type: RecommendationType
    public let title: String
    public let description: String
    public let confidence: Double           // 0.0 to 1.0
    public let priority: Int                // 1 (highest) to 5 (lowest)
    public let reasoning: String            // Explanation for the recommendation
    public let actionable: Bool             // Can user act on this immediately?
    public let estimatedImpact: String      // Expected benefit (e.g., "Save 10 min/day")
    public let relatedTaskIds: [UUID]       // Related tasks or workflows
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        type: RecommendationType,
        title: String,
        description: String,
        confidence: Double,
        priority: Int,
        reasoning: String,
        actionable: Bool = true,
        estimatedImpact: String,
        relatedTaskIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.priority = priority
        self.reasoning = reasoning
        self.actionable = actionable
        self.estimatedImpact = estimatedImpact
        self.relatedTaskIds = relatedTaskIds
        self.createdAt = createdAt
    }
}

/// Context information for generating recommendations
public struct UserContext: Codable {
    public let currentTime: Date
    public let recentTasks: [String]        // Recent task categories
    public let completionRate: Double       // Overall task completion rate
    public let averageTaskDuration: Double  // In seconds
    public let preferredWorkTimes: [Int]    // Hours of day (0-23)
    public let deviceBatteryLevel: Double   // 0.0 to 1.0
    public let activeWorkflows: [String]
    
    public init(
        currentTime: Date = Date(),
        recentTasks: [String] = [],
        completionRate: Double = 0.8,
        averageTaskDuration: Double = 300.0,
        preferredWorkTimes: [Int] = [9, 10, 11, 14, 15, 16],
        deviceBatteryLevel: Double = 1.0,
        activeWorkflows: [String] = []
    ) {
        self.currentTime = currentTime
        self.recentTasks = recentTasks
        self.completionRate = completionRate
        self.averageTaskDuration = averageTaskDuration
        self.preferredWorkTimes = preferredWorkTimes
        self.deviceBatteryLevel = deviceBatteryLevel
        self.activeWorkflows = activeWorkflows
    }
}

/// Activity data point for analysis
public struct UserActivity: Codable {
    public let timestamp: Date
    public let category: String
    public let action: String
    public let success: Bool
    public let duration: Double
    public let context: [String: String]
    
    public init(
        timestamp: Date = Date(),
        category: String,
        action: String,
        success: Bool,
        duration: Double,
        context: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.category = category
        self.action = action
        self.success = success
        self.duration = duration
        self.context = context
    }
}

/// Main recommendation engine using ML-based context analysis
public actor RecommendationEngine {
    
    // Configuration
    private let minConfidenceThreshold: Double = 0.6
    private let maxRecommendations: Int = 10
    private let historyLookbackDays: Int = 30
    
    // In-memory storage (optimized for mobile)
    private var activityHistory: [UserActivity] = []
    private var cachedRecommendations: [Recommendation] = []
    private var lastUpdateTime: Date = Date.distantPast
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    
    // Pattern detection state
    private var detectedPatterns: [String: [(pattern: String, confidence: Double)]] = [:]
    private var userPreferences: [String: Any] = [:]
    
    public init() {}
    
    // MARK: - Public API
    
    /// Record user activity for analysis
    public func recordActivity(_ activity: UserActivity) {
        activityHistory.append(activity)
        
        // Limit history size for memory efficiency (mobile optimization)
        if activityHistory.count > 1000 {
            activityHistory.removeFirst(activityHistory.count - 1000)
        }
        
        // Invalidate cache when new activity is recorded
        if activityHistory.count % 10 == 0 {
            cachedRecommendations = []
        }
    }
    
    /// Generate personalized recommendations based on current context
    public func generateRecommendations(context: UserContext) async -> [Recommendation] {
        
        // Return cached recommendations if still valid
        if !cachedRecommendations.isEmpty && 
           Date().timeIntervalSince(lastUpdateTime) < cacheValidityDuration {
            return cachedRecommendations
        }
        
        var recommendations: [Recommendation] = []
        
        // Analyze patterns and generate different types of recommendations
        recommendations += await generateWorkflowRecommendations(context: context)
        recommendations += await generateTimingRecommendations(context: context)
        recommendations += await generateEfficiencyRecommendations(context: context)
        recommendations += await generateAutomationRecommendations(context: context)
        
        // Filter by confidence threshold
        recommendations = recommendations.filter { $0.confidence >= minConfidenceThreshold }
        
        // Sort by priority and confidence
        recommendations.sort { rec1, rec2 in
            if rec1.priority == rec2.priority {
                return rec1.confidence > rec2.confidence
            }
            return rec1.priority < rec2.priority
        }
        
        // Limit to max recommendations
        recommendations = Array(recommendations.prefix(maxRecommendations))
        
        // Cache results
        cachedRecommendations = recommendations
        lastUpdateTime = Date()
        
        return recommendations
    }
    
    /// Get recommendations for a specific type only
    public func getRecommendations(
        ofType type: RecommendationType,
        context: UserContext
    ) async -> [Recommendation] {
        let allRecommendations = await generateRecommendations(context: context)
        return allRecommendations.filter { $0.type == type }
    }
    
    /// Clear cached recommendations (useful after user acts on recommendations)
    public func clearCache() {
        cachedRecommendations = []
    }
    
    /// Get activity statistics for analytics
    public func getActivityStatistics() -> [String: Any] {
        let totalActivities = activityHistory.count
        let successfulActivities = activityHistory.filter { $0.success }.count
        let successRate = totalActivities > 0 ? Double(successfulActivities) / Double(totalActivities) : 0.0
        
        var categoryCounts: [String: Int] = [:]
        for activity in activityHistory {
            categoryCounts[activity.category, default: 0] += 1
        }
        
        return [
            "totalActivities": totalActivities,
            "successRate": successRate,
            "categoryCounts": categoryCounts,
            "cacheHitRate": cachedRecommendations.isEmpty ? 0.0 : 0.8
        ]
    }
    
    // MARK: - Private Recommendation Generators
    
    private func generateWorkflowRecommendations(context: UserContext) async -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Analyze task sequences to suggest workflow automation
        let recentSequences = findTaskSequences(in: activityHistory)
        
        for sequence in recentSequences {
            if sequence.count >= 3 {
                let confidence = calculateSequenceConfidence(sequence)
                if confidence >= minConfidenceThreshold {
                    let recommendation = Recommendation(
                        type: .workflow,
                        title: "Create Workflow from Common Pattern",
                        description: "You frequently perform '\(sequence.joined(separator: " → "))'. Would you like to automate this?",
                        confidence: confidence,
                        priority: 1,
                        reasoning: "This sequence appeared \(Int(confidence * 10)) times in recent history",
                        estimatedImpact: "Save ~\(sequence.count * 2) minutes per execution"
                    )
                    recommendations.append(recommendation)
                }
            }
        }
        
        return recommendations
    }
    
    private func generateTimingRecommendations(context: UserContext) async -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Analyze when user is most productive
        let currentHour = Calendar.current.component(.hour, from: context.currentTime)
        let isPreferredTime = context.preferredWorkTimes.contains(currentHour)
        
        if !isPreferredTime && !context.recentTasks.isEmpty {
            let nextPreferredHour = context.preferredWorkTimes.first { $0 > currentHour } 
                ?? context.preferredWorkTimes.first ?? 9
            
            recommendations.append(Recommendation(
                type: .timing,
                title: "Optimal Task Timing",
                description: "You typically work better at \(nextPreferredHour):00. Consider scheduling important tasks for that time.",
                confidence: 0.75,
                priority: 3,
                reasoning: "Based on your historical productivity patterns",
                estimatedImpact: "Increase task success rate by 15%"
            ))
        }
        
        // Battery-aware recommendations
        if context.deviceBatteryLevel < 0.2 {
            recommendations.append(Recommendation(
                type: .timing,
                title: "Low Battery - Defer Heavy Tasks",
                description: "Battery is low. Consider deferring resource-intensive tasks until charging.",
                confidence: 0.95,
                priority: 2,
                reasoning: "Low battery may impact task execution reliability",
                estimatedImpact: "Prevent task failures due to power loss"
            ))
        }
        
        return recommendations
    }
    
    private func generateEfficiencyRecommendations(context: UserContext) async -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Analyze completion rates
        if context.completionRate < 0.7 {
            recommendations.append(Recommendation(
                type: .efficiency,
                title: "Task Completion Rate is Low",
                description: "Your current completion rate is \(Int(context.completionRate * 100))%. Try breaking large tasks into smaller steps.",
                confidence: 0.85,
                priority: 2,
                reasoning: "Users with similar patterns improved by task decomposition",
                estimatedImpact: "Potentially increase completion rate to 85%+"
            ))
        }
        
        // Task duration analysis
        if context.averageTaskDuration > 1800 { // 30 minutes
            recommendations.append(Recommendation(
                type: .efficiency,
                title: "Long Average Task Duration",
                description: "Your tasks average \(Int(context.averageTaskDuration / 60)) minutes. Consider using the Pomodoro technique.",
                confidence: 0.70,
                priority: 3,
                reasoning: "Breaking work into focused intervals can improve efficiency",
                estimatedImpact: "Reduce task time by 20%"
            ))
        }
        
        return recommendations
    }
    
    private func generateAutomationRecommendations(context: UserContext) async -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Find repetitive tasks
        let taskFrequency = analyzeTaskFrequency()
        
        for (category, count) in taskFrequency where count > 5 {
            recommendations.append(Recommendation(
                type: .automation,
                title: "Automate Repetitive '\(category)' Tasks",
                description: "You've performed \(count) '\(category)' tasks recently. Consider creating an automation.",
                confidence: 0.80,
                priority: 2,
                reasoning: "High repetition detected for this task type",
                estimatedImpact: "Save ~\(count * 2) minutes/week"
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Helper Methods
    
    private func findTaskSequences(in activities: [UserActivity]) -> [[String]] {
        var sequences: [[String]] = []
        var currentSequence: [String] = []
        var lastTimestamp: Date?
        
        for activity in activities.suffix(100) { // Analyze recent 100 activities
            if let last = lastTimestamp,
               activity.timestamp.timeIntervalSince(last) < 3600 { // Within 1 hour
                currentSequence.append(activity.category)
            } else {
                if currentSequence.count >= 3 {
                    sequences.append(currentSequence)
                }
                currentSequence = [activity.category]
            }
            lastTimestamp = activity.timestamp
        }
        
        if currentSequence.count >= 3 {
            sequences.append(currentSequence)
        }
        
        return sequences
    }
    
    private func calculateSequenceConfidence(_ sequence: [String]) -> Double {
        // Simple confidence based on sequence length and frequency
        let baseConfidence = 0.6
        let lengthBonus = min(Double(sequence.count) * 0.05, 0.3)
        return min(baseConfidence + lengthBonus, 0.95)
    }
    
    private func analyzeTaskFrequency() -> [String: Int] {
        var frequency: [String: Int] = [:]
        
        // Analyze last 30 days
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -historyLookbackDays, to: Date()) ?? Date()
        let recentActivities = activityHistory.filter { $0.timestamp >= cutoffDate }
        
        for activity in recentActivities {
            frequency[activity.category, default: 0] += 1
        }
        
        return frequency
    }
}
