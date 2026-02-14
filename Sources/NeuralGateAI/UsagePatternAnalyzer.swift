import Foundation
import NeuralGate

/// Advanced AI system for analyzing usage patterns and detecting gaps/opportunities
public class UsagePatternAnalyzer {
    private let configuration: NeuralGateConfiguration
    private var usageData: [UsageRecord] = []
    private var detectedPatterns: [UsagePattern] = []
    private var identifiedGaps: [UsageGap] = []
    private let logger = NeuralGateLogger.shared
    
    public init(configuration: NeuralGateConfiguration) {
        self.configuration = configuration
    }
    
    /// Represents a single usage record
    public struct UsageRecord {
        public let timestamp: Date
        public let taskCategory: Task.TaskCategory
        public let taskPriority: Task.Priority
        public let executionSuccess: Bool
        public let executionTime: TimeInterval
        public let resourceUsage: Double
        public let userContext: UserContext
        
        public init(
            timestamp: Date,
            taskCategory: Task.TaskCategory,
            taskPriority: Task.Priority,
            executionSuccess: Bool,
            executionTime: TimeInterval,
            resourceUsage: Double,
            userContext: UserContext
        ) {
            self.timestamp = timestamp
            self.taskCategory = taskCategory
            self.taskPriority = taskPriority
            self.executionSuccess = executionSuccess
            self.executionTime = executionTime
            self.resourceUsage = resourceUsage
            self.userContext = userContext
        }
        
        public struct UserContext {
            public let timeOfDay: TimeOfDay
            public let dayOfWeek: DayOfWeek
            public let deviceState: DeviceState
            
            public init(
                timeOfDay: TimeOfDay,
                dayOfWeek: DayOfWeek,
                deviceState: DeviceState
            ) {
                self.timeOfDay = timeOfDay
                self.dayOfWeek = dayOfWeek
                self.deviceState = deviceState
            }
            
            public enum TimeOfDay: String {
                case earlyMorning = "Early Morning" // 5am-9am
                case midMorning = "Mid Morning"     // 9am-12pm
                case afternoon = "Afternoon"        // 12pm-5pm
                case evening = "Evening"            // 5pm-10pm
                case night = "Night"                // 10pm-5am
                
                public static func from(date: Date) -> TimeOfDay {
                    let hour = Calendar.current.component(.hour, from: date)
                    switch hour {
                    case 5..<9: return .earlyMorning
                    case 9..<12: return .midMorning
                    case 12..<17: return .afternoon
                    case 17..<22: return .evening
                    default: return .night
                    }
                }
            }
            
            public enum DayOfWeek: String, CaseIterable {
                case monday, tuesday, wednesday, thursday, friday, saturday, sunday
                
                public var isWeekday: Bool {
                    switch self {
                    case .monday, .tuesday, .wednesday, .thursday, .friday: return true
                    case .saturday, .sunday: return false
                    }
                }
            }
            
            public enum DeviceState: String {
                case active = "Active"
                case background = "Background"
                case locked = "Locked"
                case charging = "Charging"
            }
        }
    }
    
    /// Detected usage pattern
    public struct UsagePattern {
        public let name: String
        public let description: String
        public let frequency: Double // 0.0 to 1.0
        public let confidence: Double // 0.0 to 1.0
        public let context: PatternContext
        public let occurrences: Int
        public let averageSuccessRate: Double
        
        public struct PatternContext {
            public let timeOfDay: UsageRecord.UserContext.TimeOfDay?
            public let dayOfWeek: UsageRecord.UserContext.DayOfWeek?
            public let taskCategories: [Task.TaskCategory]
            public let typicalDuration: TimeInterval
        }
    }
    
    /// Identified usage gap or opportunity
    public struct UsageGap {
        public let type: GapType
        public let description: String
        public let severity: Severity
        public let affectedArea: Task.TaskCategory
        public let opportunityDescription: String
        public let recommendedAction: String
        public let potentialValue: Double // Estimated value increase 0.0 to 1.0
        
        public enum GapType: String {
            case underutilization = "Underutilization"
            case missingFeature = "Missing Feature"
            case inefficiency = "Inefficiency"
            case errorPattern = "Error Pattern"
            case unusedContext = "Unused Context"
        }
        
        public enum Severity: String, Comparable {
            case low = "Low"
            case medium = "Medium"
            case high = "High"
            case critical = "Critical"
            
            public static func < (lhs: Severity, rhs: Severity) -> Bool {
                let order: [Severity] = [.low, .medium, .high, .critical]
                return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
            }
        }
    }
    
    /// Record a usage event
    public func recordUsage(_ record: UsageRecord) {
        usageData.append(record)
        
        // Keep only recent history (last 10,000 records)
        if usageData.count > 10000 {
            usageData.removeFirst(usageData.count - 10000)
        }
        
        // Note: Patterns are analyzed on-demand via analyzePatterns() method
    }
    
    /// Analyze usage data to detect patterns
    public func analyzePatterns() async -> [UsagePattern] {
        guard usageData.count >= 20 else {
            logger.log("Insufficient data for pattern analysis", level: .debug)
            return []
        }
        
        logger.log("Analyzing usage patterns from \(usageData.count) records", level: .info)
        
        detectedPatterns = []
        
        // Analyze temporal patterns
        detectedPatterns.append(contentsOf: analyzeTemporalPatterns())
        
        // Analyze category patterns
        detectedPatterns.append(contentsOf: analyzeCategoryPatterns())
        
        // Analyze context patterns
        detectedPatterns.append(contentsOf: analyzeContextPatterns())
        
        logger.log("Detected \(detectedPatterns.count) usage patterns", level: .info)
        return detectedPatterns
    }
    
    /// Analyze temporal patterns (time-based behaviors)
    private func analyzeTemporalPatterns() -> [UsagePattern] {
        var patterns: [UsagePattern] = []
        
        // Group by time of day
        let timeGroups = Dictionary(grouping: usageData) { record in
            record.userContext.timeOfDay
        }
        
        for (timeOfDay, records) in timeGroups where records.count >= 5 {
            let frequency = Double(records.count) / Double(usageData.count)
            let successRate = Double(records.filter { $0.executionSuccess }.count) / Double(records.count)
            let avgDuration = records.reduce(0.0) { $0 + $1.executionTime } / Double(records.count)
            
            let categories = Array(Set(records.map { $0.taskCategory }))
            
            patterns.append(UsagePattern(
                name: "\(timeOfDay.rawValue) Usage",
                description: "High activity during \(timeOfDay.rawValue) with \(categories.count) task categories",
                frequency: frequency,
                confidence: min(0.95, Double(records.count) / 100.0),
                context: UsagePattern.PatternContext(
                    timeOfDay: timeOfDay,
                    dayOfWeek: nil,
                    taskCategories: categories,
                    typicalDuration: avgDuration
                ),
                occurrences: records.count,
                averageSuccessRate: successRate
            ))
        }
        
        return patterns
    }
    
    /// Analyze category-based patterns
    private func analyzeCategoryPatterns() -> [UsagePattern] {
        var patterns: [UsagePattern] = []
        
        let categoryGroups = Dictionary(grouping: usageData) { $0.taskCategory }
        
        for (category, records) in categoryGroups where records.count >= 10 {
            let frequency = Double(records.count) / Double(usageData.count)
            let successRate = Double(records.filter { $0.executionSuccess }.count) / Double(records.count)
            let avgDuration = records.reduce(0.0) { $0 + $1.executionTime } / Double(records.count)
            
            // Find most common time
            let timeGroups = Dictionary(grouping: records) { $0.userContext.timeOfDay }
            let mostCommonTime = timeGroups.max(by: { $0.value.count < $1.value.count })?.key
            
            patterns.append(UsagePattern(
                name: "\(category.rawValue) Tasks",
                description: "Frequent \(category.rawValue) tasks, typically during \(mostCommonTime?.rawValue ?? "various times")",
                frequency: frequency,
                confidence: min(0.90, Double(records.count) / 50.0),
                context: UsagePattern.PatternContext(
                    timeOfDay: mostCommonTime,
                    dayOfWeek: nil,
                    taskCategories: [category],
                    typicalDuration: avgDuration
                ),
                occurrences: records.count,
                averageSuccessRate: successRate
            ))
        }
        
        return patterns
    }
    
    /// Analyze context-based patterns
    private func analyzeContextPatterns() -> [UsagePattern] {
        var patterns: [UsagePattern] = []
        
        // Weekday vs Weekend patterns
        let weekdayRecords = usageData.filter { $0.userContext.dayOfWeek.isWeekday }
        let weekendRecords = usageData.filter { !$0.userContext.dayOfWeek.isWeekday }
        
        if weekdayRecords.count >= 10 {
            let successRate = Double(weekdayRecords.filter { $0.executionSuccess }.count) / Double(weekdayRecords.count)
            let avgDuration = weekdayRecords.reduce(0.0) { $0 + $1.executionTime } / Double(weekdayRecords.count)
            let categories = Array(Set(weekdayRecords.map { $0.taskCategory }))
            
            patterns.append(UsagePattern(
                name: "Weekday Pattern",
                description: "Consistent weekday usage with focus on \(categories.first?.rawValue ?? "various") tasks",
                frequency: Double(weekdayRecords.count) / Double(usageData.count),
                confidence: 0.85,
                context: UsagePattern.PatternContext(
                    timeOfDay: nil,
                    dayOfWeek: nil,
                    taskCategories: categories,
                    typicalDuration: avgDuration
                ),
                occurrences: weekdayRecords.count,
                averageSuccessRate: successRate
            ))
        }
        
        if weekendRecords.count >= 5 {
            let successRate = Double(weekendRecords.filter { $0.executionSuccess }.count) / Double(weekendRecords.count)
            let avgDuration = weekendRecords.reduce(0.0) { $0 + $1.executionTime } / Double(weekendRecords.count)
            let categories = Array(Set(weekendRecords.map { $0.taskCategory }))
            
            patterns.append(UsagePattern(
                name: "Weekend Pattern",
                description: "Different weekend behavior focusing on \(categories.first?.rawValue ?? "leisure") tasks",
                frequency: Double(weekendRecords.count) / Double(usageData.count),
                confidence: 0.80,
                context: UsagePattern.PatternContext(
                    timeOfDay: nil,
                    dayOfWeek: nil,
                    taskCategories: categories,
                    typicalDuration: avgDuration
                ),
                occurrences: weekendRecords.count,
                averageSuccessRate: successRate
            ))
        }
        
        return patterns
    }
    
    /// Identify gaps and opportunities in usage
    public func identifyGaps() async -> [UsageGap] {
        guard usageData.count >= 20 else {
            logger.log("Insufficient data for gap analysis", level: .debug)
            return []
        }
        
        logger.log("Identifying usage gaps and opportunities", level: .info)
        
        identifiedGaps = []
        
        // Check for underutilized categories
        identifiedGaps.append(contentsOf: identifyUnderutilizedCategories())
        
        // Check for error patterns
        identifiedGaps.append(contentsOf: identifyErrorPatterns())
        
        // Check for inefficiencies
        identifiedGaps.append(contentsOf: identifyInefficiencies())
        
        // Check for unused contexts
        identifiedGaps.append(contentsOf: identifyUnusedContexts())
        
        // Sort by severity and potential value
        identifiedGaps.sort { lhs, rhs in
            if lhs.severity != rhs.severity {
                return lhs.severity > rhs.severity
            }
            return lhs.potentialValue > rhs.potentialValue
        }
        
        logger.log("Identified \(identifiedGaps.count) usage gaps", level: .info)
        return identifiedGaps
    }
    
    /// Identify underutilized task categories
    private func identifyUnderutilizedCategories() -> [UsageGap] {
        var gaps: [UsageGap] = []
        
        let categoryUsage = Dictionary(grouping: usageData) { $0.taskCategory }
        let totalRecords = Double(usageData.count)
        
        for category in Task.TaskCategory.allCases {
            let usage = categoryUsage[category]?.count ?? 0
            let usageRate = Double(usage) / totalRecords
            
            if usageRate < 0.05 && usage < 5 {
                gaps.append(UsageGap(
                    type: .underutilization,
                    description: "\(category.rawValue) tasks are rarely used (\(usage) times)",
                    severity: .medium,
                    affectedArea: category,
                    opportunityDescription: "Increase awareness and accessibility of \(category.rawValue) capabilities",
                    recommendedAction: "Add contextual prompts and tutorials for \(category.rawValue) tasks",
                    potentialValue: 0.65
                ))
            }
        }
        
        return gaps
    }
    
    /// Identify error patterns
    private func identifyErrorPatterns() -> [UsageGap] {
        var gaps: [UsageGap] = []
        
        let categoryErrors = Dictionary(grouping: usageData.filter { !$0.executionSuccess }) { $0.taskCategory }
        
        for (category, errors) in categoryErrors where errors.count >= 3 {
            let totalForCategory = usageData.filter { $0.taskCategory == category }.count
            let errorRate = Double(errors.count) / Double(totalForCategory)
            
            if errorRate > 0.15 { // More than 15% error rate
                gaps.append(UsageGap(
                    type: .errorPattern,
                    description: "\(category.rawValue) tasks have high failure rate (\(Int(errorRate * 100))%)",
                    severity: errorRate > 0.30 ? .high : .medium,
                    affectedArea: category,
                    opportunityDescription: "Improve reliability and error handling for \(category.rawValue)",
                    recommendedAction: "Analyze error causes and implement enhanced failover mechanisms",
                    potentialValue: 0.85
                ))
            }
        }
        
        return gaps
    }
    
    /// Identify inefficiencies in execution
    private func identifyInefficiencies() -> [UsageGap] {
        var gaps: [UsageGap] = []
        
        // Analyze execution times by category
        let categoryGroups = Dictionary(grouping: usageData) { $0.taskCategory }
        
        for (category, records) in categoryGroups where records.count >= 5 {
            let avgTime = records.reduce(0.0) { $0 + $1.executionTime } / Double(records.count)
            let maxTime = records.map { $0.executionTime }.max() ?? 0
            
            // If max time is more than 3x average, there's an efficiency issue
            if maxTime > avgTime * 3.0 && avgTime > 1.0 {
                gaps.append(UsageGap(
                    type: .inefficiency,
                    description: "\(category.rawValue) tasks show inconsistent performance (avg: \(String(format: "%.1fs", avgTime)), max: \(String(format: "%.1fs", maxTime)))",
                    severity: .medium,
                    affectedArea: category,
                    opportunityDescription: "Optimize \(category.rawValue) task execution for consistent performance",
                    recommendedAction: "Profile and optimize slow execution paths",
                    potentialValue: 0.70
                ))
            }
        }
        
        return gaps
    }
    
    /// Identify unused context opportunities
    private func identifyUnusedContexts() -> [UsageGap] {
        var gaps: [UsageGap] = []
        
        // Check if we're using context effectively
        let timeVariety = Set(usageData.map { $0.userContext.timeOfDay }).count
        
        if timeVariety < 3 && usageData.count > 50 {
            gaps.append(UsageGap(
                type: .unusedContext,
                description: "Tasks are only executed during limited times (\(timeVariety) different periods)",
                severity: .low,
                affectedArea: .automation,
                opportunityDescription: "Enable time-aware automation for broader coverage",
                recommendedAction: "Implement scheduled and context-triggered task execution",
                potentialValue: 0.75
            ))
        }
        
        return gaps
    }
    
    /// Get comprehensive usage statistics
    public func getUsageStatistics() -> UsageStatistics {
        let totalRecords = usageData.count
        let successfulRecords = usageData.filter { $0.executionSuccess }.count
        let avgExecutionTime = totalRecords > 0 ? usageData.reduce(0.0) { $0 + $1.executionTime } / Double(totalRecords) : 0
        
        let categoryDistribution = Dictionary(grouping: usageData) { $0.taskCategory }
            .mapValues { Double($0.count) / Double(totalRecords) }
        
        return UsageStatistics(
            totalExecutions: totalRecords,
            successRate: totalRecords > 0 ? Double(successfulRecords) / Double(totalRecords) : 0,
            averageExecutionTime: avgExecutionTime,
            categoryDistribution: categoryDistribution,
            detectedPatterns: detectedPatterns.count,
            identifiedGaps: identifiedGaps.count
        )
    }
    
    public struct UsageStatistics {
        public let totalExecutions: Int
        public let successRate: Double
        public let averageExecutionTime: TimeInterval
        public let categoryDistribution: [Task.TaskCategory: Double]
        public let detectedPatterns: Int
        public let identifiedGaps: Int
        
        /// Get formatted statistics text
        public var formattedSummary: String {
            var summary = """
            Usage Statistics:
            - Total Executions: \(totalExecutions)
            - Success Rate: \(Int(successRate * 100))%
            - Avg Execution Time: \(String(format: "%.2f", averageExecutionTime))s
            - Detected Patterns: \(detectedPatterns)
            - Identified Gaps: \(identifiedGaps)
            
            Category Distribution:
            """
            
            for (category, percentage) in categoryDistribution.sorted(by: { $0.value > $1.value }) {
                summary += "\n  - \(category.rawValue): \(Int(percentage * 100))%"
            }
            
            return summary
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Get gaps by severity
    /// - Parameter severity: The severity level to filter by
    /// - Returns: Array of gaps with the specified severity
    public func getGaps(withSeverity severity: UsageGap.Severity) -> [UsageGap] {
        return identifiedGaps.filter { $0.severity == severity }
    }
    
    /// Get gaps by type
    /// - Parameter type: The gap type to filter by
    /// - Returns: Array of gaps of the specified type
    public func getGaps(ofType type: UsageGap.GapType) -> [UsageGap] {
        return identifiedGaps.filter { $0.type == type }
    }
    
    /// Get most frequent task category
    /// - Returns: The most frequently used task category, or nil if no data
    public func getMostFrequentCategory() -> Task.TaskCategory? {
        return self.usageData.reduce(into: [Task.TaskCategory: Int]()) { counts, record in
            counts[record.taskCategory, default: 0] += 1
        }.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get peak usage time
    /// - Returns: The time of day with highest activity
    public func getPeakUsageTime() -> UsageRecord.UserContext.TimeOfDay? {
        return self.usageData.reduce(into: [UsageRecord.UserContext.TimeOfDay: Int]()) { counts, record in
            counts[record.userContext.timeOfDay, default: 0] += 1
        }.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get trends over time
    /// - Returns: UsageTrends with trend analysis
    public func getTrends() -> UsageTrends {
        let recentCount = 100
        let recentRecords = self.usageData.suffix(recentCount)
        let olderRecords = self.usageData.dropLast(recentCount)
        
        let recentSuccessRate = recentRecords.isEmpty ? 0 : 
            Double(recentRecords.filter { $0.executionSuccess }.count) / Double(recentRecords.count)
        let olderSuccessRate = olderRecords.isEmpty ? 0 :
            Double(olderRecords.filter { $0.executionSuccess }.count) / Double(olderRecords.count)
        
        let recentAvgTime = recentRecords.isEmpty ? 0 :
            recentRecords.reduce(0.0) { $0 + $1.executionTime } / Double(recentRecords.count)
        let olderAvgTime = olderRecords.isEmpty ? 0 :
            olderRecords.reduce(0.0) { $0 + $1.executionTime } / Double(olderRecords.count)
        
        return UsageTrends(
            successRateTrend: recentSuccessRate - olderSuccessRate,
            executionTimeTrend: recentAvgTime - olderAvgTime,
            isImproving: recentSuccessRate > olderSuccessRate && recentAvgTime <= olderAvgTime
        )
    }
}

/// Usage trends over time
public struct UsageTrends {
    public let successRateTrend: Double // Positive means improving
    public let executionTimeTrend: TimeInterval // Negative means faster
    public let isImproving: Bool
    
    public var formattedSummary: String {
        let successEmoji = successRateTrend > 0 ? "📈" : successRateTrend < 0 ? "📉" : "➡️"
        let timeEmoji = executionTimeTrend < 0 ? "⚡" : executionTimeTrend > 0 ? "🐌" : "➡️"
        
        return """
        Usage Trends:
        \(successEmoji) Success Rate: \(successRateTrend >= 0 ? "+" : "")\(String(format: "%.1f", successRateTrend * 100))%
        \(timeEmoji) Execution Time: \(executionTimeTrend >= 0 ? "+" : "")\(String(format: "%.2f", executionTimeTrend))s
        Overall: \(isImproving ? "✅ Improving" : "⚠️  Needs Attention")
        """
    }
}
