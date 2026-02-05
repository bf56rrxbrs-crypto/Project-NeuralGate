// ModelReportingSystem.swift
// NeuralGateLearning - Model Performance Reporting and Analysis
//
// Analyzes model outputs and adjusts weights for improved accuracy
// with comprehensive performance tracking and adaptive adjustments.

import Foundation

/// Performance metrics for a model
public struct ModelPerformanceMetrics: Codable {
    public let modelId: String
    public let accuracy: Double
    public let precision: Double
    public let recall: Double
    public let f1Score: Double
    public let latency: TimeInterval
    public let resourceUsage: ResourceUsage
    public let timestamp: Date
    public let sampleSize: Int
    
    public struct ResourceUsage: Codable {
        public let memoryMB: Double
        public let cpuPercent: Double
        public let batteryDrain: Double
        
        public init(memoryMB: Double, cpuPercent: Double, batteryDrain: Double) {
            self.memoryMB = memoryMB
            self.cpuPercent = cpuPercent
            self.batteryDrain = batteryDrain
        }
    }
    
    public init(
        modelId: String,
        accuracy: Double,
        precision: Double,
        recall: Double,
        f1Score: Double,
        latency: TimeInterval,
        resourceUsage: ResourceUsage,
        sampleSize: Int
    ) {
        self.modelId = modelId
        self.accuracy = accuracy
        self.precision = precision
        self.recall = recall
        self.f1Score = f1Score
        self.latency = latency
        self.resourceUsage = resourceUsage
        self.timestamp = Date()
        self.sampleSize = sampleSize
    }
    
    /// Calculate overall quality score (0-100)
    public var qualityScore: Double {
        let accuracyWeight = 0.30
        let precisionWeight = 0.20
        let recallWeight = 0.20
        let f1Weight = 0.20
        let performanceWeight = 0.10
        
        // Performance penalty for slow models
        let performancePenalty = min(latency / 5.0, 1.0)  // Penalize > 5s latency
        let performanceScore = max(0, 1.0 - performancePenalty)
        
        return (accuracy * accuracyWeight +
                precision * precisionWeight +
                recall * recallWeight +
                f1Score * f1Weight +
                performanceScore * performanceWeight) * 100
    }
}

/// Weight adjustment recommendation
public struct WeightAdjustment: Codable {
    public let parameterName: String
    public let currentValue: Double
    public let suggestedValue: Double
    public let rationale: String
    public let confidence: Double
    public let impact: ImpactLevel
    
    public enum ImpactLevel: String, Codable {
        case low, medium, high, critical
    }
    
    public init(
        parameterName: String,
        currentValue: Double,
        suggestedValue: Double,
        rationale: String,
        confidence: Double,
        impact: ImpactLevel
    ) {
        self.parameterName = parameterName
        self.currentValue = currentValue
        self.suggestedValue = suggestedValue
        self.rationale = rationale
        self.confidence = confidence
        self.impact = impact
    }
}

/// Model performance report
public struct ModelPerformanceReport {
    public let modelId: String
    public let metrics: ModelPerformanceMetrics
    public let trends: PerformanceTrends
    public let adjustments: [WeightAdjustment]
    public let alerts: [PerformanceAlert]
    public let recommendations: [String]
    public let generatedAt: Date
    
    public struct PerformanceTrends {
        public let accuracyTrend: TrendDirection
        public let latencyTrend: TrendDirection
        public let resourceTrend: TrendDirection
        
        public enum TrendDirection: String {
            case improving, stable, degrading, unknown
        }
        
        public init(
            accuracyTrend: TrendDirection,
            latencyTrend: TrendDirection,
            resourceTrend: TrendDirection
        ) {
            self.accuracyTrend = accuracyTrend
            self.latencyTrend = latencyTrend
            self.resourceTrend = resourceTrend
        }
    }
    
    public enum PerformanceAlert {
        case accuracyDrop(from: Double, to: Double)
        case highLatency(current: TimeInterval)
        case excessiveMemoryUsage(mb: Double)
        case poorPrecision(value: Double)
        case poorRecall(value: Double)
        case resourceExhaustion
        
        public var severity: AlertSeverity {
            switch self {
            case .accuracyDrop: return .high
            case .highLatency: return .medium
            case .excessiveMemoryUsage: return .medium
            case .poorPrecision, .poorRecall: return .medium
            case .resourceExhaustion: return .critical
            }
        }
        
        public enum AlertSeverity: String {
            case low, medium, high, critical
        }
    }
    
    public init(
        modelId: String,
        metrics: ModelPerformanceMetrics,
        trends: PerformanceTrends,
        adjustments: [WeightAdjustment],
        alerts: [PerformanceAlert],
        recommendations: [String]
    ) {
        self.modelId = modelId
        self.metrics = metrics
        self.trends = trends
        self.adjustments = adjustments
        self.alerts = alerts
        self.recommendations = recommendations
        self.generatedAt = Date()
    }
}

/// Model reporting and analysis system
public actor ModelReportingSystem {
    
    // Storage for metrics history
    private var metricsHistory: [String: [ModelPerformanceMetrics]] = [:]
    private let maxHistorySize = 100
    
    // Performance thresholds
    private let minAcceptableAccuracy: Double = 0.70
    private let maxAcceptableLatency: TimeInterval = 2.0
    private let maxAcceptableMemoryMB: Double = 200.0
    
    // Adaptive learning state
    private var baselineMetrics: [String: ModelPerformanceMetrics] = [:]
    private var adjustmentHistory: [String: [WeightAdjustment]] = [:]
    
    public init() {}
    
    // MARK: - Public API
    
    /// Record model performance metrics
    public func recordMetrics(_ metrics: ModelPerformanceMetrics) {
        // Initialize history if needed
        if metricsHistory[metrics.modelId] == nil {
            metricsHistory[metrics.modelId] = []
        }
        
        // Add metrics
        metricsHistory[metrics.modelId]?.append(metrics)
        
        // Maintain max history size
        if let count = metricsHistory[metrics.modelId]?.count, count > maxHistorySize {
            metricsHistory[metrics.modelId]?.removeFirst(count - maxHistorySize)
        }
        
        // Set baseline if not exists
        if baselineMetrics[metrics.modelId] == nil {
            baselineMetrics[metrics.modelId] = metrics
        }
    }
    
    /// Generate comprehensive performance report
    public func generateReport(for modelId: String) async -> ModelPerformanceReport? {
        guard let history = metricsHistory[modelId],
              let latestMetrics = history.last else {
            return nil
        }
        
        // Analyze trends
        let trends = analyzeTrends(for: modelId, history: history)
        
        // Generate weight adjustments
        let adjustments = await generateWeightAdjustments(for: modelId, metrics: latestMetrics, history: history)
        
        // Detect performance alerts
        let alerts = detectAlerts(for: latestMetrics, baseline: baselineMetrics[modelId])
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            metrics: latestMetrics,
            trends: trends,
            alerts: alerts
        )
        
        return ModelPerformanceReport(
            modelId: modelId,
            metrics: latestMetrics,
            trends: trends,
            adjustments: adjustments,
            alerts: alerts,
            recommendations: recommendations
        )
    }
    
    /// Get all models being tracked
    public func getTrackedModels() -> [String] {
        return Array(metricsHistory.keys)
    }
    
    /// Get latest metrics for a model
    public func getLatestMetrics(for modelId: String) -> ModelPerformanceMetrics? {
        return metricsHistory[modelId]?.last
    }
    
    /// Get metrics history for a model
    public func getMetricsHistory(for modelId: String, limit: Int = 50) -> [ModelPerformanceMetrics] {
        guard let history = metricsHistory[modelId] else { return [] }
        let count = min(limit, history.count)
        return Array(history.suffix(count))
    }
    
    /// Compare two models
    public func compareModels(_ model1: String, _ model2: String) -> ModelComparison? {
        guard let metrics1 = metricsHistory[model1]?.last,
              let metrics2 = metricsHistory[model2]?.last else {
            return nil
        }
        
        return ModelComparison(
            model1Id: model1,
            model2Id: model2,
            metrics1: metrics1,
            metrics2: metrics2,
            winner: determineWinner(metrics1, metrics2),
            comparisonDetails: generateComparisonDetails(metrics1, metrics2)
        )
    }
    
    // MARK: - Private Methods
    
    private func analyzeTrends(
        for modelId: String,
        history: [ModelPerformanceMetrics]
    ) -> ModelPerformanceReport.PerformanceTrends {
        
        guard history.count >= 3 else {
            return ModelPerformanceReport.PerformanceTrends(
                accuracyTrend: .unknown,
                latencyTrend: .unknown,
                resourceTrend: .unknown
            )
        }
        
        // Take last 10 samples for trend analysis
        let recentHistory = Array(history.suffix(10))
        let halfPoint = recentHistory.count / 2
        
        let firstHalf = Array(recentHistory.prefix(halfPoint))
        let secondHalf = Array(recentHistory.suffix(halfPoint))
        
        // Calculate averages
        let avgAccuracy1 = firstHalf.reduce(0.0) { $0 + $1.accuracy } / Double(firstHalf.count)
        let avgAccuracy2 = secondHalf.reduce(0.0) { $0 + $1.accuracy } / Double(secondHalf.count)
        
        let avgLatency1 = firstHalf.reduce(0.0) { $0 + $1.latency } / Double(firstHalf.count)
        let avgLatency2 = secondHalf.reduce(0.0) { $0 + $1.latency } / Double(secondHalf.count)
        
        let avgMemory1 = firstHalf.reduce(0.0) { $0 + $1.resourceUsage.memoryMB } / Double(firstHalf.count)
        let avgMemory2 = secondHalf.reduce(0.0) { $0 + $1.resourceUsage.memoryMB } / Double(secondHalf.count)
        
        // Determine trends (5% threshold for significant change)
        let accuracyTrend: ModelPerformanceReport.PerformanceTrends.TrendDirection
        if avgAccuracy2 > avgAccuracy1 * 1.05 {
            accuracyTrend = .improving
        } else if avgAccuracy2 < avgAccuracy1 * 0.95 {
            accuracyTrend = .degrading
        } else {
            accuracyTrend = .stable
        }
        
        let latencyTrend: ModelPerformanceReport.PerformanceTrends.TrendDirection
        if avgLatency2 < avgLatency1 * 0.95 {
            latencyTrend = .improving
        } else if avgLatency2 > avgLatency1 * 1.05 {
            latencyTrend = .degrading
        } else {
            latencyTrend = .stable
        }
        
        let resourceTrend: ModelPerformanceReport.PerformanceTrends.TrendDirection
        if avgMemory2 < avgMemory1 * 0.95 {
            resourceTrend = .improving
        } else if avgMemory2 > avgMemory1 * 1.05 {
            resourceTrend = .degrading
        } else {
            resourceTrend = .stable
        }
        
        return ModelPerformanceReport.PerformanceTrends(
            accuracyTrend: accuracyTrend,
            latencyTrend: latencyTrend,
            resourceTrend: resourceTrend
        )
    }
    
    private func generateWeightAdjustments(
        for modelId: String,
        metrics: ModelPerformanceMetrics,
        history: [ModelPerformanceMetrics]
    ) async -> [WeightAdjustment] {
        
        var adjustments: [WeightAdjustment] = []
        
        // Low accuracy - suggest increasing regularization
        if metrics.accuracy < minAcceptableAccuracy {
            adjustments.append(WeightAdjustment(
                parameterName: "regularization",
                currentValue: 0.1,
                suggestedValue: 0.15,
                rationale: "Accuracy below threshold (\(metrics.accuracy)). Increase regularization to prevent overfitting.",
                confidence: 0.8,
                impact: .high
            ))
        }
        
        // High latency - suggest model pruning
        if metrics.latency > maxAcceptableLatency {
            adjustments.append(WeightAdjustment(
                parameterName: "model_complexity",
                currentValue: 1.0,
                suggestedValue: 0.8,
                rationale: "Latency too high (\(metrics.latency)s). Consider model pruning or quantization.",
                confidence: 0.85,
                impact: .medium
            ))
        }
        
        // Poor precision/recall balance
        if abs(metrics.precision - metrics.recall) > 0.2 {
            let targetF1 = (metrics.precision + metrics.recall) / 2.0
            adjustments.append(WeightAdjustment(
                parameterName: "decision_threshold",
                currentValue: 0.5,
                suggestedValue: metrics.precision > metrics.recall ? 0.4 : 0.6,
                rationale: "Precision-recall imbalance detected. Adjust decision threshold to improve F1 score.",
                confidence: 0.75,
                impact: .medium
            ))
        }
        
        // Excessive memory usage
        if metrics.resourceUsage.memoryMB > maxAcceptableMemoryMB {
            adjustments.append(WeightAdjustment(
                parameterName: "batch_size",
                currentValue: 32,
                suggestedValue: 16,
                rationale: "Memory usage too high (\(metrics.resourceUsage.memoryMB)MB). Reduce batch size.",
                confidence: 0.9,
                impact: .medium
            ))
        }
        
        return adjustments
    }
    
    private func detectAlerts(
        for metrics: ModelPerformanceMetrics,
        baseline: ModelPerformanceMetrics?
    ) -> [ModelPerformanceReport.PerformanceAlert] {
        
        var alerts: [ModelPerformanceReport.PerformanceAlert] = []
        
        // Check accuracy drop
        if let baseline = baseline, metrics.accuracy < baseline.accuracy * 0.9 {
            alerts.append(.accuracyDrop(from: baseline.accuracy, to: metrics.accuracy))
        }
        
        // Check latency
        if metrics.latency > maxAcceptableLatency {
            alerts.append(.highLatency(current: metrics.latency))
        }
        
        // Check memory usage
        if metrics.resourceUsage.memoryMB > maxAcceptableMemoryMB {
            alerts.append(.excessiveMemoryUsage(mb: metrics.resourceUsage.memoryMB))
        }
        
        // Check precision
        if metrics.precision < 0.6 {
            alerts.append(.poorPrecision(value: metrics.precision))
        }
        
        // Check recall
        if metrics.recall < 0.6 {
            alerts.append(.poorRecall(value: metrics.recall))
        }
        
        // Check resource exhaustion
        if metrics.resourceUsage.memoryMB > maxAcceptableMemoryMB * 1.5 ||
           metrics.resourceUsage.cpuPercent > 90 {
            alerts.append(.resourceExhaustion)
        }
        
        return alerts
    }
    
    private func generateRecommendations(
        metrics: ModelPerformanceMetrics,
        trends: ModelPerformanceReport.PerformanceTrends,
        alerts: [ModelPerformanceReport.PerformanceAlert]
    ) -> [String] {
        
        var recommendations: [String] = []
        
        // Accuracy recommendations
        if metrics.accuracy < 0.8 {
            recommendations.append("Consider collecting more training data or feature engineering")
        }
        
        // Trend-based recommendations
        if trends.accuracyTrend == .degrading {
            recommendations.append("Model performance is degrading. Consider retraining with recent data")
        }
        
        if trends.latencyTrend == .degrading {
            recommendations.append("Response time is increasing. Consider model optimization or caching")
        }
        
        // Alert-based recommendations
        if !alerts.isEmpty {
            recommendations.append("Address \(alerts.count) performance alert(s) to maintain quality")
        }
        
        // Quality score recommendations
        if metrics.qualityScore < 70 {
            recommendations.append("Overall quality score is low. Review model architecture and hyperparameters")
        }
        
        // Mobile optimization
        if metrics.resourceUsage.batteryDrain > 0.5 {
            recommendations.append("High battery impact detected. Optimize for mobile device efficiency")
        }
        
        return recommendations
    }
    
    private func determineWinner(
        _ metrics1: ModelPerformanceMetrics,
        _ metrics2: ModelPerformanceMetrics
    ) -> String {
        let score1 = metrics1.qualityScore
        let score2 = metrics2.qualityScore
        return score1 > score2 ? metrics1.modelId : metrics2.modelId
    }
    
    private func generateComparisonDetails(
        _ metrics1: ModelPerformanceMetrics,
        _ metrics2: ModelPerformanceMetrics
    ) -> [String: String] {
        return [
            "accuracy": "\(metrics1.accuracy) vs \(metrics2.accuracy)",
            "latency": "\(metrics1.latency)s vs \(metrics2.latency)s",
            "f1Score": "\(metrics1.f1Score) vs \(metrics2.f1Score)",
            "qualityScore": "\(metrics1.qualityScore) vs \(metrics2.qualityScore)"
        ]
    }
}

/// Model comparison result
public struct ModelComparison {
    public let model1Id: String
    public let model2Id: String
    public let metrics1: ModelPerformanceMetrics
    public let metrics2: ModelPerformanceMetrics
    public let winner: String
    public let comparisonDetails: [String: String]
    
    public init(
        model1Id: String,
        model2Id: String,
        metrics1: ModelPerformanceMetrics,
        metrics2: ModelPerformanceMetrics,
        winner: String,
        comparisonDetails: [String: String]
    ) {
        self.model1Id = model1Id
        self.model2Id = model2Id
        self.metrics1 = metrics1
        self.metrics2 = metrics2
        self.winner = winner
        self.comparisonDetails = comparisonDetails
    }
}
