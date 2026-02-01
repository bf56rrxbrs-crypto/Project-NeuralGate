#if canImport(Combine)
import Foundation
import Combine

/// ViewModel for NeuralGate UI
@available(iOS 16.0, *)
@MainActor
public class NeuralGateViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var recentTasks: [Task] = []
    @Published public var workflows: [Workflow] = []
    @Published public var isProcessing: Bool = false
    @Published public var errorMessage: String?
    
    // MARK: - Properties
    
    private let agent: NeuralGateAgent
    
    // MARK: - Initialization
    
    public init() {
        self.agent = NeuralGateAgent()
        loadWorkflows()
    }
    
    // MARK: - Public Methods
    
    /// Process a natural language request
    /// - Parameter request: User's request text
    public func processRequest(_ request: String) async {
        isProcessing = true
        errorMessage = nil
        
        do {
            let result = try await agent.processRequest(request)
            
            // Update recent tasks
            if let task = agent.taskManager.getTask(result.taskId) {
                recentTasks.insert(task, at: 0)
                
                // Keep only last 10 tasks
                if recentTasks.count > 10 {
                    recentTasks.removeLast()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    /// Execute a workflow by ID
    /// - Parameter workflowId: Workflow identifier
    public func executeWorkflow(_ workflowId: String) async {
        isProcessing = true
        errorMessage = nil
        
        do {
            let result = try await agent.executeWorkflow(workflowId)
            
            // Add tasks from workflow steps to recent tasks
            for stepResult in result.stepResults {
                if let task = agent.taskManager.getTask(stepResult.taskId) {
                    recentTasks.insert(task, at: 0)
                }
            }
            
            // Trim to last 10
            if recentTasks.count > 10 {
                recentTasks = Array(recentTasks.prefix(10))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    /// Open iOS Shortcuts integration
    public func openShortcuts() {
        _Concurrency.Task {
            do {
                try await agent.integrateWithShortcut("NeuralGate")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Enable Siri integration
    public func enableSiri() async {
        do {
            try await agent.enableSiriIntegration()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    
    private func loadWorkflows() {
        workflows = agent.getAvailableWorkflows()
    }
}
#endif
