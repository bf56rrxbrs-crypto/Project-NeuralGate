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
        
        logger.log("NeuralGate Agent initialized", level: .info)
    }
    
    /// Execute a single task with full AI capabilities
    public func executeTask(_ task: Task) async throws -> TaskExecutionResult {
        logger.log("Executing task: \(task.name)", level: .info)
        
        let context = ExecutionContext(currentTask: task)
        
        // Get AI decision (used for logging and analytics)
        let decision = try await decisionEngine.makeDecision(for: task, context: context)
        logger.log("AI Decision: \(decision.value.rawValue) (confidence: \(decision.confidence))", level: .debug)
        
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
    
    // MARK: - Private Methods
    
    private func recordTaskExecution(task: Task, result: TaskExecutionResult) {
        // Record for predictive analytics
        predictiveAnalytics.recordTask(task)
        
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
