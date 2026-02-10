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
        
        // Load persistent state if available
        _Concurrency.Task {
            await self.loadPersistedState()
        }
    }
    
    /// Execute a single task with full AI capabilities and optimizations
    public func executeTask(_ task: Task) async throws -> TaskExecutionResult {
        let startTime = Date()
        logger.log("Executing task: \(task.name)", level: .info)
        
        // Dispatch webhook event
        await WebhookManager.shared.dispatch(WebhookEvent(
            type: WebhookEventType.taskStarted,
            data: ["taskId": task.id.uuidString, "taskName": task.name]
        ))
        
        let context = ExecutionContext(currentTask: task)
        
        // Check cache for similar task decisions
        let cacheKey = "decision:\(task.category):\(task.priority.rawValue)"
        let cachedDecision: ExplainableResult<TaskDecision>? = await CacheManager.shared.get(cacheKey)
        
        // Get AI decision (use cached if available for performance)
        let decision: ExplainableResult<TaskDecision>
        if let cachedDecision = cachedDecision, cachedDecision.confidence > 0.8 {
            decision = cachedDecision
            logger.log("Using cached AI decision", level: .debug)
        } else {
            decision = try await decisionEngine.makeDecision(for: task, context: context)
            // Cache decision for similar future tasks
            await CacheManager.shared.set(decision, forKey: cacheKey, ttl: 300)
        }
        logger.log("AI Decision: \(decision.value.rawValue) (confidence: \(decision.confidence))", level: .debug)
        
        // Get predictive suggestions (with caching)
        let suggestions = predictiveAnalytics.getSuggestions(context: context)
        logger.log("Predictive suggestions: \(suggestions.count)", level: .debug)
        
        // Get adaptations from feedback
        let adaptations = feedbackSystem.getAdaptations(for: task)
        logger.log("Adaptations available: \(adaptations.count)", level: .debug)
        
        // Enqueue and execute with background processing
        taskManager.enqueueTask(task)
        
        guard let result = try await taskManager.executeNextTask() else {
            // Dispatch failure webhook
            await WebhookManager.shared.dispatch(WebhookEvent(
                type: WebhookEventType.taskFailed,
                data: ["taskId": task.id.uuidString, "taskName": task.name, "reason": "Execution returned nil"]
            ))
            throw NeuralGateError.taskExecutionFailed("Failed to execute task")
        }
        
        // Record metrics
        let duration = Date().timeIntervalSince(startTime)
        await HealthMonitor.shared.recordTaskExecution(
            duration: duration,
            success: result.status == .completed
        )
        
        // Record for learning (async in background)
        await BackgroundTaskQueue.shared.enqueue(priority: .low) { [weak self] in
            self?.recordTaskExecution(task: task, result: result)
        }
        
        // Persist state
        await persistState()
        
        // Dispatch success webhook
        await WebhookManager.shared.dispatch(WebhookEvent(
            type: result.status == .completed ? WebhookEventType.taskCompleted : WebhookEventType.taskFailed,
            data: [
                "taskId": task.id.uuidString,
                "taskName": task.name,
                "status": "\(result.status)",
                "duration": "\(duration)"
            ]
        ))
        
        return result
    }
    
    /// Execute a workflow with full automation and webhook support
    public func executeWorkflow(_ workflow: Workflow) async throws -> WorkflowResult {
        let startTime = Date()
        logger.log("Executing workflow: \(workflow.name)", level: .info)
        
        // Dispatch workflow started webhook
        await WebhookManager.shared.dispatch(WebhookEvent(
            type: WebhookEventType.workflowStarted,
            data: ["workflowId": workflow.id.uuidString, "workflowName": workflow.name]
        ))
        
        let result = try await automationEngine.executeWorkflow(workflow)
        
        // Record workflow execution (async in background)
        await BackgroundTaskQueue.shared.enqueue(priority: .low) { [weak self] in
            self?.recordWorkflowExecution(result: result)
        }
        
        // Dispatch workflow completed webhook
        let duration = Date().timeIntervalSince(startTime)
        await WebhookManager.shared.dispatch(WebhookEvent(
            type: result.workflow.status == .completed ? WebhookEventType.workflowCompleted : WebhookEventType.workflowFailed,
            data: [
                "workflowId": workflow.id.uuidString,
                "workflowName": workflow.name,
                "status": "\(result.workflow.status)",
                "duration": "\(duration)",
                "successRate": "\(result.successRate)"
            ]
        ))
        
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
            let result = await improvementEngine.executeImprovement(topOpportunity)
            
            // Dispatch improvement webhook
            await WebhookManager.shared.dispatch(WebhookEvent(
                type: WebhookEventType.improvementExecuted,
                data: [
                    "area": topOpportunity.area.rawValue,
                    "success": "\(result.success)",
                    "improvement": "\(result.actualImprovement)"
                ]
            ))
        }
        
        return evaluation
    }
    
    /// Perform health check on all systems
    public func performHealthCheck() async -> HealthStatus {
        return await HealthMonitor.shared.performHealthCheck()
    }
    
    /// Get system metrics
    public func getMetrics() async -> HealthMetrics {
        return await HealthMonitor.shared.getMetrics()
    }
    
    /// Load persisted agent state
    private func loadPersistedState() async {
        do {
            let state = try await PersistenceManager.shared.load(
                PersistentAgentState.self,
                withKey: "agent_state"
            )
            logger.log("Loaded persisted state: \(state.completedTaskCount) tasks completed", level: .info)
        } catch {
            logger.log("No persisted state found or failed to load", level: .debug)
        }
    }
    
    /// Persist current agent state
    private func persistState() async {
        let taskStats = taskManager.getStatistics()
        let state = PersistentAgentState(
            completedTaskCount: taskStats.totalCompleted,
            failedTaskCount: taskStats.totalFailed,
            lastUpdateTime: Date(),
            configuration: CodableConfiguration(
                debugMode: configuration.debugMode,
                maxMemoryUsage: configuration.maxMemoryUsage,
                batteryOptimizationLevel: configuration.batteryOptimizationLevel,
                enablePredictiveAnalytics: configuration.enablePredictiveAnalytics,
                enableExplainability: configuration.enableExplainability
            )
        )
        
        do {
            try await PersistenceManager.shared.save(state, withKey: "agent_state")
        } catch {
            logger.log("Failed to persist state: \(error.localizedDescription)", level: .warning)
        }
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
