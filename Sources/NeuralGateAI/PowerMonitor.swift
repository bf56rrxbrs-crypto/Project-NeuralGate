import Foundation
import NeuralGate

#if canImport(Combine)
import Combine
#endif

#if canImport(UIKit)
import UIKit
#endif

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
public typealias ThermalState = ProcessInfo.ThermalState
#else
// Fallback for platforms without ThermalState
public enum ThermalState: Int {
    case nominal = 0
    case fair = 1
    case serious = 2
    case critical = 3
}
#endif

/// Protocol for power monitoring
public protocol PowerMonitoring: AnyObject {
    var thermalState: ThermalState { get }
    var isLowPowerMode: Bool { get }
    var recommendedBatchSize: Int { get }
}

#if canImport(Combine)
/// Monitors device power state and thermal conditions
@MainActor
public class PowerMonitor: ObservableObject, PowerMonitoring {
    
    /// Shared singleton instance
    public static let shared = PowerMonitor()
    
    /// Current thermal state of the device
    @Published public private(set) var thermalState: ThermalState
    
    /// Whether low power mode is enabled
    @Published public private(set) var isLowPowerMode: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Initialize with current state
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        self.thermalState = ProcessInfo.processInfo.thermalState
        #else
        self.thermalState = .nominal
        #endif
        
        #if canImport(UIKit)
        self.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        #else
        self.isLowPowerMode = false
        #endif
        
        setupNotifications()
    }
    
    /// Setup notification observers for power state changes
    private func setupNotifications() {
        // Observe thermal state changes
        NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateThermalState()
            }
            .store(in: &cancellables)
        
        #if canImport(UIKit)
        // Observe low power mode changes (iOS only)
        NotificationCenter.default.publisher(for: NSNotification.Name.NSProcessInfoPowerStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePowerState()
            }
            .store(in: &cancellables)
        #endif
    }
    
    /// Update thermal state from ProcessInfo
    private func updateThermalState() {
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        thermalState = ProcessInfo.processInfo.thermalState
        #else
        thermalState = .nominal
        #endif
        logPowerStateChange()
    }
    
    /// Update power state from ProcessInfo
    private func updatePowerState() {
        #if canImport(UIKit)
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        #else
        isLowPowerMode = false
        #endif
        logPowerStateChange()
    }
    
    /// Log power state changes for telemetry
    private func logPowerStateChange() {
        NeuralGateLogger.shared.log(
            "Power state change - Thermal: \(thermalState), LowPower: \(isLowPowerMode)",
            level: .info
        )
    }
    
    /// Calculate recommended batch size based on current power state
    public var recommendedBatchSize: Int {
        // Base batch size
        var batchSize = 10
        
        // Reduce batch size based on thermal state
        switch thermalState {
        case .nominal:
            batchSize = 10
        case .fair:
            batchSize = 7
        case .serious:
            batchSize = 4
        case .critical:
            batchSize = 2
        @unknown default:
            batchSize = 5
        }
        
        // Further reduce if in low power mode
        if isLowPowerMode {
            batchSize = max(1, batchSize / 2)
        }
        
        return batchSize
    }
}

#else
// Fallback implementation without Combine for non-Apple platforms
public class PowerMonitor: PowerMonitoring {
    
    /// Shared singleton instance
    public static let shared = PowerMonitor()
    
    /// Current thermal state of the device
    public private(set) var thermalState: ThermalState
    
    /// Whether low power mode is enabled
    public private(set) var isLowPowerMode: Bool
    
    private init() {
        #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
        self.thermalState = ProcessInfo.processInfo.thermalState
        #else
        self.thermalState = .nominal
        #endif
        self.isLowPowerMode = false
    }
    
    /// Calculate recommended batch size based on current power state
    public var recommendedBatchSize: Int {
        var batchSize = 10
        
        switch thermalState {
        case .nominal:
            batchSize = 10
        case .fair:
            batchSize = 7
        case .serious:
            batchSize = 4
        case .critical:
            batchSize = 2
        }
        
        if isLowPowerMode {
            batchSize = max(1, batchSize / 2)
        }
        
        return batchSize
    }
}
#endif
