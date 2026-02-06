import Foundation
import NeuralGate

/// AI Decision Engine for task routing and intelligent decision making
public class AIDecisionEngine {
    private let configuration: NeuralGateConfiguration
    private var models: [AIModel]
    private let logger = NeuralGateLogger.shared
    
    // Performance optimizations
    private var decisionCache: [String: CachedDecision] = [:]
    private let cacheMaxSize = 100
    private var modelHealthScores: [String: Double] = [:]
    
    public init(configuration: NeuralGateConfiguration, models: [AIModel] = []) {
        self.configuration = configuration
        self.models = models.isEmpty ? [BaselineAIModel()] : models
        // Initialize health scores
        for model in self.models {
            modelHealthScores[model.name] = 1.0
        }
    }
    
    /// Make a decision using ensemble of AI models
    public func makeDecision(
        for task: Task,
        context: ExecutionContext
    ) async throws -> ExplainableResult<TaskDecision> {
        logger.log("Making decision for task: \(task.name)", level: .info)
        
        // Early exit optimization for critical tasks
        if task.priority == .critical && shouldUseEarlyExit(task: task) {
            logger.log("Using early exit for critical task", level: .debug)
            return ExplainableResult(
                value: .execute,
                explanation: "Critical priority task - fast-track execution",
                confidence: 0.95,
                factors: ["priority": 1.0, "early_exit": 1.0]
            )
        }
        
        // Check cache for recent similar decisions
        let cacheKey = generateCacheKey(task: task, context: context)
        if let cached = decisionCache[cacheKey], !cached.isExpired() {
            logger.log("Using cached decision", level: .debug)
            return cached.result
        }
        
        // Check resource constraints
        let totalEstimatedUsage = models.reduce(0) { $0 + $1.estimatedMemoryUsage }
        guard totalEstimatedUsage <= configuration.maxMemoryUsage else {
            throw NeuralGateError.resourceLimitExceeded
        }
        
        // Filter healthy models using circuit breaker pattern
        let healthyModels = models.filter { (modelHealthScores[$0.name] ?? 0) > 0.3 }
        guard !healthyModels.isEmpty else {
            // All models unhealthy, reset and try again
            resetModelHealth()
            throw NeuralGateError.modelLoadingFailed("All models are unhealthy")
        }
        
        // Get predictions from all models in parallel
        var predictions: [(model: String, decision: TaskDecision, confidence: Double)] = []
        
        await withTaskGroup(of: (String, TaskDecision, Double)?.self) { group in
            for model in healthyModels {
                group.addTask {
                    do {
                        let prediction = try await model.predict(task: task, context: context)
                        // Update health score on success
                        self.updateModelHealth(model.name, success: true)
                        return (model.name, prediction.decision, prediction.confidence)
                    } catch {
                        self.logger.log("Model \(model.name) failed: \(error)", level: .warning)
                        // Decrease health score on failure
                        self.updateModelHealth(model.name, success: false)
                        return nil
                    }
                }
            }
            
            for await result in group {
                if let prediction = result {
                    predictions.append(prediction)
                }
            }
        }
        
        guard !predictions.isEmpty else {
            throw NeuralGateError.taskExecutionFailed("All models failed to make predictions")
        }
        
        // Ensemble voting - weighted by confidence
        let decision = ensembleVote(predictions: predictions)
        
        // Calculate aggregate confidence
        let avgConfidence = predictions.reduce(0.0) { $0 + $1.confidence } / Double(predictions.count)
        
        // Build explanation
        let explanation = buildExplanation(predictions: predictions, finalDecision: decision)
        
        // Extract contributing factors
        let factors = extractFactors(task: task, predictions: predictions)
        
        let result = ExplainableResult(
            value: decision,
            explanation: explanation,
            confidence: avgConfidence,
            factors: factors
        )
        
        // Cache the decision
        cacheDecision(key: cacheKey, result: result)
        
        return result
    }
    
    // MARK: - Performance Optimization Methods
    
    /// Generate cache key for task and context
    private func generateCacheKey(task: Task, context: ExecutionContext) -> String {
        // Simple hash based on task properties
        return "\(task.priority.rawValue)_\(task.category.rawValue)_\(task.status.rawValue)"
    }
    
    /// Cache a decision result
    private func cacheDecision(key: String, result: ExplainableResult<TaskDecision>) {
        decisionCache[key] = CachedDecision(result: result, timestamp: Date())
        
        // Limit cache size using LRU-like eviction
        if decisionCache.count > cacheMaxSize {
            // Remove oldest entries
            let sortedKeys = decisionCache.keys.sorted {
                (decisionCache[$0]?.timestamp ?? Date.distantPast) < (decisionCache[$1]?.timestamp ?? Date.distantPast)
            }
            for key in sortedKeys.prefix(sortedKeys.count - cacheMaxSize) {
                decisionCache.removeValue(forKey: key)
            }
        }
    }
    
    /// Check if early exit should be used for high-priority tasks
    private func shouldUseEarlyExit(task: Task) -> Bool {
        // Use early exit for communication tasks with critical priority
        return task.category == .communication || task.category == .automation
    }
    
    /// Update model health score based on prediction success
    private func updateModelHealth(_ modelName: String, success: Bool) {
        let currentHealth = modelHealthScores[modelName] ?? 1.0
        // Exponential moving average: increase slowly on success, decrease quickly on failure
        let alpha = success ? 0.1 : 0.3
        let newHealth = success ? min(1.0, currentHealth + alpha * (1.0 - currentHealth)) : max(0.0, currentHealth - alpha)
        modelHealthScores[modelName] = newHealth
        
        if newHealth < 0.5 {
            logger.log("Model \(modelName) health degraded to \(newHealth)", level: .warning)
        }
    }
    
    /// Reset all model health scores
    private func resetModelHealth() {
        for model in models {
            modelHealthScores[model.name] = 1.0
        }
        logger.log("Reset all model health scores", level: .info)
    }
    
    /// Get model health metrics
    public func getModelHealthMetrics() -> [String: Double] {
        return modelHealthScores
    }
    
    /// Ensemble voting strategy
    private func ensembleVote(
        predictions: [(model: String, decision: TaskDecision, confidence: Double)]
    ) -> TaskDecision {
        // Weighted voting by confidence
        var votes: [TaskDecision: Double] = [:]
        
        for prediction in predictions {
            votes[prediction.decision, default: 0.0] += prediction.confidence
        }
        
        return votes.max(by: { $0.value < $1.value })?.key ?? .execute
    }
    
    /// Build human-readable explanation
    private func buildExplanation(
        predictions: [(model: String, decision: TaskDecision, confidence: Double)],
        finalDecision: TaskDecision
    ) -> String {
        guard configuration.enableExplainability else {
            return "Decision made by AI ensemble"
        }
        
        let modelCount = predictions.count
        let agreementCount = predictions.filter { $0.decision == finalDecision }.count
        let agreementPercentage = (Double(agreementCount) / Double(modelCount)) * 100
        
        var explanation = "Decision: \(finalDecision.rawValue)\n"
        explanation += "Based on \(modelCount) model(s) with \(String(format: "%.1f", agreementPercentage))% agreement.\n"
        
        for prediction in predictions {
            let indicator = prediction.decision == finalDecision ? "✓" : "✗"
            explanation += "\(indicator) \(prediction.model): \(prediction.decision.rawValue) (confidence: \(String(format: "%.2f", prediction.confidence)))\n"
        }
        
        return explanation
    }
    
    /// Extract contributing factors
    private func extractFactors(
        task: Task,
        predictions: [(model: String, decision: TaskDecision, confidence: Double)]
    ) -> [String: Double] {
        var factors: [String: Double] = [:]
        
        factors["priority"] = Double(task.priority.weight) / 4.0
        factors["model_agreement"] = Double(predictions.filter { $0.decision == ensembleVote(predictions: predictions) }.count) / Double(predictions.count)
        factors["avg_confidence"] = predictions.reduce(0.0) { $0 + $1.confidence } / Double(predictions.count)
        
        return factors
    }
}

/// Cached decision with expiration
private struct CachedDecision {
    let result: ExplainableResult<TaskDecision>
    let timestamp: Date
    let ttl: TimeInterval = 60.0 // 60 seconds cache lifetime
    
    func isExpired() -> Bool {
        return Date().timeIntervalSince(timestamp) > ttl
    }
}

/// Task decision types
public enum TaskDecision: String, Codable, Hashable {
    case execute
    case deferTask
    case delegate
    case skip
    case requiresUserInput
}

/// Protocol for AI models
public protocol AIModel: ResourceAware {
    var name: String { get }
    
    func predict(
        task: Task,
        context: ExecutionContext
    ) async throws -> ModelPrediction
}

/// Model prediction result
public struct ModelPrediction {
    public let decision: TaskDecision
    public let confidence: Double
    public let reasoning: String
    
    public init(decision: TaskDecision, confidence: Double, reasoning: String) {
        self.decision = decision
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

/// Baseline AI model implementation
public class BaselineAIModel: AIModel {
    public let name = "Baseline"
    
    public var estimatedMemoryUsage: Int { 5 }
    public var estimatedCPUUsage: Double { 0.1 }
    public var estimatedBatteryImpact: Double { 0.05 }
    
    public init() {}
    
    public func canExecute(configuration: NeuralGateConfiguration) -> Bool {
        return estimatedMemoryUsage <= configuration.maxMemoryUsage
    }
    
    public func predict(task: Task, context: ExecutionContext) async throws -> ModelPrediction {
        // Simple rule-based baseline
        let decision: TaskDecision
        let confidence: Double
        
        switch task.priority {
        case .critical:
            decision = .execute
            confidence = 0.95
        case .high:
            decision = .execute
            confidence = 0.85
        case .medium:
            decision = .execute
            confidence = 0.70
        case .low:
            decision = .deferTask
            confidence = 0.60
        }
        
        let reasoning = "Priority-based decision: \(task.priority.rawValue) priority tasks are \(decision.rawValue)d"
        
        return ModelPrediction(decision: decision, confidence: confidence, reasoning: reasoning)
    }
}
