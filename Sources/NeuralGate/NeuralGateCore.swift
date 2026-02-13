import Foundation

/// Core configuration for NeuralGate AI agent
public struct NeuralGateConfiguration {
    /// Maximum allowed memory usage in megabytes
    /// Valid range: 1-1000 MB. This limit ensures the agent operates within
    /// reasonable resource constraints on iPhone devices.
    public static let maxMemoryLimit: Int = 1000
    
    /// Minimum allowed memory usage in megabytes
    public static let minMemoryLimit: Int = 1
    
    /// Enable debug logging
    public var debugMode: Bool
    
    /// Maximum memory usage in MB (valid range: 1-1000)
    public var maxMemoryUsage: Int
    
    /// Battery optimization level (0-3, higher = more aggressive)
    /// - 0: No optimization
    /// - 1: Light optimization
    /// - 2: Balanced (default)
    /// - 3: Aggressive optimization
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
    
    /// Validate configuration parameters
    /// - Throws: NeuralGateError.invalidConfiguration if parameters are invalid
    public func validate() throws {
        guard maxMemoryUsage >= Self.minMemoryLimit && maxMemoryUsage <= Self.maxMemoryLimit else {
            throw NeuralGateError.invalidConfiguration("maxMemoryUsage must be between \(Self.minMemoryLimit) and \(Self.maxMemoryLimit) MB, got \(maxMemoryUsage)")
        }
        
        guard batteryOptimizationLevel >= 0 && batteryOptimizationLevel <= 3 else {
            throw NeuralGateError.invalidConfiguration("batteryOptimizationLevel must be between 0 and 3, got \(batteryOptimizationLevel)")
        }
    }
}

/// Core error types for NeuralGate
public enum NeuralGateError: Error {
    case invalidConfiguration(String)
    case resourceLimitExceeded(String)
    case taskExecutionFailed(String)
    case modelLoadingFailed(String)
    case dataPipelineError(String)
    case failoverRequired
    case invalidInput(String)
    case networkError(String)
    case permissionDenied(String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidConfiguration(let details):
            return "Invalid configuration: \(details)"
        case .resourceLimitExceeded(let resource):
            return "Resource limit exceeded: \(resource)"
        case .taskExecutionFailed(let message):
            return "Task execution failed: \(message)"
        case .modelLoadingFailed(let message):
            return "Model loading failed: \(message)"
        case .dataPipelineError(let message):
            return "Data pipeline error: \(message)"
        case .failoverRequired:
            return "Failover to backup system required"
        case .invalidInput(let details):
            return "Invalid input: \(details)"
        case .networkError(let details):
            return "Network error: \(details)"
        case .permissionDenied(let permission):
            return "Permission denied: \(permission)"
        }
    }
    
    /// Provides recovery suggestions for errors
    public var recoverySuggestion: String? {
        switch self {
        case .invalidConfiguration:
            return "Check configuration parameters and ensure all required values are valid."
        case .resourceLimitExceeded:
            return "Close other applications or increase resource limits in configuration."
        case .taskExecutionFailed:
            return "Check task parameters and try again. Contact support if issue persists."
        case .invalidInput:
            return "Ensure input is not empty and contains valid characters."
        case .networkError:
            return "Check internet connection and try again."
        case .permissionDenied:
            return "Grant required permissions in Settings app."
        default:
            return nil
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
