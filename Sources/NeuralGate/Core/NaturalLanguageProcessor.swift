import Foundation
#if canImport(NaturalLanguage)
import NaturalLanguage
#endif

/// Processes natural language input to understand user intent
@available(iOS 16.0, *)
public class NaturalLanguageProcessor {
    
    // MARK: - Properties
    
    #if canImport(NaturalLanguage)
    private let tagger: NLTagger
    #endif
    
    // MARK: - Initialization
    
    public init() {
        #if canImport(NaturalLanguage)
        self.tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Parse natural language text to extract user intent
    /// - Parameter text: Natural language input
    /// - Returns: Parsed intent
    /// - Throws: NeuralGateError if input is invalid or parsing fails
    public func parseIntent(_ text: String) async throws -> Intent {
        // Edge case: empty or whitespace-only input
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            throw NeuralGateError.invalidInput("Input text cannot be empty")
        }
        
        // Edge case: extremely long input (>5000 characters)
        guard trimmedText.count <= 5000 else {
            throw NeuralGateError.invalidInput("Input text exceeds maximum length of 5000 characters")
        }
        
        #if canImport(NaturalLanguage)
        // Tokenize and tag the input
        tagger.string = trimmedText
        let tokens = tokenize(trimmedText)
        
        // Extract action verbs and entities
        let action = extractAction(from: tokens, text: trimmedText)
        let entities = extractEntities(from: tokens, text: trimmedText)
        #else
        // Fallback for non-iOS platforms
        let tokens = trimmedText.components(separatedBy: .whitespaces)
        let action = extractAction(from: tokens, text: trimmedText)
        let entities: [Entity] = []
        #endif
        
        // Determine priority from context
        let priority = determinePriority(from: trimmedText)
        
        // Build parameters dictionary
        var parameters: [String: Any] = [:]
        for entity in entities {
            parameters[entity.type] = entity.value
        }
        
        return Intent(
            action: action,
            parameters: parameters,
            priority: priority,
            originalText: trimmedText
        )
    }
    
    // MARK: - Private Methods
    
    private func tokenize(_ text: String) -> [String] {
        #if canImport(NaturalLanguage)
        var tokens: [String] = []
        
        tagger.string = text
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            let token = String(text[range])
            tokens.append(token)
            return true
        }
        
        return tokens
        #else
        return text.components(separatedBy: .whitespaces)
        #endif
    }
    
    private func extractAction(from tokens: [String], text: String) -> String {
        // Common action verbs for task automation
        let actionVerbs = [
            "send", "create", "schedule", "remind", "call", "message",
            "email", "set", "open", "start", "stop", "play", "pause"
        ]
        
        for token in tokens {
            if actionVerbs.contains(token.lowercased()) {
                return token.lowercased()
            }
        }
        
        return "execute" // Default action
    }
    
    private func extractEntities(from tokens: [String], text: String) -> [Entity] {
        #if canImport(NaturalLanguage)
        var entities: [Entity] = []
        
        tagger.string = text
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if let tag = tag {
                let value = String(text[range])
                let entity = Entity(type: tag.rawValue, value: value)
                entities.append(entity)
            }
            return true
        }
        
        return entities
        #else
        return []
        #endif
    }
    
    private func determinePriority(from text: String) -> Task.Priority {
        let urgentKeywords = ["urgent", "asap", "immediately", "now", "critical"]
        let textLower = text.lowercased()
        
        for keyword in urgentKeywords {
            if textLower.contains(keyword) {
                return .high
            }
        }
        
        return .medium
    }
}

// MARK: - Supporting Structures

private struct Entity {
    let type: String
    let value: String
}
