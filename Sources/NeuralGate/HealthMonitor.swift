import Foundation

/// Health monitoring and metrics collection system
public actor HealthMonitor {
    public static let shared = HealthMonitor()
    
    private var metrics: HealthMetrics
    private var lastHealthCheck: Date?
    private let logger = NeuralGateLogger.shared
    
    private init() {
        self.metrics = HealthMetrics()
    }
    
    /// Perform comprehensive health check
    public func performHealthCheck() async -> HealthStatus {
        let startTime = Date()
        lastHealthCheck = startTime
        
        var status = HealthStatus(
            isHealthy: true,
            timestamp: startTime,
            components: [:]
        )
        
        // Check cache health
        let cacheStats = await CacheManager.shared.getStats()
        status.components["cache"] = ComponentHealth(
            status: cacheStats.validEntries > 0 ? .healthy : .degraded,
            message: "Cache utilization: \(String(format: "%.1f", cacheStats.utilizationPercentage))%"
        )
        
        // Check persistence health
        do {
            let storageSize = try await PersistenceManager.shared.getStorageSize()
            let storageMB = Double(storageSize) / 1_048_576
            status.components["persistence"] = ComponentHealth(
                status: storageMB < 100 ? .healthy : .warning,
                message: "Storage: \(String(format: "%.2f", storageMB)) MB"
            )
        } catch {
            status.components["persistence"] = ComponentHealth(
                status: .unhealthy,
                message: "Storage check failed: \(error.localizedDescription)"
            )
            status.isHealthy = false
        }
        
        // Check API client health
        let circuitBreakerState = await APIClient.shared.getCircuitBreakerState()
        status.components["api"] = ComponentHealth(
            status: circuitBreakerState == .closed ? .healthy : .degraded,
            message: "Circuit breaker: \(circuitBreakerState)"
        )
        
        // Check memory usage
        let memoryUsage = getMemoryUsage()
        status.components["memory"] = ComponentHealth(
            status: memoryUsage < 200 ? .healthy : .warning,
            message: "Memory: \(memoryUsage) MB"
        )
        
        // Update metrics
        metrics.totalHealthChecks += 1
        if !status.isHealthy {
            metrics.failedHealthChecks += 1
        }
        
        logger.log("Health check completed: \(status.isHealthy ? "HEALTHY" : "UNHEALTHY")", level: .info)
        
        return status
    }
    
    /// Record task execution metrics
    public func recordTaskExecution(duration: TimeInterval, success: Bool) {
        metrics.totalTasks += 1
        metrics.totalExecutionTime += duration
        
        if success {
            metrics.successfulTasks += 1
        } else {
            metrics.failedTasks += 1
        }
        
        // Update average
        metrics.averageTaskDuration = metrics.totalExecutionTime / Double(metrics.totalTasks)
    }
    
    /// Record API call metrics
    public func recordAPICall(duration: TimeInterval, success: Bool) {
        metrics.totalAPICalls += 1
        
        if success {
            metrics.successfulAPICalls += 1
        } else {
            metrics.failedAPICalls += 1
        }
    }
    
    /// Get current metrics
    public func getMetrics() -> HealthMetrics {
        metrics
    }
    
    /// Reset metrics
    public func resetMetrics() {
        metrics = HealthMetrics()
    }
    
    /// Get memory usage in MB
    private func getMemoryUsage() -> Int {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        // Darwin platforms
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size) / 1_048_576
        }
        #endif
        
        // For Linux or if measurement fails, return 0
        return 0
    }
}

/// Health status information
public struct HealthStatus {
    public var isHealthy: Bool
    public let timestamp: Date
    public var components: [String: ComponentHealth]
    
    public var overallStatus: ComponentStatus {
        if !isHealthy {
            return .unhealthy
        }
        
        let statuses = components.values.map { $0.status }
        if statuses.contains(.unhealthy) {
            return .unhealthy
        } else if statuses.contains(.degraded) {
            return .degraded
        } else if statuses.contains(.warning) {
            return .warning
        }
        
        return .healthy
    }
}

/// Component health information
public struct ComponentHealth {
    public let status: ComponentStatus
    public let message: String
}

/// Component status levels
public enum ComponentStatus: String, Codable {
    case healthy
    case warning
    case degraded
    case unhealthy
}

/// Health metrics
public struct HealthMetrics {
    public var totalHealthChecks: Int = 0
    public var failedHealthChecks: Int = 0
    public var totalTasks: Int = 0
    public var successfulTasks: Int = 0
    public var failedTasks: Int = 0
    public var totalExecutionTime: TimeInterval = 0
    public var averageTaskDuration: TimeInterval = 0
    public var totalAPICalls: Int = 0
    public var successfulAPICalls: Int = 0
    public var failedAPICalls: Int = 0
    
    public var taskSuccessRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(successfulTasks) / Double(totalTasks)
    }
    
    public var apiSuccessRate: Double {
        guard totalAPICalls > 0 else { return 0 }
        return Double(successfulAPICalls) / Double(totalAPICalls)
    }
}
