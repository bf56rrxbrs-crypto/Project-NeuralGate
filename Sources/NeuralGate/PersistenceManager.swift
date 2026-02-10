import Foundation

/// Persistent storage manager for offline operation and state management
public actor PersistenceManager {
    public static let shared = PersistenceManager()
    
    private let fileManager = FileManager.default
    private let storageDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        // Create storage directory in app's documents folder
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageDirectory = documentsPath.appendingPathComponent("NeuralGate", isDirectory: true)
        
        // Ensure directory exists
        try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
    }
    
    /// Save codable object to persistent storage
    public func save<T: Codable>(_ object: T, withKey key: String) async throws {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")
        let data = try encoder.encode(object)
        try data.write(to: fileURL, options: [.atomic])
    }
    
    /// Load codable object from persistent storage
    public func load<T: Codable>(_ type: T.Type, withKey key: String) async throws -> T {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(type, from: data)
    }
    
    /// Check if object exists in storage
    public func exists(withKey key: String) -> Bool {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Delete object from storage
    public func delete(withKey key: String) async throws {
        let fileURL = storageDirectory.appendingPathComponent("\(key).json")
        try fileManager.removeItem(at: fileURL)
    }
    
    /// List all stored keys
    public func listKeys() throws -> [String] {
        let contents = try fileManager.contentsOfDirectory(at: storageDirectory, includingPropertiesForKeys: nil)
        return contents
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent }
    }
    
    /// Clear all stored data
    public func clearAll() async throws {
        let contents = try fileManager.contentsOfDirectory(at: storageDirectory, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Get storage size in bytes
    public func getStorageSize() throws -> Int64 {
        let contents = try fileManager.contentsOfDirectory(at: storageDirectory, includingPropertiesForKeys: [.fileSizeKey])
        return contents.reduce(0) { total, url in
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(fileSize)
        }
    }
}

/// Persistent state container for agent status
public struct PersistentAgentState: Codable {
    public var lastExecutedTaskId: UUID?
    public var completedTaskCount: Int
    public var failedTaskCount: Int
    public var lastUpdateTime: Date
    public var configuration: CodableConfiguration
    
    public init(
        lastExecutedTaskId: UUID? = nil,
        completedTaskCount: Int = 0,
        failedTaskCount: Int = 0,
        lastUpdateTime: Date = Date(),
        configuration: CodableConfiguration = CodableConfiguration()
    ) {
        self.lastExecutedTaskId = lastExecutedTaskId
        self.completedTaskCount = completedTaskCount
        self.failedTaskCount = failedTaskCount
        self.lastUpdateTime = lastUpdateTime
        self.configuration = configuration
    }
}

/// Codable version of NeuralGateConfiguration for persistence
public struct CodableConfiguration: Codable {
    public var debugMode: Bool
    public var maxMemoryUsage: Int
    public var batteryOptimizationLevel: Int
    public var enablePredictiveAnalytics: Bool
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
    
    public func toConfiguration() -> NeuralGateConfiguration {
        return NeuralGateConfiguration(
            debugMode: debugMode,
            maxMemoryUsage: maxMemoryUsage,
            batteryOptimizationLevel: batteryOptimizationLevel,
            enablePredictiveAnalytics: enablePredictiveAnalytics,
            enableExplainability: enableExplainability
        )
    }
}
