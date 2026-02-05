import Foundation
import NeuralGate

/// AI-powered system to recommend optimal AI models for different scenarios
public class ModelRecommendationSystem {
    private let configuration: NeuralGateConfiguration
    private var availableModels: [AIModelMetadata] = []
    private var modelPerformanceHistory: [String: ModelPerformance] = [:]
    private let logger = NeuralGateLogger.shared
    
    public init(configuration: NeuralGateConfiguration) {
        self.configuration = configuration
        self.initializeModelCatalog()
    }
    
    /// Metadata about an AI model
    public struct AIModelMetadata {
        public let name: String
        public let type: ModelType
        public let capabilities: Set<ModelCapability>
        public let resourceRequirements: ResourceRequirements
        public let suitability: [Task.TaskCategory: Double]
        public let averageAccuracy: Double
        public let trainingDataSize: Int
        
        public enum ModelType: String, CaseIterable {
            case rulesBased = "Rules-Based"
            case machineLearning = "Machine Learning"
            case deepLearning = "Deep Learning"
            case ensemble = "Ensemble"
            case hybrid = "Hybrid"
            case reinforcementLearning = "Reinforcement Learning"
        }
        
        public enum ModelCapability: String, CaseIterable, Hashable {
            case classification = "Classification"
            case regression = "Regression"
            case clustering = "Clustering"
            case sequenceAnalysis = "Sequence Analysis"
            case patternRecognition = "Pattern Recognition"
            case nlp = "NLP"
            case timeSeriesForecasting = "Time Series Forecasting"
            case anomalyDetection = "Anomaly Detection"
            case optimization = "Optimization"
            case recommendation = "Recommendation"
        }
        
        public struct ResourceRequirements {
            public let memoryMB: Int
            public let cpuIntensity: CPUIntensity
            public let batteryImpact: BatteryImpact
            public let inferenceTimeMS: Int
            
            public enum CPUIntensity: String, Comparable {
                case low = "Low"
                case medium = "Medium"
                case high = "High"
                case veryHigh = "Very High"
                
                public static func < (lhs: CPUIntensity, rhs: CPUIntensity) -> Bool {
                    let order: [CPUIntensity] = [.low, .medium, .high, .veryHigh]
                    return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
                }
            }
            
            public enum BatteryImpact: String, Comparable {
                case minimal = "Minimal"
                case low = "Low"
                case moderate = "Moderate"
                case high = "High"
                
                public static func < (lhs: BatteryImpact, rhs: BatteryImpact) -> Bool {
                    let order: [BatteryImpact] = [.minimal, .low, .moderate, .high]
                    return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
                }
            }
        }
    }
    
    /// Performance tracking for a model
    public struct ModelPerformance {
        public let modelName: String
        public var executionCount: Int
        public var averageAccuracy: Double
        public var averageInferenceTime: TimeInterval
        public var successRate: Double
        public var lastUsed: Date
        public var resourceEfficiency: Double // 0.0 to 1.0
    }
    
    /// Model recommendation result
    public struct ModelRecommendation {
        public let model: AIModelMetadata
        public let confidence: Double
        public let reasoning: String
        public let alternativeModels: [AIModelMetadata]
        public let expectedPerformance: ExpectedPerformance
        
        public struct ExpectedPerformance {
            public let accuracy: Double
            public let inferenceTime: TimeInterval
            public let resourceUsage: Double
            public let batteryImpact: AIModelMetadata.ResourceRequirements.BatteryImpact
        }
    }
    
    /// Initialize model catalog with available models
    private func initializeModelCatalog() {
        availableModels = [
            // Baseline Rules-Based Model
            AIModelMetadata(
                name: "BaselineRulesEngine",
                type: .rulesBased,
                capabilities: [.classification, .optimization],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 5,
                    cpuIntensity: .low,
                    batteryImpact: .minimal,
                    inferenceTimeMS: 10
                ),
                suitability: [
                    .automation: 0.85,
                    .general: 0.80,
                    .productivity: 0.75,
                    .communication: 0.70,
                    .learning: 0.60
                ],
                averageAccuracy: 0.75,
                trainingDataSize: 0
            ),
            
            // Pattern Recognition ML Model
            AIModelMetadata(
                name: "PatternRecognitionML",
                type: .machineLearning,
                capabilities: [.patternRecognition, .classification, .sequenceAnalysis],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 25,
                    cpuIntensity: .medium,
                    batteryImpact: .low,
                    inferenceTimeMS: 50
                ),
                suitability: [
                    .automation: 0.90,
                    .productivity: 0.88,
                    .communication: 0.85,
                    .general: 0.75,
                    .analytics: 0.80
                ],
                averageAccuracy: 0.85,
                trainingDataSize: 10000
            ),
            
            // Deep Learning Model
            AIModelMetadata(
                name: "DeepLearningClassifier",
                type: .deepLearning,
                capabilities: [.classification, .patternRecognition, .nlp],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 75,
                    cpuIntensity: .high,
                    batteryImpact: .moderate,
                    inferenceTimeMS: 150
                ),
                suitability: [
                    .communication: 0.95,
                    .productivity: 0.92,
                    .automation: 0.88,
                    .learning: 0.85,
                    .analytics: 0.80
                ],
                averageAccuracy: 0.92,
                trainingDataSize: 100000
            ),
            
            // Time Series Forecaster
            AIModelMetadata(
                name: "TimeSeriesForecaster",
                type: .machineLearning,
                capabilities: [.timeSeriesForecasting, .sequenceAnalysis, .patternRecognition],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 35,
                    cpuIntensity: .medium,
                    batteryImpact: .low,
                    inferenceTimeMS: 80
                ),
                suitability: [
                    .automation: 0.92,
                    .productivity: 0.88,
                    .general: 0.80,
                    .analytics: 0.85,
                    .communication: 0.75
                ],
                averageAccuracy: 0.87,
                trainingDataSize: 50000
            ),
            
            // Anomaly Detection Model
            AIModelMetadata(
                name: "AnomalyDetector",
                type: .machineLearning,
                capabilities: [.anomalyDetection, .patternRecognition, .clustering],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 20,
                    cpuIntensity: .medium,
                    batteryImpact: .low,
                    inferenceTimeMS: 40
                ),
                suitability: [
                    .general: 0.95,
                    .analytics: 0.88,
                    .automation: 0.82,
                    .productivity: 0.75,
                    .communication: 0.70
                ],
                averageAccuracy: 0.83,
                trainingDataSize: 25000
            ),
            
            // Recommendation Engine
            AIModelMetadata(
                name: "RecommendationEngine",
                type: .hybrid,
                capabilities: [.recommendation, .patternRecognition, .clustering],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 30,
                    cpuIntensity: .medium,
                    batteryImpact: .low,
                    inferenceTimeMS: 60
                ),
                suitability: [
                    .learning: 0.95,
                    .communication: 0.88,
                    .productivity: 0.85,
                    .automation: 0.80,
                    .analytics: 0.75
                ],
                averageAccuracy: 0.86,
                trainingDataSize: 75000
            ),
            
            // Reinforcement Learning Agent
            AIModelMetadata(
                name: "ReinforcementLearningAgent",
                type: .reinforcementLearning,
                capabilities: [.optimization, .sequenceAnalysis, .patternRecognition],
                resourceRequirements: AIModelMetadata.ResourceRequirements(
                    memoryMB: 50,
                    cpuIntensity: .high,
                    batteryImpact: .moderate,
                    inferenceTimeMS: 120
                ),
                suitability: [
                    .automation: 0.95,
                    .general: 0.88,
                    .productivity: 0.85,
                    .analytics: 0.82,
                    .communication: 0.75
                ],
                averageAccuracy: 0.89,
                trainingDataSize: 200000
            )
        ]
    }
    
    /// Recommend the best AI model for a given task and context
    public func recommendModel(
        for task: Task,
        context: ExecutionContext
    ) async -> ModelRecommendation {
        logger.log("Recommending AI model for task: \(task.name)", level: .info)
        
        // Filter models based on resource constraints
        let viableModels = availableModels.filter { model in
            model.resourceRequirements.memoryMB <= configuration.maxMemoryUsage &&
            matchesBatteryConstraints(model: model)
        }
        
        guard !viableModels.isEmpty else {
            // Fallback to baseline
            let baseline = availableModels.first { $0.type == .rulesBased }!
            return createRecommendation(for: baseline, task: task, confidence: 0.5, alternatives: [])
        }
        
        // Score each model
        var scoredModels: [(model: AIModelMetadata, score: Double)] = []
        
        for model in viableModels {
            let score = calculateModelScore(model: model, task: task, context: context)
            scoredModels.append((model, score))
        }
        
        // Sort by score
        scoredModels.sort { $0.score > $1.score }
        
        // Select top model and alternatives
        let topModel = scoredModels[0].model
        let alternatives = scoredModels.dropFirst().prefix(3).map { $0.model }
        
        let confidence = calculateConfidence(score: scoredModels[0].score, alternatives: scoredModels.dropFirst().prefix(3).map { $0.score })
        
        return createRecommendation(
            for: topModel,
            task: task,
            confidence: confidence,
            alternatives: Array(alternatives)
        )
    }
    
    /// Calculate suitability score for a model
    private func calculateModelScore(
        model: AIModelMetadata,
        task: Task,
        context: ExecutionContext
    ) -> Double {
        var score = 0.0
        
        // Category suitability (40% weight)
        let categorySuitability = model.suitability[task.category] ?? 0.5
        score += categorySuitability * 0.4
        
        // Accuracy (30% weight)
        score += model.averageAccuracy * 0.3
        
        // Resource efficiency (20% weight)
        let resourceScore = calculateResourceScore(model: model)
        score += resourceScore * 0.2
        
        // Historical performance (10% weight)
        if let performance = modelPerformanceHistory[model.name] {
            let historyScore = (performance.successRate + performance.resourceEfficiency) / 2.0
            score += historyScore * 0.1
        }
        
        // Priority adjustment
        if task.priority == .critical || task.priority == .high {
            // Prefer accuracy over efficiency for high-priority tasks
            score += (model.averageAccuracy - 0.5) * 0.1
        }
        
        return min(1.0, score)
    }
    
    /// Calculate resource efficiency score
    private func calculateResourceScore(model: AIModelMetadata) -> Double {
        let memoryScore = 1.0 - (Double(model.resourceRequirements.memoryMB) / 100.0)
        let cpuScore: Double = {
            switch model.resourceRequirements.cpuIntensity {
            case .low: return 1.0
            case .medium: return 0.7
            case .high: return 0.4
            case .veryHigh: return 0.2
            }
        }()
        let batteryScore: Double = {
            switch model.resourceRequirements.batteryImpact {
            case .minimal: return 1.0
            case .low: return 0.8
            case .moderate: return 0.5
            case .high: return 0.2
            }
        }()
        
        return (memoryScore + cpuScore + batteryScore) / 3.0
    }
    
    /// Check if model matches battery optimization level
    private func matchesBatteryConstraints(model: AIModelMetadata) -> Bool {
        switch configuration.batteryOptimizationLevel {
        case 0, 1:
            return true // All models allowed
        case 2:
            return model.resourceRequirements.batteryImpact <= .moderate
        case 3:
            return model.resourceRequirements.batteryImpact <= .low
        default:
            return model.resourceRequirements.batteryImpact == .minimal
        }
    }
    
    /// Calculate confidence in recommendation
    private func calculateConfidence(score: Double, alternatives: [Double]) -> Double {
        guard !alternatives.isEmpty else {
            return score
        }
        
        // Confidence is higher when there's a clear winner
        let topAlternative = alternatives.max() ?? 0
        let gap = score - topAlternative
        
        return min(1.0, score * 0.7 + gap * 0.3)
    }
    
    /// Create recommendation object
    private func createRecommendation(
        for model: AIModelMetadata,
        task: Task,
        confidence: Double,
        alternatives: [AIModelMetadata]
    ) -> ModelRecommendation {
        let reasoning = buildReasoning(for: model, task: task, confidence: confidence)
        
        let expectedPerformance = ModelRecommendation.ExpectedPerformance(
            accuracy: model.averageAccuracy,
            inferenceTime: Double(model.resourceRequirements.inferenceTimeMS) / 1000.0,
            resourceUsage: Double(model.resourceRequirements.memoryMB) / 100.0,
            batteryImpact: model.resourceRequirements.batteryImpact
        )
        
        return ModelRecommendation(
            model: model,
            confidence: confidence,
            reasoning: reasoning,
            alternativeModels: alternatives,
            expectedPerformance: expectedPerformance
        )
    }
    
    /// Build human-readable reasoning
    private func buildReasoning(for model: AIModelMetadata, task: Task, confidence: Double) -> String {
        let suitability = model.suitability[task.category] ?? 0.5
        
        var reasoning = "Recommended \(model.name) (\(model.type.rawValue)) "
        reasoning += "with \(Int(confidence * 100))% confidence. "
        reasoning += "This model has \(Int(suitability * 100))% suitability for \(task.category.rawValue) tasks "
        reasoning += "and \(Int(model.averageAccuracy * 100))% average accuracy. "
        reasoning += "Resource requirements: \(model.resourceRequirements.memoryMB)MB memory, "
        reasoning += "\(model.resourceRequirements.cpuIntensity.rawValue) CPU, "
        reasoning += "\(model.resourceRequirements.batteryImpact.rawValue) battery impact."
        
        return reasoning
    }
    
    /// Record model performance
    public func recordPerformance(
        modelName: String,
        accuracy: Double,
        inferenceTime: TimeInterval,
        success: Bool,
        resourceUsage: Double
    ) {
        if var performance = modelPerformanceHistory[modelName] {
            // Update existing performance
            let count = Double(performance.executionCount)
            performance.averageAccuracy = (performance.averageAccuracy * count + accuracy) / (count + 1)
            performance.averageInferenceTime = (performance.averageInferenceTime * count + inferenceTime) / (count + 1)
            performance.successRate = (performance.successRate * count + (success ? 1.0 : 0.0)) / (count + 1)
            performance.resourceEfficiency = (performance.resourceEfficiency * count + (1.0 - resourceUsage)) / (count + 1)
            performance.executionCount += 1
            performance.lastUsed = Date()
            modelPerformanceHistory[modelName] = performance
        } else {
            // Create new performance record
            modelPerformanceHistory[modelName] = ModelPerformance(
                modelName: modelName,
                executionCount: 1,
                averageAccuracy: accuracy,
                averageInferenceTime: inferenceTime,
                successRate: success ? 1.0 : 0.0,
                lastUsed: Date(),
                resourceEfficiency: 1.0 - resourceUsage
            )
        }
    }
    
    /// Get all available models
    public func getAvailableModels() -> [AIModelMetadata] {
        return availableModels
    }
    
    /// Get models by capability
    public func getModelsByCapability(_ capability: AIModelMetadata.ModelCapability) -> [AIModelMetadata] {
        return availableModels.filter { $0.capabilities.contains(capability) }
    }
    
    /// Get model performance history
    public func getPerformanceHistory() -> [String: ModelPerformance] {
        return modelPerformanceHistory
    }
    
    /// Generate model comparison report
    public func generateModelReport() -> String {
        var report = "# AI Model Catalog Report\n\n"
        
        report += "## Available Models\n\n"
        for model in availableModels.sorted(by: { $0.averageAccuracy > $1.averageAccuracy }) {
            report += "### \(model.name)\n"
            report += "- Type: \(model.type.rawValue)\n"
            report += "- Accuracy: \(Int(model.averageAccuracy * 100))%\n"
            report += "- Memory: \(model.resourceRequirements.memoryMB)MB\n"
            report += "- CPU: \(model.resourceRequirements.cpuIntensity.rawValue)\n"
            report += "- Battery: \(model.resourceRequirements.batteryImpact.rawValue)\n"
            report += "- Inference: \(model.resourceRequirements.inferenceTimeMS)ms\n"
            report += "- Capabilities: \(model.capabilities.map { $0.rawValue }.joined(separator: ", "))\n\n"
        }
        
        if !modelPerformanceHistory.isEmpty {
            report += "## Performance History\n\n"
            let sortedHistory = modelPerformanceHistory.values.sorted { $0.successRate > $1.successRate }
            
            for performance in sortedHistory {
                report += "### \(performance.modelName)\n"
                report += "- Executions: \(performance.executionCount)\n"
                report += "- Success Rate: \(Int(performance.successRate * 100))%\n"
                report += "- Avg Accuracy: \(Int(performance.averageAccuracy * 100))%\n"
                report += "- Avg Inference: \(String(format: "%.3f", performance.averageInferenceTime))s\n"
                report += "- Resource Efficiency: \(Int(performance.resourceEfficiency * 100))%\n\n"
            }
        }
        
        return report
    }
}
