import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

/// Protocol for power monitoring
public protocol PowerMonitoring: AnyObject {
    var thermalState: ProcessInfo.ThermalState { get }
    var isLowPowerMode: Bool { get }
    var recommendedBatchSize: Int { get }
}

/// Monitors device power state and thermal conditions
@MainActor
public class PowerMonitor: ObservableObject, PowerMonitoring {
    
    /// Shared singleton instance
    public static let shared = PowerMonitor()
    
    /// Current thermal state of the device
    @Published public private(set) var thermalState: ProcessInfo.ThermalState
    
    /// Whether low power mode is enabled
    @Published public private(set) var isLowPowerMode: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Initialize with current state
        self.thermalState = ProcessInfo.processInfo.thermalState
        
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
        thermalState = ProcessInfo.processInfo.thermalState
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
