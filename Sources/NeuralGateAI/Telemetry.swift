import Foundation
import NeuralGate

// Import thermal state type from PowerMonitor
#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
public typealias TelemetryThermalState = ProcessInfo.ThermalState
#else
public enum TelemetryThermalState: Int {
    case nominal = 0
    case fair = 1
    case serious = 2
    case critical = 3
}
#endif

/// Telemetry event types
public enum TelemetryEvent {
    case routingDecision(mode: String, score: Double, thermalState: String, timestamp: Date)
    case remoteCallResult(success: Bool, latency: TimeInterval, failureReason: String?)
    case powerStateChange(thermalState: String, isLowPowerMode: Bool)
}

/// Lightweight telemetry system for tracking key operations
public class Telemetry {
    
    /// Shared instance
    public static let shared = Telemetry()
    
    /// Whether telemetry is enabled (can be disabled at compile time)
    #if DISABLE_TELEMETRY
    public private(set) var isEnabled = false
    #else
    public private(set) var isEnabled = true
    #endif
    
    private let logger = NeuralGateLogger.shared
    private var events: [TelemetryEvent] = []
    private let maxStoredEvents = 1000
    private let queue = DispatchQueue(label: "com.neuralgate.telemetry", attributes: .concurrent)
    
    private init() {}
    
    /// Record a routing decision event
    public func recordRoutingDecision(
        mode: ExecutionMode,
        score: Double,
        thermalState: TelemetryThermalState,
        timestamp: Date = Date()
    ) {
        guard isEnabled else { return }
        
        let event = TelemetryEvent.routingDecision(
            mode: mode.rawValue,
            score: score,
            thermalState: thermalStateString(thermalState),
            timestamp: timestamp
        )
        
        recordEvent(event)
        
        logger.log(
            "Telemetry: Routing decision - mode: \(mode.rawValue), score: \(String(format: "%.3f", score)), thermal: \(thermalStateString(thermalState))",
            level: .debug
        )
    }
    
    /// Record a remote call result event
    public func recordRemoteCallResult(
        success: Bool,
        latency: TimeInterval,
        failureReason: String? = nil
    ) {
        guard isEnabled else { return }
        
        let event = TelemetryEvent.remoteCallResult(
            success: success,
            latency: latency,
            failureReason: failureReason
        )
        
        recordEvent(event)
        
        let statusStr = success ? "success" : "failure"
        let reasonStr = failureReason.map { " - reason: \($0)" } ?? ""
        logger.log(
            "Telemetry: Remote call \(statusStr) - latency: \(String(format: "%.3f", latency))s\(reasonStr)",
            level: .debug
        )
    }
    
    /// Record a power state change event
    public func recordPowerStateChange(
        thermalState: TelemetryThermalState,
        isLowPowerMode: Bool
    ) {
        guard isEnabled else { return }
        
        let event = TelemetryEvent.powerStateChange(
            thermalState: thermalStateString(thermalState),
            isLowPowerMode: isLowPowerMode
        )
        
        recordEvent(event)
        
        logger.log(
            "Telemetry: Power state change - thermal: \(thermalStateString(thermalState)), lowPower: \(isLowPowerMode)",
            level: .debug
        )
    }
    
    /// Record an event to storage
    private func recordEvent(_ event: TelemetryEvent) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.events.append(event)
            
            // Trim events if exceeding max storage
            if self.events.count > self.maxStoredEvents {
                self.events.removeFirst(self.events.count - self.maxStoredEvents)
            }
        }
    }
    
    /// Get statistics for routing decisions
    public func getRoutingStatistics() -> RoutingStatistics? {
        guard isEnabled else { return nil }
        
        return queue.sync {
            let routingEvents = events.compactMap { event -> (mode: String, score: Double)? in
                if case .routingDecision(let mode, let score, _, _) = event {
                    return (mode, score)
                }
                return nil
            }
            
            guard !routingEvents.isEmpty else { return nil }
            
            let scores = routingEvents.map { $0.score }
            let medianScore = calculateMedian(scores)
            let avgScore = scores.reduce(0, +) / Double(scores.count)
            
            var modeCounts: [String: Int] = [:]
            for event in routingEvents {
                modeCounts[event.mode, default: 0] += 1
            }
            
            return RoutingStatistics(
                totalDecisions: routingEvents.count,
                medianComplexity: medianScore,
                averageComplexity: avgScore,
                modeCounts: modeCounts
            )
        }
    }
    
    /// Get statistics for remote calls
    public func getRemoteCallStatistics() -> RemoteCallStatistics? {
        guard isEnabled else { return nil }
        
        return queue.sync {
            let callEvents = events.compactMap { event -> (success: Bool, latency: TimeInterval)? in
                if case .remoteCallResult(let success, let latency, _) = event {
                    return (success, latency)
                }
                return nil
            }
            
            guard !callEvents.isEmpty else { return nil }
            
            let successCount = callEvents.filter { $0.success }.count
            let successRate = Double(successCount) / Double(callEvents.count)
            
            let latencies = callEvents.map { $0.latency }
            let medianLatency = calculateMedian(latencies)
            let avgLatency = latencies.reduce(0, +) / Double(latencies.count)
            
            return RemoteCallStatistics(
                totalCalls: callEvents.count,
                successRate: successRate,
                medianLatency: medianLatency,
                averageLatency: avgLatency
            )
        }
    }
    
    /// Clear all stored events
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.events.removeAll()
        }
    }
    
    // MARK: - Helper Methods
    
    private func thermalStateString(_ state: TelemetryThermalState) -> String {
        switch state {
        case .nominal: return "nominal"
        case .fair: return "fair"
        case .serious: return "serious"
        case .critical: return "critical"
        @unknown default: return "unknown"
        }
    }
    
    private func calculateMedian(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0.0 }
        
        let sorted = values.sorted()
        let count = sorted.count
        
        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            return sorted[count / 2]
        }
    }
}

// MARK: - Statistics Types

public struct RoutingStatistics {
    public let totalDecisions: Int
    public let medianComplexity: Double
    public let averageComplexity: Double
    public let modeCounts: [String: Int]
}

public struct RemoteCallStatistics {
    public let totalCalls: Int
    public let successRate: Double
    public let medianLatency: TimeInterval
    public let averageLatency: TimeInterval
}
