import Foundation
import NeuralGate

/// Circuit breaker state
public enum CircuitState {
    case closed      // Normal operation
    case open        // Failure threshold exceeded, blocking calls
    case halfOpen    // Testing if service recovered
}

/// Circuit breaker for remote LLM calls with fallback support
public actor CircuitBreaker {
    
    /// Current state of the circuit
    private(set) public var state: CircuitState = .closed
    
    /// Number of consecutive failures
    private var consecutiveFailures: Int = 0
    
    /// Failure threshold before opening circuit
    public let failureThreshold: Int
    
    /// Timeout duration in seconds before attempting recovery (half-open)
    public let timeout: TimeInterval
    
    /// Timestamp when circuit was opened
    private var openedAt: Date?
    
    /// Base delay for exponential backoff (in seconds)
    private let baseRetryDelay: TimeInterval = 1.0
    
    /// Maximum retry delay (in seconds)
    private let maxRetryDelay: TimeInterval = 60.0
    
    private let logger = NeuralGateLogger.shared
    
    public init(failureThreshold: Int = 3, timeout: TimeInterval = 60.0) {
        self.failureThreshold = max(1, failureThreshold)
        self.timeout = timeout
    }
    
    /// Execute a remote call with circuit breaker protection
    /// - Parameter operation: The async operation to execute
    /// - Returns: Result of the operation or fallback
    public func execute<T>(
        operation: () async throws -> T,
        fallback: () async -> T
    ) async -> T {
        // Check if circuit should transition to half-open
        if state == .open, let openedAt = openedAt,
           Date().timeIntervalSince(openedAt) >= timeout {
            logger.log("Circuit transitioning to half-open state", level: .info)
            state = .halfOpen
        }
        
        // If circuit is open, use fallback immediately
        guard state != .open else {
            logger.log("Circuit is open, using fallback", level: .warning)
            return await fallback()
        }
        
        do {
            // Attempt the operation
            let result = try await operation()
            
            // Success - reset failure count and close circuit
            if state == .halfOpen {
                logger.log("Circuit recovered, closing circuit", level: .info)
            }
            consecutiveFailures = 0
            state = .closed
            openedAt = nil
            
            return result
        } catch {
            // Record failure
            consecutiveFailures += 1
            logger.log("Operation failed (attempt \(consecutiveFailures)/\(failureThreshold)): \(error)", level: .warning)
            
            // Check if threshold exceeded
            if consecutiveFailures >= failureThreshold {
                logger.log("Failure threshold exceeded, opening circuit", level: .error)
                state = .open
                openedAt = Date()
            }
            
            // Use fallback
            return await fallback()
        }
    }
    
    /// Execute with exponential backoff retry logic
    public func executeWithRetry<T>(
        maxAttempts: Int = 3,
        operation: () async throws -> T,
        fallback: () async -> T
    ) async -> T {
        for attempt in 1...maxAttempts {
            do {
                let result = try await operation()
                
                // Success - reset state
                if state == .halfOpen {
                    logger.log("Circuit recovered after retry", level: .info)
                }
                consecutiveFailures = 0
                state = .closed
                openedAt = nil
                
                return result
            } catch {
                logger.log("Retry attempt \(attempt)/\(maxAttempts) failed: \(error)", level: .warning)
                
                // Don't retry if this was the last attempt
                guard attempt < maxAttempts else { break }
                
                // Exponential backoff: 1s, 2s, 4s, 8s, etc. (capped at maxRetryDelay)
                let delay = min(baseRetryDelay * pow(2.0, Double(attempt - 1)), maxRetryDelay)
                logger.log("Waiting \(String(format: "%.1f", delay))s before retry", level: .info)
                
                try? await _Concurrency.Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        // All retries exhausted - record failures and use fallback
        consecutiveFailures += maxAttempts
        
        if consecutiveFailures >= failureThreshold {
            logger.log("Failure threshold exceeded after retries, opening circuit", level: .error)
            state = .open
            openedAt = Date()
        }
        
        logger.log("All retry attempts exhausted, using fallback", level: .error)
        return await fallback()
    }
    
    /// Get current circuit breaker status
    public func getStatus() -> (state: CircuitState, failures: Int) {
        return (state, consecutiveFailures)
    }
    
    /// Reset circuit breaker manually
    public func reset() {
        state = .closed
        consecutiveFailures = 0
        openedAt = nil
        logger.log("Circuit breaker manually reset", level: .info)
    }
}

/// Deterministic local fallback response generator
public struct LocalFallbackGenerator {
    
    /// Generate a fallback response when remote service is unavailable
    public static func generateFallback(for prompt: String) -> String {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedPrompt.isEmpty else {
            return "I'm currently operating in offline mode. Please provide a prompt to process."
        }
        
        // Analyze prompt for basic categorization
        let lowercased = trimmedPrompt.lowercased()
        
        if lowercased.contains("help") || lowercased.contains("how") {
            return "I'm currently in offline mode with limited capabilities. For '\(trimmedPrompt)', I recommend trying again when online connectivity is restored, or consult local documentation."
        } else if lowercased.contains("what") || lowercased.contains("explain") {
            return "I'm operating offline. I can provide basic task execution but complex queries like '\(trimmedPrompt)' require online connectivity."
        } else {
            return "I'm currently in offline mode. Your request '\(trimmedPrompt)' has been noted. For best results, please retry when connectivity is restored."
        }
    }
}
