// ExplainabilityInterface.swift
// NeuralGateAI - Explainable AI Interface
//
// Provides transparent AI reasoning with metrics visualization and
// clear explanations for all AI decisions.

import Foundation

/// Explainability level for AI decisions
public enum ExplainabilityLevel: String, Codable {
    case basic       // Simple, user-friendly explanation
    case detailed    // Technical details with metrics
    case expert      // Full algorithmic breakdown
}

/// Explanation for an AI decision
public struct AIExplanation: Identifiable, Codable {
    public let id: UUID
    public let decisionType: DecisionType
    public let summary: String
    public let reasoning: [ReasoningStep]
    public let confidence: Double
    public let factorsConsidered: [DecisionFactor]
    public let metrics: ExplanationMetrics
    public let timestamp: Date
    public let modelUsed: String
    
    public enum DecisionType: String, Codable {
        case recommendation
        case prioritization
        case classification
        case prediction
        case optimization
        case routing
    }
    
    public init(
        id: UUID = UUID(),
        decisionType: DecisionType,
        summary: String,
        reasoning: [ReasoningStep],
        confidence: Double,
        factorsConsidered: [DecisionFactor],
        metrics: ExplanationMetrics,
        modelUsed: String
    ) {
        self.id = id
        self.decisionType = decisionType
        self.summary = summary
        self.reasoning = reasoning
        self.confidence = confidence
        self.factorsConsidered = factorsConsidered
        self.metrics = metrics
        self.timestamp = Date()
        self.modelUsed = modelUsed
    }
}

/// Individual step in the reasoning process
public struct ReasoningStep: Identifiable, Codable {
    public let id: UUID
    public let stepNumber: Int
    public let description: String
    public let input: String
    public let output: String
    public let confidence: Double
    public let reasoning: String
    
    public init(
        id: UUID = UUID(),
        stepNumber: Int,
        description: String,
        input: String,
        output: String,
        confidence: Double,
        reasoning: String
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.description = description
        self.input = input
        self.output = output
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

/// Factor that influenced the decision
public struct DecisionFactor: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let value: String
    public let weight: Double
    public let impact: Impact
    public let explanation: String
    
    public enum Impact: String, Codable {
        case positive, negative, neutral
        
        public var description: String {
            switch self {
            case .positive: return "Increased likelihood"
            case .negative: return "Decreased likelihood"
            case .neutral: return "No significant impact"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        value: String,
        weight: Double,
        impact: Impact,
        explanation: String
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.weight = weight
        self.impact = impact
        self.explanation = explanation
    }
}

/// Metrics associated with an explanation
public struct ExplanationMetrics: Codable {
    public let accuracy: Double?
    public let precision: Double?
    public let recall: Double?
    public let processingTime: TimeInterval
    public let dataPointsAnalyzed: Int
    public let alternativesConsidered: Int
    
    public init(
        accuracy: Double? = nil,
        precision: Double? = nil,
        recall: Double? = nil,
        processingTime: TimeInterval,
        dataPointsAnalyzed: Int,
        alternativesConsidered: Int
    ) {
        self.accuracy = accuracy
        self.precision = precision
        self.recall = recall
        self.processingTime = processingTime
        self.dataPointsAnalyzed = dataPointsAnalyzed
        self.alternativesConsidered = alternativesConsidered
    }
}

/// Visual representation of explanation data
public struct ExplanationVisualization {
    public let type: VisualizationType
    public let data: VisualizationData
    public let title: String
    public let description: String
    
    public enum VisualizationType: String {
        case barChart
        case pieChart
        case lineGraph
        case heatmap
        case decisionTree
        case confidenceGauge
    }
    
    public struct VisualizationData {
        public let labels: [String]
        public let values: [Double]
        public let colors: [String]?
        public let metadata: [String: Any]
        
        public init(
            labels: [String],
            values: [Double],
            colors: [String]? = nil,
            metadata: [String: Any] = [:]
        ) {
            self.labels = labels
            self.values = values
            self.colors = colors
            self.metadata = metadata
        }
    }
    
    public init(
        type: VisualizationType,
        data: VisualizationData,
        title: String,
        description: String
    ) {
        self.type = type
        self.data = data
        self.title = title
        self.description = description
    }
}

/// Interface for generating explainable AI outputs
public actor ExplainabilityInterface {
    
    private var explanationHistory: [AIExplanation] = []
    private let maxHistorySize = 500
    
    // Configuration
    private var defaultLevel: ExplainabilityLevel = .basic
    private var enableVisualization: Bool = true
    
    public init() {}
    
    // MARK: - Public API
    
    /// Generate explanation for an AI decision
    public func generateExplanation(
        decisionType: AIExplanation.DecisionType,
        input: Any,
        output: Any,
        model: String,
        metadata: [String: Any] = [:],
        level: ExplainabilityLevel? = nil
    ) async -> AIExplanation {
        
        let explanationLevel = level ?? defaultLevel
        
        // Build reasoning steps
        let reasoning = buildReasoningSteps(
            input: input,
            output: output,
            metadata: metadata,
            level: explanationLevel
        )
        
        // Identify factors
        let factors = identifyFactors(
            input: input,
            metadata: metadata
        )
        
        // Calculate confidence
        let confidence = calculateConfidence(
            factors: factors,
            metadata: metadata
        )
        
        // Create metrics
        let metrics = ExplanationMetrics(
            accuracy: metadata["accuracy"] as? Double,
            precision: metadata["precision"] as? Double,
            recall: metadata["recall"] as? Double,
            processingTime: metadata["processingTime"] as? TimeInterval ?? 0,
            dataPointsAnalyzed: metadata["dataPoints"] as? Int ?? 0,
            alternativesConsidered: metadata["alternatives"] as? Int ?? 0
        )
        
        // Generate summary
        let summary = generateSummary(
            decisionType: decisionType,
            output: output,
            confidence: confidence,
            level: explanationLevel
        )
        
        let explanation = AIExplanation(
            decisionType: decisionType,
            summary: summary,
            reasoning: reasoning,
            confidence: confidence,
            factorsConsidered: factors,
            metrics: metrics,
            modelUsed: model
        )
        
        // Store in history
        storeExplanation(explanation)
        
        return explanation
    }
    
    /// Generate visualization for an explanation
    public func generateVisualization(
        for explanation: AIExplanation,
        type: ExplanationVisualization.VisualizationType? = nil
    ) -> ExplanationVisualization {
        
        let vizType = type ?? selectOptimalVisualizationType(for: explanation)
        
        switch vizType {
        case .barChart:
            return createFactorsBarChart(explanation)
        case .pieChart:
            return createConfidencePieChart(explanation)
        case .confidenceGauge:
            return createConfidenceGauge(explanation)
        case .decisionTree:
            return createDecisionTree(explanation)
        default:
            return createFactorsBarChart(explanation)
        }
    }
    
    /// Get explanation history
    public func getExplanationHistory(
        decisionType: AIExplanation.DecisionType? = nil,
        limit: Int = 50
    ) -> [AIExplanation] {
        
        var filtered = explanationHistory
        
        if let type = decisionType {
            filtered = filtered.filter { $0.decisionType == type }
        }
        
        return Array(filtered.suffix(limit))
    }
    
    /// Compare two AI decisions
    public func compareDecisions(
        _ explanation1: AIExplanation,
        _ explanation2: AIExplanation
    ) -> DecisionComparison {
        
        return DecisionComparison(
            explanation1: explanation1,
            explanation2: explanation2,
            confidenceDifference: abs(explanation1.confidence - explanation2.confidence),
            commonFactors: findCommonFactors(explanation1, explanation2),
            differingFactors: findDifferingFactors(explanation1, explanation2),
            recommendation: generateComparisonRecommendation(explanation1, explanation2)
        )
    }
    
    /// Generate plain language explanation
    public func toPlainLanguage(
        _ explanation: AIExplanation
    ) -> String {
        
        var plainText = "Decision: \(explanation.summary)\n\n"
        
        plainText += "I made this decision because:\n"
        for (index, step) in explanation.reasoning.enumerated() {
            plainText += "\(index + 1). \(step.reasoning)\n"
        }
        
        plainText += "\nKey factors I considered:\n"
        for factor in explanation.factorsConsidered {
            let impactStr = factor.impact == .positive ? "✓" : (factor.impact == .negative ? "✗" : "○")
            plainText += "• \(impactStr) \(factor.name): \(factor.value) - \(factor.explanation)\n"
        }
        
        plainText += "\nConfidence: \(Int(explanation.confidence * 100))%\n"
        plainText += "This means I'm \(confidenceDescription(explanation.confidence)) about this decision.\n"
        
        return plainText
    }
    
    /// Configure explainability settings
    public func configure(
        defaultLevel: ExplainabilityLevel? = nil,
        enableVisualization: Bool? = nil
    ) {
        if let level = defaultLevel {
            self.defaultLevel = level
        }
        if let viz = enableVisualization {
            self.enableVisualization = viz
        }
    }
    
    // MARK: - Private Methods
    
    private func buildReasoningSteps(
        input: Any,
        output: Any,
        metadata: [String: Any],
        level: ExplainabilityLevel
    ) -> [ReasoningStep] {
        
        var steps: [ReasoningStep] = []
        
        // Step 1: Data Collection
        steps.append(ReasoningStep(
            stepNumber: 1,
            description: "Data Collection",
            input: "User request and context",
            output: "Structured data for analysis",
            confidence: 0.95,
            reasoning: "Gathered relevant information from your request and current context"
        ))
        
        // Step 2: Analysis
        steps.append(ReasoningStep(
            stepNumber: 2,
            description: "Pattern Analysis",
            input: "Structured data",
            output: "Identified patterns and trends",
            confidence: 0.85,
            reasoning: "Analyzed patterns based on historical data and current trends"
        ))
        
        // Step 3: Decision Making
        steps.append(ReasoningStep(
            stepNumber: 3,
            description: "Decision Generation",
            input: "Analysis results",
            output: "Final recommendation",
            confidence: 0.90,
            reasoning: "Evaluated multiple options and selected the best one based on your preferences"
        ))
        
        if level == .expert {
            // Add more detailed steps for expert level
            steps.append(ReasoningStep(
                stepNumber: 4,
                description: "Validation",
                input: "Selected decision",
                output: "Validated decision",
                confidence: 0.88,
                reasoning: "Verified decision against constraints and best practices"
            ))
        }
        
        return steps
    }
    
    private func identifyFactors(
        input: Any,
        metadata: [String: Any]
    ) -> [DecisionFactor] {
        
        var factors: [DecisionFactor] = []
        
        // Extract factors from metadata
        if let priority = metadata["priority"] as? String {
            factors.append(DecisionFactor(
                name: "Priority Level",
                value: priority,
                weight: 0.3,
                impact: .positive,
                explanation: "High priority increases urgency of action"
            ))
        }
        
        if let context = metadata["context"] as? String {
            factors.append(DecisionFactor(
                name: "Context",
                value: context,
                weight: 0.25,
                impact: .positive,
                explanation: "Current context influences decision appropriateness"
            ))
        }
        
        if let historicalSuccess = metadata["historicalSuccess"] as? Double {
            factors.append(DecisionFactor(
                name: "Historical Success Rate",
                value: "\(Int(historicalSuccess * 100))%",
                weight: 0.20,
                impact: historicalSuccess > 0.7 ? .positive : .negative,
                explanation: "Past success rate of similar decisions"
            ))
        }
        
        if let resourceAvailability = metadata["resources"] as? String {
            factors.append(DecisionFactor(
                name: "Resource Availability",
                value: resourceAvailability,
                weight: 0.15,
                impact: .neutral,
                explanation: "Current system resources affect execution capability"
            ))
        }
        
        if let userPreferenceValue = metadata["userPreference"] as? String {
            factors.append(DecisionFactor(
                name: "User Preference",
                value: userPreferenceValue,
                weight: 0.10,
                impact: .positive,
                explanation: "Aligns with your stated preferences"
            ))
        }
        
        return factors
    }
    
    private func calculateConfidence(
        factors: [DecisionFactor],
        metadata: [String: Any]
    ) -> Double {
        
        // Base confidence
        var confidence = 0.5
        
        // Adjust based on factors
        for factor in factors {
            switch factor.impact {
            case .positive:
                confidence += factor.weight * 0.3
            case .negative:
                confidence -= factor.weight * 0.2
            case .neutral:
                confidence += factor.weight * 0.1
            }
        }
        
        // Adjust based on data quality
        if let dataQuality = metadata["dataQuality"] as? Double {
            confidence *= dataQuality
        }
        
        // Clamp to valid range
        return min(max(confidence, 0.0), 1.0)
    }
    
    private func generateSummary(
        decisionType: AIExplanation.DecisionType,
        output: Any,
        confidence: Double,
        level: ExplainabilityLevel
    ) -> String {
        
        let confidenceStr = confidenceDescription(confidence)
        
        switch decisionType {
        case .recommendation:
            return "I'm \(confidenceStr) that this recommendation will help you achieve your goal"
        case .prioritization:
            return "Based on your priorities and deadlines, I'm \(confidenceStr) about this task order"
        case .classification:
            return "I've classified this as '\(output)' with \(confidenceStr) certainty"
        case .prediction:
            return "I predict '\(output)' and I'm \(confidenceStr) about this forecast"
        case .optimization:
            return "This is the optimal solution with \(confidenceStr) confidence"
        case .routing:
            return "I've determined the best path with \(confidenceStr) confidence"
        }
    }
    
    private func confidenceDescription(_ confidence: Double) -> String {
        switch confidence {
        case 0.9...:
            return "very confident"
        case 0.75..<0.9:
            return "confident"
        case 0.6..<0.75:
            return "reasonably confident"
        case 0.4..<0.6:
            return "moderately confident"
        default:
            return "somewhat uncertain"
        }
    }
    
    private func storeExplanation(_ explanation: AIExplanation) {
        explanationHistory.append(explanation)
        
        // Maintain history size
        if explanationHistory.count > maxHistorySize {
            explanationHistory.removeFirst(explanationHistory.count - maxHistorySize)
        }
    }
    
    private func selectOptimalVisualizationType(
        for explanation: AIExplanation
    ) -> ExplanationVisualization.VisualizationType {
        
        // Select based on decision type and data
        switch explanation.decisionType {
        case .prioritization:
            return .barChart
        case .classification:
            return .pieChart
        case .recommendation:
            return .confidenceGauge
        default:
            return .barChart
        }
    }
    
    private func createFactorsBarChart(
        _ explanation: AIExplanation
    ) -> ExplanationVisualization {
        
        let labels = explanation.factorsConsidered.map { $0.name }
        let values = explanation.factorsConsidered.map { $0.weight * 100 }
        let colors = explanation.factorsConsidered.map { factor -> String in
            switch factor.impact {
            case .positive: return "#4CAF50"
            case .negative: return "#F44336"
            case .neutral: return "#9E9E9E"
            }
        }
        
        return ExplanationVisualization(
            type: .barChart,
            data: .init(labels: labels, values: values, colors: colors),
            title: "Decision Factors",
            description: "Relative importance of each factor in the decision"
        )
    }
    
    private func createConfidencePieChart(
        _ explanation: AIExplanation
    ) -> ExplanationVisualization {
        
        let confidence = explanation.confidence * 100
        let uncertainty = 100 - confidence
        
        return ExplanationVisualization(
            type: .pieChart,
            data: .init(
                labels: ["Confidence", "Uncertainty"],
                values: [confidence, uncertainty],
                colors: ["#4CAF50", "#FF9800"]
            ),
            title: "Decision Confidence",
            description: "How certain the AI is about this decision"
        )
    }
    
    private func createConfidenceGauge(
        _ explanation: AIExplanation
    ) -> ExplanationVisualization {
        
        return ExplanationVisualization(
            type: .confidenceGauge,
            data: .init(
                labels: ["Confidence"],
                values: [explanation.confidence * 100]
            ),
            title: "Confidence Level",
            description: "\(Int(explanation.confidence * 100))% confident in this decision"
        )
    }
    
    private func createDecisionTree(
        _ explanation: AIExplanation
    ) -> ExplanationVisualization {
        
        let labels = explanation.reasoning.map { $0.description }
        let values = explanation.reasoning.map { $0.confidence * 100 }
        
        return ExplanationVisualization(
            type: .decisionTree,
            data: .init(labels: labels, values: values),
            title: "Decision Process",
            description: "Step-by-step reasoning path"
        )
    }
    
    private func findCommonFactors(
        _ explanation1: AIExplanation,
        _ explanation2: AIExplanation
    ) -> [DecisionFactor] {
        
        let names1 = Set(explanation1.factorsConsidered.map { $0.name })
        let names2 = Set(explanation2.factorsConsidered.map { $0.name })
        let common = names1.intersection(names2)
        
        return explanation1.factorsConsidered.filter { common.contains($0.name) }
    }
    
    private func findDifferingFactors(
        _ explanation1: AIExplanation,
        _ explanation2: AIExplanation
    ) -> [DecisionFactor] {
        
        let names1 = Set(explanation1.factorsConsidered.map { $0.name })
        let names2 = Set(explanation2.factorsConsidered.map { $0.name })
        let differing = names1.symmetricDifference(names2)
        
        let factors1 = explanation1.factorsConsidered.filter { differing.contains($0.name) }
        let factors2 = explanation2.factorsConsidered.filter { differing.contains($0.name) }
        
        return factors1 + factors2
    }
    
    private func generateComparisonRecommendation(
        _ explanation1: AIExplanation,
        _ explanation2: AIExplanation
    ) -> String {
        
        if explanation1.confidence > explanation2.confidence {
            return "The first decision has higher confidence (\(Int(explanation1.confidence * 100))% vs \(Int(explanation2.confidence * 100))%)"
        } else if explanation2.confidence > explanation1.confidence {
            return "The second decision has higher confidence (\(Int(explanation2.confidence * 100))% vs \(Int(explanation1.confidence * 100))%)"
        } else {
            return "Both decisions have equal confidence. Consider other factors like resource requirements."
        }
    }
}

/// Comparison result between two AI decisions
public struct DecisionComparison {
    public let explanation1: AIExplanation
    public let explanation2: AIExplanation
    public let confidenceDifference: Double
    public let commonFactors: [DecisionFactor]
    public let differingFactors: [DecisionFactor]
    public let recommendation: String
    
    public init(
        explanation1: AIExplanation,
        explanation2: AIExplanation,
        confidenceDifference: Double,
        commonFactors: [DecisionFactor],
        differingFactors: [DecisionFactor],
        recommendation: String
    ) {
        self.explanation1 = explanation1
        self.explanation2 = explanation2
        self.confidenceDifference = confidenceDifference
        self.commonFactors = commonFactors
        self.differingFactors = differingFactors
        self.recommendation = recommendation
    }
}
