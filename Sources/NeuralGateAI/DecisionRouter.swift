import Foundation
import NeuralGate

#if canImport(CryptoKit)
import CryptoKit
#endif

/// Protocol for routing decisions in the NeuralGate system
public protocol Routing: Actor {
    /// Determines the best execution mode for a given prompt
    /// - Parameters:
    ///   - prompt: The user's input prompt
    ///   - containsSensitiveData: Whether the prompt contains sensitive information
    /// - Returns: The recommended execution mode
    func determineBestMode(for prompt: String, containsSensitiveData: Bool) async -> ExecutionMode
}

/// Execution mode for task routing
public enum ExecutionMode: String, Codable {
    case local      // Execute locally on device
    case remote     // Execute on remote service
    case hybrid     // Use both local and remote
}

/// Actor-based decision router for determining optimal execution strategy
public actor DecisionRouter: Routing {
    /// Configurable complexity threshold (0.0-1.0) for routing decisions
    public var complexityThreshold: Double
    
    private let logger = NeuralGateLogger.shared
    
    public init(complexityThreshold: Double = 0.6) {
        self.complexityThreshold = max(0.0, min(1.0, complexityThreshold))
    }
    
    /// Determines the best execution mode for a given prompt
    public func determineBestMode(for prompt: String, containsSensitiveData: Bool) async -> ExecutionMode {
        // Privacy: Hash the prompt for logging instead of logging raw content
        let promptHash = hashPrompt(prompt)
        let complexity = calculateComplexity(for: prompt)
        
        // Log with hashed ID and metadata (no PII)
        logger.log("Routing decision - Hash: \(promptHash), Complexity: \(String(format: "%.3f", complexity)), Sensitive: \(containsSensitiveData)", level: .info)
        
        // Decision logic
        let mode: ExecutionMode
        
        if containsSensitiveData {
            // Always use local mode for sensitive data
            mode = .local
        } else if complexity < complexityThreshold {
            // Simple prompts can be handled locally
            mode = .local
        } else {
            // Complex prompts benefit from remote processing
            mode = .remote
        }
        
        logger.log("Selected mode: \(mode.rawValue) for hash: \(promptHash)", level: .info)
        
        return mode
    }
    
    /// Calculates normalized complexity score in range [0, 1]
    /// Uses token-based splitting and keyword analysis with clamped results
    public func calculateComplexity(for prompt: String) -> Double {
        guard !prompt.isEmpty else { return 0.0 }
        
        // Normalize whitespace and get tokens
        let normalized = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return 0.0 }
        
        let tokens = normalized.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        guard !tokens.isEmpty else { return 0.0 }
        
        // Calculate length-based score (normalized to 0-1 range)
        // Assumption: 50+ tokens = high complexity (score approaches 1.0)
        let tokenCount = Double(tokens.count)
        let lengthScore = min(1.0, tokenCount / 50.0)
        
        // Keywords that indicate complexity
        let complexityKeywords = [
            "analyze", "compare", "evaluate", "synthesize", "explain",
            "calculate", "optimize", "predict", "recommend", "summarize",
            "integrate", "coordinate", "orchestrate", "transform"
        ]
        
        // Count complexity keywords in the prompt (case-insensitive)
        let lowercasePrompt = normalized.lowercased()
        let keywordCount = complexityKeywords.reduce(0) { count, keyword in
            count + (lowercasePrompt.contains(keyword) ? 1 : 0)
        }
        
        // Keyword boost (normalized, max 0.3 additional complexity)
        let keywordBoost = min(0.3, Double(keywordCount) * 0.1)
        
        // Combine scores with weights
        let rawScore = (lengthScore * 0.7) + keywordBoost
        
        // Clamp to [0, 1] range for deterministic output
        let finalScore = max(0.0, min(1.0, rawScore))
        
        return finalScore
    }
    
    /// Hash prompt for privacy-preserving logging
    private func hashPrompt(_ prompt: String) -> String {
        #if canImport(CryptoKit)
        let data = Data(prompt.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined().prefix(16).description
        #else
        // Fallback for platforms without CryptoKit
        return String(prompt.hashValue, radix: 16).prefix(16).description
        #endif
    }
}
