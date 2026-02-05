# NeuralGate Examples

This directory contains comprehensive examples demonstrating the capabilities of the NeuralGate AI Agent.

## Quick Examples

### 1. Simple Task Execution

```swift
import NeuralGate
import NeuralGateAutomation

let agent = NeuralGateAgent()

let task = Task(
    name: "Send Email",
    description: "Send morning status update",
    priority: .high,
    category: .communication
)

let result = try await agent.executeTask(task)
print("Task completed: \(result.explanation)")
```

### 2. Workflow Automation

```swift
// Create a morning routine workflow
let morningWorkflow = Workflow(
    name: "Morning Routine",
    description: "Automated morning tasks",
    tasks: [
        Task(name: "Check Email", description: "Review inbox", priority: .high, category: .communication),
        Task(name: "Review Calendar", description: "Check today's schedule", priority: .high, category: .productivity),
        Task(name: "Process Notifications", description: "Handle alerts", priority: .medium, category: .general)
    ]
)

let workflowResult = try await agent.executeWorkflow(morningWorkflow)
print("Workflow completed with \(workflowResult.successRate * 100)% success rate")
```

### 3. Predictive Suggestions

```swift
// Get AI-powered task suggestions
let suggestions = agent.getTaskSuggestions()

for suggestion in suggestions {
    print("Suggested: \(suggestion.taskName)")
    print("Confidence: \(String(format: "%.1f", suggestion.confidence * 100))%")
    print("Reasoning: \(suggestion.reasoning)\n")
}
```

### 4. User Feedback Integration

```swift
// Submit positive feedback
let feedback = UserFeedback(
    type: .positive,
    severity: .normal,
    message: "Task executed perfectly and efficiently",
    taskId: task.id
)
agent.submitFeedback(feedback)

// Submit improvement suggestion
let improvementFeedback = UserFeedback(
    type: .improvement,
    severity: .normal,
    message: "Could add better error messages for failed tasks"
)
agent.submitFeedback(improvementFeedback)
```

### 5. Self-Improvement

```swift
// Trigger autonomous self-improvement
let evaluation = try await agent.performSelfImprovement()

print("Performance Score: \(String(format: "%.2f", evaluation.overallScore))")
print("\nImprovement Opportunities:")
for opportunity in evaluation.opportunities {
    print("Area: \(opportunity.area.rawValue)")
    print("Current: \(opportunity.currentValue)")
    print("Target: \(opportunity.targetValue)")
    print("Action: \(opportunity.suggestedAction)\n")
}
```

### 6. Custom Configuration

```swift
// Configure for maximum battery optimization
let configuration = NeuralGateConfiguration(
    debugMode: false,
    maxMemoryUsage: 50,              // Limit to 50MB
    batteryOptimizationLevel: 3,     // Maximum optimization
    enablePredictiveAnalytics: true,
    enableExplainability: true
)

let agent = NeuralGateAgent(configuration: configuration)
```

### 7. Advanced Workflow Composition

```swift
// Create multiple workflows and compose them
let dataCollection = Workflow(
    name: "Data Collection",
    description: "Gather data from various sources",
    tasks: [...]
)

let analysis = Workflow(
    name: "Analysis",
    description: "Analyze collected data",
    tasks: [...]
)

let reporting = Workflow(
    name: "Reporting",
    description: "Generate and send reports",
    tasks: [...]
)

// Compose workflows sequentially
let composedWorkflow = automationEngine.composeWorkflows(
    [dataCollection, analysis, reporting],
    compositionStrategy: .sequential
)

let result = try await agent.executeWorkflow(composedWorkflow)
```

### 8. Monitoring Agent Health

```swift
// Get comprehensive agent status
let status = agent.getStatus()

print("=== Agent Health Report ===")
print("Overall Health: \(status.isHealthy ? "Healthy ✓" : "Needs Attention ⚠️")")
print("Performance Score: \(String(format: "%.1f", status.performanceScore * 100))%")
print("\nTask Statistics:")
print("- Queued: \(status.taskStatistics.totalQueued)")
print("- Completed: \(status.taskStatistics.totalCompleted)")
print("- Failed: \(status.taskStatistics.totalFailed)")
print("- Completion Rate: \(String(format: "%.1f", status.taskStatistics.completionRate * 100))%")
print("\nUser Satisfaction:")
print("- Total Feedback: \(status.feedbackAnalysis.totalFeedback)")
print("- Satisfaction Score: \(String(format: "%.1f", status.feedbackAnalysis.satisfactionScore * 100))%")
print("- Positive: \(status.feedbackAnalysis.positiveCount)")
print("- Negative: \(status.feedbackAnalysis.negativeCount)")
```

### 9. Custom AI Models

```swift
import NeuralGateAI

// Create a custom AI model
class SmartPriorityModel: AIModel {
    let name = "SmartPriority"
    
    var estimatedMemoryUsage: Int { 15 }
    var estimatedCPUUsage: Double { 0.25 }
    var estimatedBatteryImpact: Double { 0.1 }
    
    func canExecute(configuration: NeuralGateConfiguration) -> Bool {
        return estimatedMemoryUsage <= configuration.maxMemoryUsage
    }
    
    func predict(task: Task, context: ExecutionContext) async throws -> ModelPrediction {
        // Custom prediction logic
        var confidence = 0.7
        var decision: TaskDecision = .execute
        
        // Consider time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        if task.category == .communication {
            // Communication tasks during work hours get higher priority
            if hour >= 9 && hour <= 17 {
                confidence = 0.9
                decision = .execute
            } else {
                confidence = 0.5
                decision = .deferTask
            }
        }
        
        let reasoning = "Smart priority based on time (\(hour):00) and category (\(task.category.rawValue))"
        return ModelPrediction(decision: decision, confidence: confidence, reasoning: reasoning)
    }
}

// Use custom model
let decisionEngine = AIDecisionEngine(
    configuration: configuration,
    models: [BaselineAIModel(), SmartPriorityModel()]
)
```

### 10. Real-Time Learning

```swift
import NeuralGateLearning

// Record task feedback for continuous learning
let feedbackSystem = FeedbackLoopSystem(configuration: configuration)

// After task execution
let taskFeedback = TaskFeedback(
    taskId: task.id,
    taskCategory: task.category,
    wasSuccessful: true,
    executionTime: 2.5,
    userRating: 5,
    userComments: "Executed perfectly"
)

feedbackSystem.recordFeedback(taskFeedback)

// Get adaptations learned from feedback
let adaptations = feedbackSystem.getAdaptations(for: nextTask)
for adaptation in adaptations {
    print("Learned adaptation: \(adaptation.description)")
    print("Confidence: \(String(format: "%.1f", adaptation.confidence * 100))%")
}
```

## iOS Integration Example

### SwiftUI View Integration

```swift
import SwiftUI
import NeuralGate
import NeuralGateAutomation

struct TaskAutomationView: View {
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Task Queue
                List(viewModel.tasks) { task in
                    TaskRow(task: task)
                }
                
                // Suggestions
                if !viewModel.suggestions.isEmpty {
                    SuggestionsSection(suggestions: viewModel.suggestions)
                }
                
                // Agent Status
                StatusCard(status: viewModel.agentStatus)
            }
            .navigationTitle("NeuralGate")
        }
        .task {
            await viewModel.initialize()
        }
    }
}

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var suggestions: [TaskSuggestion] = []
    @Published var agentStatus: AgentStatus?
    
    private let agent: NeuralGateAgent
    
    init() {
        let config = NeuralGateConfiguration(
            maxMemoryUsage: 50,
            batteryOptimizationLevel: 2
        )
        self.agent = NeuralGateAgent(configuration: config)
    }
    
    func initialize() async {
        // Load suggestions
        suggestions = agent.getTaskSuggestions()
        
        // Update status
        agentStatus = agent.getStatus()
    }
    
    func executeTask(_ task: Task) async {
        do {
            let result = try await agent.executeTask(task)
            // Handle result
        } catch {
            // Handle error
        }
    }
}
```

## Performance Tips

1. **Memory Management**: Set `maxMemoryUsage` based on your device capabilities
2. **Battery Optimization**: Use `batteryOptimizationLevel: 3` for background operations
3. **Feedback Loop**: Regularly submit user feedback to improve accuracy
4. **Predictive Analytics**: Enable for better task suggestions
5. **Workflow Composition**: Use workflows for related tasks to improve efficiency

## Best Practices

1. Always check `agentStatus.isHealthy` before critical operations
2. Use explainable AI to understand decision-making
3. Monitor performance metrics regularly
4. Submit feedback for both successful and failed tasks
5. Leverage predictive suggestions for proactive task management
6. Configure resource limits appropriate for your use case
7. Use workflow composition for complex multi-step operations
8. Handle errors gracefully with failover support
