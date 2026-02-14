import Foundation
import NeuralGate
import NeuralGateAI
import NeuralGateLearning

/// Main NeuralGate AI Agent - Comprehensive task and workflow automation for iPhone
public class NeuralGateAgent {
    // Configuration
    public let configuration: NeuralGateConfiguration
    
    // Core components
    private let decisionEngine: AIDecisionEngine
    private let automationEngine: WorkflowAutomationEngine
    private let taskManager: TaskManager
    
    // Learning components
    private let feedbackSystem: FeedbackLoopSystem
    private let improvementEngine: SelfImprovementEngine
    private let userFeedback: UserFeedbackIntegration
    private let dataPipeline: DataPipeline
    
    // Analytics
    private let predictiveAnalytics: PredictiveAnalytics
    
    // AI Enhancement Systems
    private let capabilityDiscovery: CapabilityDiscoveryEngine
    private let usageAnalyzer: UsagePatternAnalyzer
    private let modelRecommendation: ModelRecommendationSystem
    private let featureSuggestion: FeatureSuggestionEngine
    
    private let logger = NeuralGateLogger.shared
    
    /// Initialize the NeuralGate agent
    public init(configuration: NeuralGateConfiguration = NeuralGateConfiguration()) {
        self.configuration = configuration
        
        // Initialize logger
        logger.debugMode = configuration.debugMode
        
        // Initialize core components
        self.decisionEngine = AIDecisionEngine(configuration: configuration)
        self.taskManager = TaskManager(configuration: configuration)
        self.automationEngine = WorkflowAutomationEngine(
            configuration: configuration,
            decisionEngine: decisionEngine
        )
        
        // Initialize learning components
        self.feedbackSystem = FeedbackLoopSystem(configuration: configuration)
        self.improvementEngine = SelfImprovementEngine(configuration: configuration)
        self.userFeedback = UserFeedbackIntegration(configuration: configuration)
        self.dataPipeline = DataPipeline(configuration: configuration)
        
        // Initialize analytics
        self.predictiveAnalytics = PredictiveAnalytics(configuration: configuration)
        
        // Initialize AI enhancement systems
        self.capabilityDiscovery = CapabilityDiscoveryEngine(configuration: configuration)
        self.usageAnalyzer = UsagePatternAnalyzer(configuration: configuration)
        self.modelRecommendation = ModelRecommendationSystem(configuration: configuration)
        self.featureSuggestion = FeatureSuggestionEngine(configuration: configuration)
        
        logger.log("NeuralGate Agent initialized with AI enhancements", level: .info)
    }
    
    /// Execute a single task with full AI capabilities
    public func executeTask(_ task: Task) async throws -> TaskExecutionResult {
        logger.log("Executing task: \(task.name)", level: .info)
        
        let context = ExecutionContext(currentTask: task)
        
        // Get AI decision for task execution strategy
        _ = try await decisionEngine.makeDecision(for: task, context: context)
        
        // Get predictive suggestions
        let suggestions = predictiveAnalytics.getSuggestions(context: context)
        logger.log("Predictive suggestions: \(suggestions.count)", level: .debug)
        
        // Get adaptations from feedback
        let adaptations = feedbackSystem.getAdaptations(for: task)
        logger.log("Adaptations available: \(adaptations.count)", level: .debug)
        
        // Enqueue and execute
        taskManager.enqueueTask(task)
        
        guard let result = try await taskManager.executeNextTask() else {
            throw NeuralGateError.taskExecutionFailed("Failed to execute task")
        }
        
        // Record for learning
        recordTaskExecution(task: task, result: result)
        
        return result
    }
    
    /// Execute a workflow with full automation
    public func executeWorkflow(_ workflow: Workflow) async throws -> WorkflowResult {
        logger.log("Executing workflow: \(workflow.name)", level: .info)
        
        let result = try await automationEngine.executeWorkflow(workflow)
        
        // Record workflow execution
        recordWorkflowExecution(result: result)
        
        return result
    }
    
    /// Get intelligent task suggestions
    public func getTaskSuggestions() -> [TaskSuggestion] {
        let context = ExecutionContext()
        return predictiveAnalytics.getSuggestions(context: context)
    }
    
    /// Submit user feedback
    public func submitFeedback(_ feedback: UserFeedback) {
        userFeedback.submitFeedback(feedback)
        
        // Process feedback for learning
        processFeedbackForLearning(feedback)
    }
    
    /// Perform self-improvement evaluation
    public func performSelfImprovement() async throws -> PerformanceEvaluation {
        logger.log("Performing self-improvement evaluation", level: .info)
        
        let evaluation = improvementEngine.evaluatePerformance()
        
        // Execute highest priority improvement if needed
        if let topOpportunity = evaluation.opportunities.first {
            logger.log("Executing top improvement: \(topOpportunity.suggestedAction)", level: .info)
            _ = await improvementEngine.executeImprovement(topOpportunity)
        }
        
        return evaluation
    }
    
    /// Get comprehensive agent status
    public func getStatus() -> AgentStatus {
        let taskStats = taskManager.getStatistics()
        let pipelineStats = dataPipeline.getStatistics()
        let feedbackAnalysis = userFeedback.processFeedbackQueue()
        let evaluation = improvementEngine.evaluatePerformance()
        
        return AgentStatus(
            taskStatistics: taskStats,
            pipelineStatistics: pipelineStats,
            feedbackAnalysis: feedbackAnalysis,
            performanceScore: evaluation.overallScore,
            isHealthy: evaluation.overallScore > 0.7
        )
    }
    
    // MARK: - AI Enhancement API
    
    /// Analyze platform capabilities and get enhancement opportunities
    public func analyzeCapabilities() async -> [CapabilityDiscoveryEngine.EnhancementOpportunity] {
        logger.log("Analyzing platform capabilities", level: .info)
        return await capabilityDiscovery.analyzeCapabilities()
    }
    
    /// Generate comprehensive capability report
    public func generateCapabilityReport() -> String {
        return capabilityDiscovery.generateCapabilityReport()
    }
    
    /// Analyze usage patterns
    public func analyzeUsagePatterns() async -> [UsagePatternAnalyzer.UsagePattern] {
        logger.log("Analyzing usage patterns", level: .info)
        return await usageAnalyzer.analyzePatterns()
    }
    
    /// Identify usage gaps and opportunities
    public func identifyUsageGaps() async -> [UsagePatternAnalyzer.UsageGap] {
        logger.log("Identifying usage gaps", level: .info)
        return await usageAnalyzer.identifyGaps()
    }
    
    /// Get usage statistics
    public func getUsageStatistics() -> UsagePatternAnalyzer.UsageStatistics {
        return usageAnalyzer.getUsageStatistics()
    }
    
    /// Recommend optimal AI model for a task
    public func recommendModel(for task: Task, context: ExecutionContext) async -> ModelRecommendationSystem.ModelRecommendation {
        logger.log("Recommending AI model for task: \(task.name)", level: .info)
        return await modelRecommendation.recommendModel(for: task, context: context)
    }
    
    /// Get all available AI models
    public func getAvailableModels() -> [ModelRecommendationSystem.AIModelMetadata] {
        return modelRecommendation.getAvailableModels()
    }
    
    /// Generate AI model comparison report
    public func generateModelReport() -> String {
        return modelRecommendation.generateModelReport()
    }
    
    /// Generate feature suggestions based on user behavior
    public func generateFeatureSuggestions() async -> [FeatureSuggestionEngine.FeatureSuggestion] {
        logger.log("Generating feature suggestions", level: .info)
        return await featureSuggestion.generateSuggestions()
    }
    
    /// Get high-value feature suggestions
    public func getHighValueFeatures(threshold: Double = 0.80) -> [FeatureSuggestionEngine.FeatureSuggestion] {
        return featureSuggestion.getHighValueSuggestions(threshold: threshold)
    }
    
    /// Generate feature roadmap
    public func generateFeatureRoadmap() -> String {
        return featureSuggestion.generateRoadmap()
    }
    
    // MARK: - Convenience Methods
    
    /// Get comprehensive AI insights combining all enhancement systems
    /// - Returns: AIInsightsSummary containing analysis from all systems
    public func getAIInsights() async -> AIInsightsSummary {
        logger.log("Generating comprehensive AI insights", level: .info)
        
        let capabilities = await analyzeCapabilities()
        let patterns = await analyzeUsagePatterns()
        let gaps = await identifyUsageGaps()
        let suggestions = await generateFeatureSuggestions()
        let stats = getUsageStatistics()
        
        return AIInsightsSummary(
            capabilities: capabilities,
            patterns: patterns,
            gaps: gaps,
            suggestions: suggestions,
            usageStats: stats,
            timestamp: Date()
        )
    }
    
    /// Export all reports as formatted text
    /// - Returns: Combined report text from all AI enhancement systems
    public func exportAIReports() -> String {
        var report = """
        ╔═══════════════════════════════════════════════════════════════╗
        ║         NeuralGate AI Enhancement Systems Report              ║
        ║         Generated: \(Date().formatted())                      
        ╚═══════════════════════════════════════════════════════════════╝
        
        """
        
        report += "\n\n" + String(repeating: "=", count: 65)
        report += "\n📊 CAPABILITY ANALYSIS\n"
        report += String(repeating: "=", count: 65) + "\n\n"
        report += generateCapabilityReport()
        
        report += "\n\n" + String(repeating: "=", count: 65)
        report += "\n🤖 AI MODEL RECOMMENDATIONS\n"
        report += String(repeating: "=", count: 65) + "\n\n"
        report += generateModelReport()
        
        report += "\n\n" + String(repeating: "=", count: 65)
        report += "\n💡 FEATURE SUGGESTIONS\n"
        report += String(repeating: "=", count: 65) + "\n\n"
        report += generateFeatureRoadmap()
        
        return report
    }
    
    /// Check if AI enhancement analysis should run based on usage
    /// - Parameter minimumExecutions: Minimum task executions before analysis
    /// - Returns: True if analysis should run
    public func shouldRunAIAnalysis(minimumExecutions: Int = 10) -> Bool {
        let stats = getUsageStatistics()
        return stats.totalExecutions >= minimumExecutions
    }
    
    /// Get quick health check of AI enhancement systems
    /// - Returns: AIHealthStatus with system status
    public func getAIHealthStatus() -> AIHealthStatus {
        let stats = getUsageStatistics()
        let models = getAvailableModels()
        
        let healthScore: Double
        if stats.totalExecutions == 0 {
            healthScore = 1.0 // No data yet, assume healthy
        } else {
            // Health based on success rate and pattern detection
            healthScore = (stats.successRate * 0.7) + (stats.detectedPatterns > 0 ? 0.3 : 0.0)
        }
        
        return AIHealthStatus(
            isHealthy: healthScore >= 0.7,
            healthScore: healthScore,
            totalExecutions: stats.totalExecutions,
            successRate: stats.successRate,
            patternsDetected: stats.detectedPatterns,
            gapsIdentified: stats.identifiedGaps,
            availableModels: models.count,
            recommendation: healthScore >= 0.9 ? "Excellent" :
                          healthScore >= 0.7 ? "Good" :
                          healthScore >= 0.5 ? "Fair" : "Needs Attention"
        )
    }
    
    // MARK: - Private Methods
    
    private func recordTaskExecution(task: Task, result: TaskExecutionResult) {
        // Record for predictive analytics
        predictiveAnalytics.recordTask(task)
        
        // Record for usage pattern analysis
        let currentDate = Date()
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let dayOfWeek: UsagePatternAnalyzer.UsageRecord.UserContext.DayOfWeek = {
            switch weekday {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: return .monday
            }
        }()
        
        let usageRecord = UsagePatternAnalyzer.UsageRecord(
            timestamp: currentDate,
            taskCategory: task.category,
            taskPriority: task.priority,
            executionSuccess: result.status == .completed,
            executionTime: result.executionTime,
            resourceUsage: 0.3, // Conservative estimate - actual measurement requires platform APIs
            userContext: UsagePatternAnalyzer.UsageRecord.UserContext(
                timeOfDay: UsagePatternAnalyzer.UsageRecord.UserContext.TimeOfDay.from(date: currentDate),
                dayOfWeek: dayOfWeek,
                deviceState: .active // iOS app is active during task execution
            )
        )
        usageAnalyzer.recordUsage(usageRecord)
        
        // Record feature usage behavior
        let timeOfDay = UsagePatternAnalyzer.UsageRecord.UserContext.TimeOfDay.from(date: currentDate)
        let behaviorRecord = FeatureSuggestionEngine.BehaviorRecord(
            timestamp: currentDate,
            action: .taskCreation,
            context: FeatureSuggestionEngine.BehaviorRecord.BehaviorContext(
                taskCategory: task.category,
                timeOfDay: timeOfDay.rawValue,
                deviceState: "Active", // Device is active during task execution
                frequency: 1
            ),
            satisfaction: result.status == .completed ? 0.9 : 0.3
        )
        featureSuggestion.recordBehavior(behaviorRecord)
        
        // Record for self-improvement
        let taskResult = TaskResult(
            taskId: task.id,
            wasSuccessful: result.status == .completed,
            executionTime: result.executionTime,
            memoryUsed: 0, // Would be measured in production
            userRating: nil
        )
        improvementEngine.updateMetrics(taskResult: taskResult)
        
        // Add to data pipeline
        let dataPoint = DataPoint(
            taskCategory: task.category,
            features: ["priority": Double(task.priority.weight)],
            outcome: result.status == .completed ? .success : .failure
        )
        dataPipeline.addDataPoint(dataPoint)
    }
    
    private func recordWorkflowExecution(result: WorkflowResult) {
        logger.log("Workflow completed: \(result.workflow.name) (success rate: \(result.successRate))", level: .info)
        
        // Record each task in the workflow
        for taskResult in result.executedTasks {
            recordTaskExecution(task: taskResult.task, result: taskResult)
        }
    }
    
    private func processFeedbackForLearning(_ feedback: UserFeedback) {
        // Convert user feedback to task feedback if applicable
        if let taskId = feedback.taskId {
            let taskFeedback = TaskFeedback(
                taskId: taskId,
                taskCategory: .general, // Would be determined from task
                wasSuccessful: feedback.type == .positive,
                executionTime: nil,
                userRating: feedback.type == .positive ? 5 : 1,
                userComments: feedback.message
            )
            feedbackSystem.recordFeedback(taskFeedback)
        }
    }
}

// MARK: - AI Enhancement Support Types

/// Comprehensive AI insights from all enhancement systems
public struct AIInsightsSummary {
    public let capabilities: [CapabilityDiscoveryEngine.EnhancementOpportunity]
    public let patterns: [UsagePatternAnalyzer.UsagePattern]
    public let gaps: [UsagePatternAnalyzer.UsageGap]
    public let suggestions: [FeatureSuggestionEngine.FeatureSuggestion]
    public let usageStats: UsagePatternAnalyzer.UsageStatistics
    public let timestamp: Date
    
    /// Get top priority items across all systems
    public var topPriorities: [String] {
        var priorities: [String] = []
        
        // Add critical capabilities
        let criticalCaps = capabilities.filter { $0.priority == .critical }.prefix(3)
        priorities.append(contentsOf: criticalCaps.map { $0.suggestedEnhancement })
        
        // Add critical gaps
        let criticalGaps = gaps.filter { $0.severity == .critical }.prefix(3)
        priorities.append(contentsOf: criticalGaps.map { $0.description })
        
        // Add critical/high priority features
        let criticalFeatures = suggestions.filter { 
            $0.priority == .critical || $0.priority == .high 
        }.prefix(3)
        priorities.append(contentsOf: criticalFeatures.map { $0.name })
        
        return Array(priorities.prefix(10))
    }
    
    /// Get overall health score based on all metrics
    public var overallHealthScore: Double {
        let capabilityScore = capabilities.isEmpty ? 0.8 : 
            Double(capabilities.filter { $0.priority == .low || $0.priority == .medium }.count) / 
            Double(capabilities.count)
        
        let gapScore = gaps.isEmpty ? 1.0 : 
            1.0 - (Double(gaps.filter { $0.severity == .critical || $0.severity == .high }.count) / 
            Double(gaps.count))
        
        let usageScore = usageStats.successRate
        
        return (capabilityScore * 0.3 + gapScore * 0.3 + usageScore * 0.4)
    }
}

/// AI health status for quick checks
public struct AIHealthStatus {
    public let isHealthy: Bool
    public let healthScore: Double
    public let totalExecutions: Int
    public let successRate: Double
    public let patternsDetected: Int
    public let gapsIdentified: Int
    public let availableModels: Int
    public let recommendation: String
    
    /// Get formatted health report
    public var formattedReport: String {
        """
        ╔═══════════════════════════════════════════╗
        ║     NeuralGate AI Health Status           ║
        ╠═══════════════════════════════════════════╣
        ║ Status: \(isHealthy ? "✅ Healthy" : "⚠️  Needs Attention")                  
        ║ Health Score: \(Int(healthScore * 100))%                      
        ║ Success Rate: \(Int(successRate * 100))%                      
        ╠═══════════════════════════════════════════╣
        ║ Executions: \(totalExecutions)                          
        ║ Patterns: \(patternsDetected)                            
        ║ Gaps: \(gapsIdentified)                                
        ║ AI Models: \(availableModels)                           
        ╠═══════════════════════════════════════════╣
        ║ Recommendation: \(recommendation)              
        ╚═══════════════════════════════════════════╝
        """
    }
}


/// Comprehensive agent status
public struct AgentStatus {
    public let taskStatistics: TaskStatistics
    public let pipelineStatistics: DataPipelineStatistics
    public let feedbackAnalysis: FeedbackAnalysis
    public let performanceScore: Double
    public let isHealthy: Bool
}
