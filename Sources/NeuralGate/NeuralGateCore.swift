import Foundation

/// Core configuration for NeuralGate AI agent
public struct NeuralGateConfiguration {
    /// Enable debug logging
    public var debugMode: Bool
    
    /// Maximum memory usage in MB
    public var maxMemoryUsage: Int
    
    /// Battery optimization level (0-3, higher = more aggressive)
    public var batteryOptimizationLevel: Int
    
    /// Enable predictive analytics
    public var enablePredictiveAnalytics: Bool
    
    /// Enable explainable AI
    public var enableExplainability: Bool
    
    public init(
        debugMode: Bool = false,
        maxMemoryUsage: Int = 100,
        batteryOptimizationLevel: Int = 2,
        enablePredictiveAnalytics: Bool = true,
        enableExplainability: Bool = true
    ) {
        self.debugMode = debugMode
        self.maxMemoryUsage = maxMemoryUsage
        self.batteryOptimizationLevel = batteryOptimizationLevel
        self.enablePredictiveAnalytics = enablePredictiveAnalytics
        self.enableExplainability = enableExplainability
    }
}

/// Core error types for NeuralGate
public enum NeuralGateError: Error {
    case invalidConfiguration
    case resourceLimitExceeded
    case taskExecutionFailed(String)
    case modelLoadingFailed(String)
    case dataPipelineError(String)
    case failoverRequired
    case invalidInput(String)
    case timeout(String)
    case networkError(String)
    case unauthorized(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidConfiguration:
            return "Invalid configuration provided"
        case .resourceLimitExceeded:
            return "Resource limit exceeded"
        case .taskExecutionFailed(let message):
            return "Task execution failed: \(message)"
        case .modelLoadingFailed(let message):
            return "Model loading failed: \(message)"
        case .dataPipelineError(let message):
            return "Data pipeline error: \(message)"
        case .failoverRequired:
            return "Failover to backup system required"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .timeout(let message):
            return "Operation timed out: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        }
    }
}

/// Result type with explanation for AI decisions
public struct ExplainableResult<T> {
    /// The actual result
    public let value: T
    
    /// Explanation of how this result was determined
    public let explanation: String
    
    /// Confidence score (0.0-1.0)
    public let confidence: Double
    
    /// Contributing factors
    public let factors: [String: Double]
    
    public init(value: T, explanation: String, confidence: Double, factors: [String: Double] = [:]) {
        self.value = value
        self.explanation = explanation
        self.confidence = confidence
        self.factors = factors
    }
}

/// Protocol for resource-aware operations
public protocol ResourceAware {
    /// Estimated memory usage in MB
    var estimatedMemoryUsage: Int { get }
    
    /// Estimated CPU usage (0.0-1.0)
    var estimatedCPUUsage: Double { get }
    
    /// Estimated battery impact (0.0-1.0)
    var estimatedBatteryImpact: Double { get }
    
    /// Check if operation can be performed within resource constraints
    func canExecute(configuration: NeuralGateConfiguration) -> Bool
}

/// Logging utility
public class NeuralGateLogger {
    public static var shared = NeuralGateLogger()
    public var debugMode: Bool = false
    
    private init() {}
    
    public func log(_ message: String, level: LogLevel = .info) {
        guard debugMode || level == .error else { return }
        print("[\(level.rawValue)] \(Date()): \(message)")
    }
    
    public enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
}
