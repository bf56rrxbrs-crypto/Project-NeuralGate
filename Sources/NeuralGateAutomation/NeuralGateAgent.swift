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
        
        // Get AI decision
        let decision = try await decisionEngine.makeDecision(for: task, context: context)
        
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
    
    // MARK: - Private Methods
    
    private func recordTaskExecution(task: Task, result: TaskExecutionResult) {
        // Record for predictive analytics
        predictiveAnalytics.recordTask(task)
        
        // Record for usage pattern analysis
        let usageRecord = UsagePatternAnalyzer.UsageRecord(
            timestamp: Date(),
            taskCategory: task.category,
            taskPriority: task.priority,
            executionSuccess: result.status == .completed,
            executionTime: result.executionTime,
            resourceUsage: 0.5, // Would be measured in production
            userContext: UsagePatternAnalyzer.UsageRecord.UserContext(
                timeOfDay: UsagePatternAnalyzer.UsageRecord.UserContext.TimeOfDay.from(date: Date()),
                dayOfWeek: .monday, // Would be determined from current date
                deviceState: .active
            )
        )
        usageAnalyzer.recordUsage(usageRecord)
        
        // Record feature usage behavior
        let behaviorRecord = FeatureSuggestionEngine.BehaviorRecord(
            timestamp: Date(),
            action: .taskCreation,
            context: FeatureSuggestionEngine.BehaviorRecord.BehaviorContext(
                taskCategory: task.category,
                timeOfDay: "Morning",
                deviceState: "Active",
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

/// Comprehensive agent status
public struct AgentStatus {
    public let taskStatistics: TaskStatistics
    public let pipelineStatistics: DataPipelineStatistics
    public let feedbackAnalysis: FeedbackAnalysis
    public let performanceScore: Double
    public let isHealthy: Bool
}
