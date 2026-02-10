import Foundation

/// Webhook manager for receiving and dispatching webhook events
public actor WebhookManager {
    public static let shared = WebhookManager()
    
    private var registrations: [String: WebhookRegistration] = [:]
    private var eventHandlers: [String: [(WebhookEvent) async -> Void]] = [:]
    private let logger = NeuralGateLogger.shared
    
    private init() {}
    
    /// Register a webhook endpoint
    public func register(
        eventType: String,
        url: URL,
        secret: String? = nil,
        headers: [String: String]? = nil
    ) -> String {
        let id = UUID().uuidString
        let registration = WebhookRegistration(
            id: id,
            eventType: eventType,
            url: url,
            secret: secret,
            headers: headers,
            isActive: true,
            createdAt: Date()
        )
        
        registrations[id] = registration
        logger.log("Webhook registered: \(eventType) -> \(url)", level: .info)
        
        return id
    }
    
    /// Unregister a webhook
    public func unregister(_ id: String) {
        registrations.removeValue(forKey: id)
        logger.log("Webhook unregistered: \(id)", level: .info)
    }
    
    /// Get all active registrations
    public func getRegistrations() -> [WebhookRegistration] {
        Array(registrations.values).filter { $0.isActive }
    }
    
    /// Add event handler for specific event type
    public func addHandler(
        for eventType: String,
        handler: @escaping (WebhookEvent) async -> Void
    ) {
        if eventHandlers[eventType] == nil {
            eventHandlers[eventType] = []
        }
        eventHandlers[eventType]?.append(handler)
        logger.log("Event handler added for: \(eventType)", level: .info)
    }
    
    /// Dispatch webhook event to registered endpoints and handlers
    public func dispatch(_ event: WebhookEvent) async {
        logger.log("Dispatching webhook event: \(event.type)", level: .info)
        
        // Call local handlers
        if let handlers = eventHandlers[event.type] {
            for handler in handlers {
                await handler(event)
            }
        }
        
        // Call remote webhooks
        let relevantRegistrations = registrations.values.filter {
            $0.isActive && ($0.eventType == event.type || $0.eventType == "*")
        }
        
        for registration in relevantRegistrations {
            await sendWebhook(event: event, to: registration)
        }
    }
    
    /// Send webhook to remote endpoint
    private func sendWebhook(event: WebhookEvent, to registration: WebhookRegistration) async {
        do {
            let payload = try JSONEncoder().encode(event)
            var headers = registration.headers ?? [:]
            
            // Add signature if secret is provided
            if let secret = registration.secret {
                let signature = generateSignature(payload: payload, secret: secret)
                headers["X-Webhook-Signature"] = signature
            }
            
            let _ = try await APIClient.shared.request(
                url: registration.url,
                method: .post,
                headers: headers,
                body: payload
            )
            
            logger.log("Webhook sent successfully to: \(registration.url)", level: .info)
            
        } catch {
            logger.log("Failed to send webhook: \(error.localizedDescription)", level: .error)
        }
    }
    
    /// Generate HMAC signature for webhook payload
    private func generateSignature(payload: Data, secret: String) -> String {
        // In production, use proper HMAC-SHA256
        // For now, simple hash representation
        let combined = payload.base64EncodedString() + secret
        return combined.data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    /// Verify webhook signature
    public func verifySignature(
        payload: Data,
        signature: String,
        secret: String
    ) -> Bool {
        let expectedSignature = generateSignature(payload: payload, secret: secret)
        return signature == expectedSignature
    }
}

/// Webhook registration information
public struct WebhookRegistration: Codable {
    public let id: String
    public let eventType: String
    public let url: URL
    public let secret: String?
    public let headers: [String: String]?
    public var isActive: Bool
    public let createdAt: Date
}

/// Webhook event
public struct WebhookEvent: Codable {
    public let id: String
    public let type: String
    public let timestamp: Date
    public let data: [String: String]
    
    public init(type: String, data: [String: String] = [:]) {
        self.id = UUID().uuidString
        self.type = type
        self.timestamp = Date()
        self.data = data
    }
}

/// Common webhook event types
public enum WebhookEventType {
    public static let taskStarted = "task.started"
    public static let taskCompleted = "task.completed"
    public static let taskFailed = "task.failed"
    public static let workflowStarted = "workflow.started"
    public static let workflowCompleted = "workflow.completed"
    public static let workflowFailed = "workflow.failed"
    public static let improvementExecuted = "improvement.executed"
    public static let feedbackReceived = "feedback.received"
    public static let all = "*"
}
