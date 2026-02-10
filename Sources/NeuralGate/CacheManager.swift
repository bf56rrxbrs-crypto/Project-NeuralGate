import Foundation

/// Thread-safe cache manager for optimizing repeated operations
public actor CacheManager {
    public static let shared = CacheManager()
    
    private var cache: [String: CacheEntry] = [:]
    private let maxCacheSize: Int
    private let defaultTTL: TimeInterval
    
    private init(maxCacheSize: Int = 1000, defaultTTL: TimeInterval = 300) {
        self.maxCacheSize = maxCacheSize
        self.defaultTTL = defaultTTL
    }
    
    /// Store value in cache with optional TTL
    public func set<T>(_ value: T, forKey key: String, ttl: TimeInterval? = nil) {
        // Remove expired entries if cache is full
        if cache.count >= maxCacheSize {
            cleanupExpiredEntries()
        }
        
        let expirationDate = Date().addingTimeInterval(ttl ?? defaultTTL)
        cache[key] = CacheEntry(value: value, expirationDate: expirationDate)
    }
    
    /// Retrieve value from cache
    public func get<T>(_ key: String) -> T? {
        guard let entry = cache[key] else {
            return nil
        }
        
        // Check if entry has expired
        if Date() > entry.expirationDate {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return entry.value as? T
    }
    
    /// Remove value from cache
    public func remove(_ key: String) {
        cache.removeValue(forKey: key)
    }
    
    /// Clear all cache entries
    public func clear() {
        cache.removeAll()
    }
    
    /// Remove expired entries
    private func cleanupExpiredEntries() {
        let now = Date()
        cache = cache.filter { $0.value.expirationDate > now }
    }
    
    /// Get cache statistics
    public func getStats() -> CacheStats {
        let now = Date()
        let validEntries = cache.filter { $0.value.expirationDate > now }.count
        let expiredEntries = cache.count - validEntries
        
        return CacheStats(
            totalEntries: cache.count,
            validEntries: validEntries,
            expiredEntries: expiredEntries,
            maxSize: maxCacheSize
        )
    }
}

/// Cache entry with expiration
private struct CacheEntry {
    let value: Any
    let expirationDate: Date
}

/// Cache statistics
public struct CacheStats {
    public let totalEntries: Int
    public let validEntries: Int
    public let expiredEntries: Int
    public let maxSize: Int
    
    public var utilizationPercentage: Double {
        Double(validEntries) / Double(maxSize) * 100
    }
}
