import Foundation
import NeuralGate

/// Predictive Analytics Engine for pattern recognition and task suggestions
public class PredictiveAnalytics {
    private let configuration: NeuralGateConfiguration
    private var taskHistory: [Task] = []
    private var patterns: [TaskPattern] = []
    private var patternIndex: [String: [TaskPattern]] = [:] // Hash-based index for O(1) lookup
    private let logger = NeuralGateLogger.shared
    
    public init(configuration: NeuralGateConfiguration) {
        self.configuration = configuration
    }
    
    /// Record task completion for pattern learning
    public func recordTask(_ task: Task) {
        taskHistory.append(task)
        
        // Keep only recent history (last 1000 tasks)
        if taskHistory.count > 1000 {
            taskHistory.removeFirst(taskHistory.count - 1000)
        }
        
        // Update patterns periodically
        if taskHistory.count % 10 == 0 {
            updatePatterns()
        }
    }
    
    /// Get predictive suggestions based on current context
    public func getSuggestions(context: ExecutionContext) -> [TaskSuggestion] {
        guard configuration.enablePredictiveAnalytics else {
            return []
        }
        
        logger.log("Generating predictive suggestions", level: .info)
        
        var suggestions: [TaskSuggestion] = []
        
        // Fast lookup using hash index
        if let currentTask = context.currentTask {
            let key = currentTask.category.rawValue
            if let matchingPatterns = patternIndex[key] {
                for pattern in matchingPatterns {
                    let suggestion = TaskSuggestion(
                        taskName: pattern.nextTaskName,
                        confidence: pattern.confidence,
                        reasoning: "Based on \(pattern.occurrences) similar past occurrences",
                        category: pattern.category
                    )
                    suggestions.append(suggestion)
                }
            }
        }
        
        // Sort by confidence and return top suggestions
        return suggestions.sorted { $0.confidence > $1.confidence }.prefix(5).map { $0 }
    }
    
    /// Analyze task patterns and identify frequently repeated sequences
    private func updatePatterns() {
        logger.log("Updating task patterns", level: .debug)
        
        // Group tasks by category and time window
        var categorySequences: [Task.TaskCategory: [[Task]]] = [:]
        
        for category in Task.TaskCategory.allCases {
            let categoryTasks = taskHistory.filter { $0.category == category }
            
            // Look for sequences within 1 hour windows
            var sequences: [[Task]] = []
            var currentSequence: [Task] = []
            
            for task in categoryTasks {
                if let last = currentSequence.last,
                   task.createdAt.timeIntervalSince(last.createdAt) < 3600 {
                    currentSequence.append(task)
                } else {
                    if currentSequence.count >= 2 {
                        sequences.append(currentSequence)
                    }
                    currentSequence = [task]
                }
            }
            
            if currentSequence.count >= 2 {
                sequences.append(currentSequence)
            }
            
            categorySequences[category] = sequences
        }
        
        // Extract patterns
        patterns.removeAll()
        
        for (category, sequences) in categorySequences {
            // Find most common sequences
            var sequenceMap: [String: (count: Int, nextTask: String)] = [:]
            
            for sequence in sequences where sequence.count >= 2 {
                let key = sequence.dropLast().map { $0.name }.joined(separator: "->")
                let nextTask = sequence.last!.name
                
                if let existing = sequenceMap[key] {
                    sequenceMap[key] = (existing.count + 1, nextTask)
                } else {
                    sequenceMap[key] = (1, nextTask)
                }
            }
            
            // Create patterns from frequent sequences
            for (_, value) in sequenceMap where value.count >= 3 {
                let pattern = TaskPattern(
                    nextTaskName: value.nextTask,
                    confidence: min(Double(value.count) / 10.0, 0.95),
                    category: category,
                    occurrences: value.count
                )
                patterns.append(pattern)
            }
        }
        
        logger.log("Updated patterns: \(patterns.count) patterns identified", level: .info)
        
        // Build hash index for fast lookups
        buildPatternIndex()
    }
    
    /// Build hash-based index for O(1) pattern lookups
    private func buildPatternIndex() {
        patternIndex.removeAll()
        
        for pattern in patterns {
            let key = pattern.category.rawValue
            if patternIndex[key] != nil {
                patternIndex[key]?.append(pattern)
            } else {
                patternIndex[key] = [pattern]
            }
        }
        
        logger.log("Built pattern index with \(patternIndex.count) categories", level: .debug)
    }
    
    /// Get analytics statistics
    public func getStatistics() -> AnalyticsStatistics {
        return AnalyticsStatistics(
            totalTasksRecorded: taskHistory.count,
            patternsDiscovered: patterns.count,
            categoriesWithPatterns: patternIndex.count,
            averageConfidence: patterns.isEmpty ? 0.0 : patterns.reduce(0.0) { $0 + $1.confidence } / Double(patterns.count)
        )
    }
}

/// Analytics statistics
public struct AnalyticsStatistics {
    public let totalTasksRecorded: Int
    public let patternsDiscovered: Int
    public let categoriesWithPatterns: Int
    public let averageConfidence: Double
}

/// Represents a discovered task pattern
public struct TaskPattern {
    public let nextTaskName: String
    public let confidence: Double
    public let category: Task.TaskCategory
    public let occurrences: Int
    
    public func matches(context: ExecutionContext) -> Bool {
        // Check if current context suggests this pattern
        guard let currentTask = context.currentTask else { return false }
        return currentTask.category == category
    }
}

/// Task suggestion from predictive analytics
public struct TaskSuggestion {
    public let taskName: String
    public let confidence: Double
    public let reasoning: String
    public let category: Task.TaskCategory
    
    public init(taskName: String, confidence: Double, reasoning: String, category: Task.TaskCategory) {
        self.taskName = taskName
        self.confidence = confidence
        self.reasoning = reasoning
        self.category = category
    }
}
