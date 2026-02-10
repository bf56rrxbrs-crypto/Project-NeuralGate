import Foundation

/// Service locator for dependency injection
@MainActor
public class Services {
    /// Router for decision making
    public static var router: Routing = DecisionRouter()
    
    /// Power monitor for device state
    public static var powerMonitor: PowerMonitoring = PowerMonitor.shared
    
    // Prevent instantiation
    private init() {}
}
