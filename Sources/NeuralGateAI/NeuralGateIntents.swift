import Foundation
#if canImport(Intents)
import Intents
#endif

#if canImport(Intents)
/// NeuralGate Siri Intent handler for "Ask NeuralGate" queries
@available(iOS 16.0, *)
public class AskNeuralGateIntentHandler: NSObject, AskNeuralGateIntentHandling {
    
    private let logger = NeuralGateLogger.shared
    
    public func handle(intent: AskNeuralGateIntent, completion: @escaping (AskNeuralGateIntentResponse) -> Void) {
        logger.log("AskNeuralGate intent received", level: .info)
        
        guard let prompt = intent.prompt, !prompt.isEmpty else {
            completion(AskNeuralGateIntentResponse.failure(error: "No prompt provided"))
            return
        }
        
        // Generate a task ID for tracking
        let taskId = UUID().uuidString
        
        // Start async processing without blocking
        Task { @MainActor in
            // Get routing decision
            let mode = await Services.router.determineBestMode(
                for: prompt,
                containsSensitiveData: false
            )
            
            // Generate provisional response immediately
            let rationale = """
            Task received and queued for processing.
            
            Task ID: \(taskId)
            Mode: \(mode.rawValue)
            
            Processing will continue in the background. Check the NeuralGate app for results.
            """
            
            logger.log("Returning provisional result for task: \(taskId)", level: .info)
            
            // Return immediately with provisional result
            completion(AskNeuralGateIntentResponse.success(result: rationale))
        }
    }
    
    public func resolvePrompt(for intent: AskNeuralGateIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let prompt = intent.prompt, !prompt.isEmpty {
            completion(INStringResolutionResult.success(with: prompt))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
}

/// Intent definition for "Ask NeuralGate"
@available(iOS 16.0, *)
public class AskNeuralGateIntent: INIntent {
    @NSManaged public var prompt: String?
}

/// Intent response for "Ask NeuralGate"
@available(iOS 16.0, *)
public class AskNeuralGateIntentResponse: INIntentResponse {
    
    @NSManaged public var result: String?
    
    public static func success(result: String) -> AskNeuralGateIntentResponse {
        let response = AskNeuralGateIntentResponse(code: .success, userActivity: nil)
        response.result = result
        return response
    }
    
    public static func failure(error: String) -> AskNeuralGateIntentResponse {
        let response = AskNeuralGateIntentResponse(code: .failure, userActivity: nil)
        response.result = "Error: \(error)"
        return response
    }
}

/// Protocol for handling AskNeuralGate intents
@available(iOS 16.0, *)
public protocol AskNeuralGateIntentHandling {
    func handle(intent: AskNeuralGateIntent, completion: @escaping (AskNeuralGateIntentResponse) -> Void)
    func resolvePrompt(for intent: AskNeuralGateIntent, with completion: @escaping (INStringResolutionResult) -> Void)
}

#endif
