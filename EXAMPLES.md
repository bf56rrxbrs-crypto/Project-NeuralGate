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

## AI Enhancement Examples

### 11. Capability Analysis

```swift
import NeuralGate
import NeuralGateAutomation

let agent = NeuralGateAgent()

// Analyze platform capabilities
let opportunities = await agent.analyzeCapabilities()

print("Found \(opportunities.count) enhancement opportunities\n")

// Display top 5 opportunities
for (index, opportunity) in opportunities.prefix(5).enumerated() {
    print("\(index + 1). \(opportunity.capability)")
    print("   Priority: \(opportunity.priority.rawValue)")
    print("   Impact: \(Int(opportunity.estimatedImpact * 100))%")
    print("   Complexity: \(opportunity.implementationComplexity.rawValue)")
    print("   Suggestion: \(opportunity.suggestedEnhancement)")
    print("   Expected Value Increase: +\(String(format: "%.0f", opportunity.estimatedValueIncrease))%\n")
}

// Generate comprehensive report
let report = agent.generateCapabilityReport()
print(report)
```

### 12. Usage Pattern Analysis

```swift
// Execute multiple tasks to generate usage data
let tasks = [
    Task(name: "Morning Email", description: "Check emails", priority: .high, category: .communication),
    Task(name: "Daily Standup", description: "Team sync", priority: .high, category: .communication),
    Task(name: "Code Review", description: "Review PRs", priority: .medium, category: .productivity),
    Task(name: "Documentation", description: "Update docs", priority: .low, category: .productivity)
]

for task in tasks {
    _ = try await agent.executeTask(task)
}

// Analyze patterns
let patterns = await agent.analyzeUsagePatterns()

print("Detected \(patterns.count) usage patterns:\n")

for pattern in patterns {
    print("Pattern: \(pattern.name)")
    print("  Frequency: \(Int(pattern.frequency * 100))%")
    print("  Confidence: \(Int(pattern.confidence * 100))%")
    print("  Success Rate: \(Int(pattern.averageSuccessRate * 100))%")
    print("  Description: \(pattern.description)\n")
}

// Identify gaps
let gaps = await agent.identifyUsageGaps()

if !gaps.isEmpty {
    print("\nIdentified \(gaps.count) usage gaps:\n")
    
    for gap in gaps {
        print("\(gap.type.rawValue) - \(gap.severity.rawValue) Severity")
        print("  Issue: \(gap.description)")
        print("  Action: \(gap.recommendedAction)")
        print("  Potential Value: +\(Int(gap.potentialValue * 100))%\n")
    }
}

// Get usage statistics
let stats = agent.getUsageStatistics()
print("\nUsage Statistics:")
print("  Total Executions: \(stats.totalExecutions)")
print("  Success Rate: \(Int(stats.successRate * 100))%")
print("  Average Execution Time: \(String(format: "%.2f", stats.averageExecutionTime))s")
print("  Detected Patterns: \(stats.detectedPatterns)")
print("  Identified Gaps: \(stats.identifiedGaps)")
```

### 13. AI Model Recommendation

```swift
let task = Task(
    name: "Analyze Meeting Notes",
    description: "Extract action items from meeting transcript",
    priority: .high,
    category: .productivity
)

let context = ExecutionContext(currentTask: task)

// Get model recommendation
let recommendation = await agent.recommendModel(for: task, context: context)

print("Recommended AI Model: \(recommendation.model.name)")
print("Type: \(recommendation.model.type.rawValue)")
print("Confidence: \(Int(recommendation.confidence * 100))%\n")

print("Reasoning:")
print(recommendation.reasoning)

print("\nExpected Performance:")
print("  Accuracy: \(Int(recommendation.expectedPerformance.accuracy * 100))%")
print("  Inference Time: \(String(format: "%.3f", recommendation.expectedPerformance.inferenceTime))s")
print("  Resource Usage: \(Int(recommendation.expectedPerformance.resourceUsage * 100))%")
print("  Battery Impact: \(recommendation.expectedPerformance.batteryImpact.rawValue)")

// Show alternative models
if !recommendation.alternativeModels.isEmpty {
    print("\nAlternative Models:")
    for altModel in recommendation.alternativeModels {
        print("  - \(altModel.name) (\(altModel.type.rawValue))")
        print("    Accuracy: \(Int(altModel.averageAccuracy * 100))%")
        print("    Memory: \(altModel.resourceRequirements.memoryMB)MB\n")
    }
}

// Get all available models
let allModels = agent.getAvailableModels()
print("\nAvailable Models: \(allModels.count)")
for model in allModels {
    print("  - \(model.name): \(Int(model.averageAccuracy * 100))% accuracy")
}

// Generate detailed model report
let modelReport = agent.generateModelReport()
print("\n" + modelReport)
```

### 14. Feature Suggestion Generation

```swift
// Generate feature suggestions
let suggestions = await agent.generateFeatureSuggestions()

print("Generated \(suggestions.count) feature suggestions\n")

// Display high-priority suggestions
let highPriority = suggestions.filter { $0.priority == .high || $0.priority == .critical }

print("High Priority Features (\(highPriority.count)):\n")

for suggestion in highPriority {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("\(suggestion.name)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Category: \(suggestion.category.rawValue)")
    print("Priority: \(suggestion.priority.rawValue)")
    print("Estimated Value: \(Int(suggestion.estimatedValue * 100))%")
    print("Implementation Effort: \(suggestion.implementationEffort.rawValue)")
    print("Target Users: \(suggestion.targetUsers.rawValue)")
    print("\nDescription:")
    print(suggestion.description)
    print("\nExpected Benefits:")
    for benefit in suggestion.expectedBenefits {
        print("  ✓ \(benefit)")
    }
    if !suggestion.dependencies.isEmpty {
        print("\nDependencies:")
        for dependency in suggestion.dependencies {
            print("  - \(dependency)")
        }
    }
    print("\nReasoning:")
    print(suggestion.reasoning)
    print()
}

// Get high-value features only
let highValue = agent.getHighValueFeatures(threshold: 0.85)
print("\nHigh-Value Features (≥85%): \(highValue.count)")

// Generate feature roadmap
let roadmap = agent.generateFeatureRoadmap()
print("\n" + roadmap)
```

### 15. Complete AI Enhancement Workflow

```swift
// Comprehensive example showing all AI enhancement systems

let agent = NeuralGateAgent(configuration: NeuralGateConfiguration(
    debugMode: false,
    maxMemoryUsage: 100,
    batteryOptimizationLevel: 2,
    enablePredictiveAnalytics: true
))

print("🧠 NeuralGate AI Enhancement Analysis\n")
print("=" * 60)

// 1. Capability Analysis
print("\n📊 CAPABILITY ANALYSIS\n")
let capabilities = await agent.analyzeCapabilities()
let highPriorityCap = capabilities.filter { $0.priority == .high }.count
let criticalCap = capabilities.filter { $0.priority == .critical }.count

print("Total Opportunities: \(capabilities.count)")
print("Critical Priority: \(criticalCap)")
print("High Priority: \(highPriorityCap)")

if let topOpportunity = capabilities.first {
    print("\nTop Recommendation:")
    print("  \(topOpportunity.suggestedEnhancement)")
    print("  Impact: +\(String(format: "%.0f", topOpportunity.estimatedValueIncrease))%")
}

// 2. Usage Pattern Analysis
print("\n\n📈 USAGE PATTERN ANALYSIS\n")
let patterns = await agent.analyzeUsagePatterns()
let gaps = await agent.identifyUsageGaps()

print("Detected Patterns: \(patterns.count)")
print("Identified Gaps: \(gaps.count)")

if let criticalGap = gaps.first(where: { $0.severity == .critical }) {
    print("\nCritical Gap Found:")
    print("  \(criticalGap.description)")
    print("  Action: \(criticalGap.recommendedAction)")
}

// 3. Model Recommendations
print("\n\n🤖 AI MODEL ANALYSIS\n")
let models = agent.getAvailableModels()
print("Available Models: \(models.count)")

// Get recommendation for a sample task
let sampleTask = Task(
    name: "Smart Scheduling",
    description: "Optimize meeting schedule",
    priority: .high,
    category: .productivity
)

let modelRec = await agent.recommendModel(
    for: sampleTask,
    context: ExecutionContext(currentTask: sampleTask)
)

print("Recommended for Scheduling: \(modelRec.model.name)")
print("  Accuracy: \(Int(modelRec.model.averageAccuracy * 100))%")
print("  Inference: \(modelRec.model.resourceRequirements.inferenceTimeMS)ms")

// 4. Feature Suggestions
print("\n\n💡 FEATURE SUGGESTIONS\n")
let features = await agent.generateFeatureSuggestions()
let highValueFeatures = agent.getHighValueFeatures(threshold: 0.85)

print("Total Suggestions: \(features.count)")
print("High-Value Features: \(highValueFeatures.count)")

// Group by category
let byCategory = Dictionary(grouping: features) { $0.category }
print("\nBy Category:")
for (category, items) in byCategory.sorted(by: { $0.value.count > $1.value.count }) {
    print("  \(category.rawValue): \(items.count)")
}

if let topFeature = features.first {
    print("\nTop Feature Suggestion:")
    print("  \(topFeature.name)")
    print("  Value: \(Int(topFeature.estimatedValue * 100))%")
    print("  \(topFeature.description)")
}

// 5. Summary
print("\n\n📋 SUMMARY\n")
print("=" * 60)
print("✓ Analyzed \(capabilities.count) platform capabilities")
print("✓ Detected \(patterns.count) usage patterns")
print("✓ Identified \(gaps.count) improvement opportunities")
print("✓ Evaluated \(models.count) AI models")
print("✓ Generated \(features.count) feature suggestions")
print("\nNeuralGate AI Enhancement Analysis Complete!")
```

### 16. Periodic Health Check

```swift
// Schedule periodic AI enhancement analysis

import Foundation

actor AIHealthMonitor {
    private let agent: NeuralGateAgent
    private var lastAnalysis: Date?
    
    init(agent: NeuralGateAgent) {
        self.agent = agent
    }
    
    func performHealthCheck() async -> HealthReport {
        let capabilities = await agent.analyzeCapabilities()
        let patterns = await agent.analyzeUsagePatterns()
        let gaps = await agent.identifyUsageGaps()
        let stats = agent.getUsageStatistics()
        
        let criticalIssues = gaps.filter { $0.severity == .critical }.count
        let highPriorityEnhancements = capabilities.filter { 
            $0.priority == .high || $0.priority == .critical 
        }.count
        
        let healthScore = calculateHealthScore(
            successRate: stats.successRate,
            criticalIssues: criticalIssues,
            patterns: patterns.count
        )
        
        lastAnalysis = Date()
        
        return HealthReport(
            score: healthScore,
            successRate: stats.successRate,
            totalExecutions: stats.totalExecutions,
            patternsDetected: patterns.count,
            gapsIdentified: gaps.count,
            criticalIssues: criticalIssues,
            enhancementOpportunities: highPriorityEnhancements,
            recommendation: generateRecommendation(healthScore: healthScore)
        )
    }
    
    private func calculateHealthScore(
        successRate: Double,
        criticalIssues: Int,
        patterns: Int
    ) -> Double {
        var score = successRate * 0.6 // Success rate: 60% weight
        score += (patterns > 0 ? 0.2 : 0.0) // Pattern detection: 20% weight
        score -= (Double(criticalIssues) * 0.1) // Penalty for issues
        return max(0.0, min(1.0, score))
    }
    
    private func generateRecommendation(healthScore: Double) -> String {
        switch healthScore {
        case 0.9...1.0:
            return "Excellent health. Continue monitoring."
        case 0.7..<0.9:
            return "Good health. Review enhancement opportunities."
        case 0.5..<0.7:
            return "Fair health. Address identified gaps."
        default:
            return "Poor health. Immediate action required."
        }
    }
}

struct HealthReport {
    let score: Double
    let successRate: Double
    let totalExecutions: Int
    let patternsDetected: Int
    let gapsIdentified: Int
    let criticalIssues: Int
    let enhancementOpportunities: Int
    let recommendation: String
    
    func print() {
        Swift.print("╔═══════════════════════════════════════╗")
        Swift.print("║     NeuralGate Health Report          ║")
        Swift.print("╠═══════════════════════════════════════╣")
        Swift.print("║ Health Score: \(String(format: "%.0f", score * 100))%\(String(repeating: " ", count: 21))║")
        Swift.print("║ Success Rate: \(String(format: "%.0f", successRate * 100))%\(String(repeating: " ", count: 21))║")
        Swift.print("║ Total Executions: \(totalExecutions)\(String(repeating: " ", count: 25 - String(totalExecutions).count))║")
        Swift.print("╠═══════════════════════════════════════╣")
        Swift.print("║ Patterns: \(patternsDetected)\(String(repeating: " ", count: 29 - String(patternsDetected).count))║")
        Swift.print("║ Gaps: \(gapsIdentified)\(String(repeating: " ", count: 33 - String(gapsIdentified).count))║")
        Swift.print("║ Critical Issues: \(criticalIssues)\(String(repeating: " ", count: 22 - String(criticalIssues).count))║")
        Swift.print("║ Enhancements: \(enhancementOpportunities)\(String(repeating: " ", count: 25 - String(enhancementOpportunities).count))║")
        Swift.print("╠═══════════════════════════════════════╣")
        Swift.print("║ \(recommendation)\(String(repeating: " ", count: 38 - recommendation.count))║")
        Swift.print("╚═══════════════════════════════════════╝")
    }
}

// Usage
let monitor = AIHealthMonitor(agent: agent)
let report = await monitor.performHealthCheck()
report.print()
```

## Conclusion

These examples demonstrate the comprehensive AI enhancement capabilities of NeuralGate. The four AI enhancement systems provide:

1. **CapabilityDiscoveryEngine** - Identifies platform improvement opportunities
2. **UsagePatternAnalyzer** - Detects usage patterns and gaps
3. **ModelRecommendationSystem** - Recommends optimal AI models
4. **FeatureSuggestionEngine** - Suggests new features based on user needs

For complete API documentation, see [DOCUMENTATION.md](DOCUMENTATION.md).
For detailed information on AI enhancements, see [AI_ENHANCEMENTS.md](AI_ENHANCEMENTS.md).
