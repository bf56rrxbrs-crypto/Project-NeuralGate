import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// API client with retry logic and circuit breaker for external service calls
public actor APIClient {
    public static let shared = APIClient()
    
    private let session: URLSession
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    private var circuitBreakerState: CircuitBreakerState = .closed
    private var failureCount: Int = 0
    private let circuitBreakerThreshold: Int = 5
    private let circuitBreakerTimeout: TimeInterval = 60
    private var lastFailureTime: Date?
    
    private init(maxRetries: Int = 3, retryDelay: TimeInterval = 2.0) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
    /// Make HTTP request with retry logic and circuit breaker
    public func request(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        // Check circuit breaker
        try await checkCircuitBreaker()
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("NeuralGate/1.0", forHTTPHeaderField: "User-Agent")
        
        // Execute with retry logic
        return try await executeWithRetry(request: request)
    }
    
    /// Execute request with exponential backoff retry
    private func executeWithRetry(request: URLRequest, attempt: Int = 0) async throws -> (Data, HTTPURLResponse) {
        do {
            // Use async/await URLSession data task
            #if canImport(FoundationNetworking)
            // For Linux compatibility
            let (data, response): (Data, URLResponse) = try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data = data, let response = response else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    continuation.resume(returning: (data, response))
                }
                task.resume()
            }
            #else
            // For Darwin platforms
            let (data, response) = try await session.data(for: request)
            #endif
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                // Record failure for circuit breaker
                recordFailure()
                
                if httpResponse.statusCode >= 500 && attempt < maxRetries {
                    // Retry on server errors
                    let delay = retryDelay * pow(2.0, Double(attempt))
                    try await _Concurrency.Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return try await executeWithRetry(request: request, attempt: attempt + 1)
                }
                
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // Reset failure count on success
            recordSuccess()
            
            return (data, httpResponse)
            
        } catch {
            // Record failure for circuit breaker
            recordFailure()
            
            // Retry on network errors
            if attempt < maxRetries {
                let delay = retryDelay * pow(2.0, Double(attempt))
                try await _Concurrency.Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await executeWithRetry(request: request, attempt: attempt + 1)
            }
            
            throw error
        }
    }
    
    /// Check circuit breaker state
    private func checkCircuitBreaker() async throws {
        switch circuitBreakerState {
        case .open:
            // Check if timeout has elapsed
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > circuitBreakerTimeout {
                circuitBreakerState = .halfOpen
                failureCount = 0
            } else {
                throw APIError.circuitBreakerOpen
            }
        case .halfOpen, .closed:
            break
        }
    }
    
    /// Record successful request
    private func recordSuccess() {
        failureCount = 0
        circuitBreakerState = .closed
    }
    
    /// Record failed request
    private func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()
        
        if failureCount >= circuitBreakerThreshold {
            circuitBreakerState = .open
        }
    }
    
    /// Get current circuit breaker state
    public func getCircuitBreakerState() -> CircuitBreakerState {
        circuitBreakerState
    }
}

/// HTTP methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// Circuit breaker states
public enum CircuitBreakerState {
    case closed  // Normal operation
    case open    // Failing, rejecting requests
    case halfOpen // Testing if service recovered
}

/// API errors
public enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case circuitBreakerOpen
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .circuitBreakerOpen:
            return "Circuit breaker is open - service unavailable"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
