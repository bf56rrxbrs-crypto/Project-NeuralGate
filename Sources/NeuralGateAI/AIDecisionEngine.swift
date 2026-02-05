import Foundation
import NeuralGate

/// AI Decision Engine for task routing and intelligent decision making
public class AIDecisionEngine {
    private let configuration: NeuralGateConfiguration
    private var models: [AIModel]
    private let logger = NeuralGateLogger.shared
    
    public init(configuration: NeuralGateConfiguration, models: [AIModel] = []) {
        self.configuration = configuration
        self.models = models.isEmpty ? [BaselineAIModel()] : models
    }
    
    /// Make a decision using ensemble of AI models
    public func makeDecision(
        for task: Task,
        context: ExecutionContext
    ) async throws -> ExplainableResult<TaskDecision> {
        logger.log("Making decision for task: \(task.name)", level: .info)
        
        // Check resource constraints
        let totalEstimatedUsage = models.reduce(0) { $0 + $1.estimatedMemoryUsage }
        guard totalEstimatedUsage <= configuration.maxMemoryUsage else {
            throw NeuralGateError.resourceLimitExceeded
        }
        
        // Get predictions from all models
        var predictions: [(model: String, decision: TaskDecision, confidence: Double)] = []
        
        for model in models {
            do {
                let prediction = try await model.predict(task: task, context: context)
                predictions.append((model.name, prediction.decision, prediction.confidence))
            } catch {
                logger.log("Model \(model.name) failed: \(error)", level: .warning)
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
        
        return ExplainableResult(
            value: decision,
            explanation: explanation,
            confidence: avgConfidence,
            factors: factors
        )
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
