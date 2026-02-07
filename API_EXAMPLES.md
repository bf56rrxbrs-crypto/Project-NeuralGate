# API Usage Examples

This document provides comprehensive examples of using the NeuralGate API for common use cases.

## Table of Contents

- [Getting Started](#getting-started)
- [Task Management](#task-management)
- [Workflow Automation](#workflow-automation)
- [Natural Language Processing](#natural-language-processing)
- [iOS Integration](#ios-integration)
- [Advanced Features](#advanced-features)

## Getting Started

### Basic Setup

```swift
import NeuralGate

// Create an agent instance
let agent = NeuralGateAgent()

// Agent is now ready to process tasks and workflows
```

## Task Management

### Creating and Executing Tasks

```swift
// Create a simple task
let task = Task(
    name: "Send Email",
    description: "Send project update to team",
    priority: .high,
    category: .communication
)

// Execute the task
Task {
    do {
        let result = try await agent.executeTask(task)
        print("Task completed: \(result.success)")
    } catch {
        print("Task failed: \(error)")
    }
}
```

### Working with Task Priorities

```swift
// Create tasks with different priorities
let urgentTask = Task(
    name: "Critical Bug Fix",
    description: "Fix production issue",
    priority: .critical  // Executed first
)

let normalTask = Task(
    name: "Update Documentation",
    description: "Update API docs",
    priority: .medium  // Executed after critical tasks
)

let lowPriorityTask = Task(
    name: "Clean Logs",
    description: "Archive old logs",
    priority: .low  // Executed when resources available
)

// Get priority weight for sorting
print("Urgent priority weight: \(urgentTask.priority.weight)") // 4
```

### Task Categories

```swift
// Communication task
let emailTask = Task(
    name: "Team Update",
    description: "Send weekly update",
    category: .communication
)

// Productivity task
let documentTask = Task(
    name: "Create Report",
    description: "Generate monthly report",
    category: .productivity
)

// Automation task
let automationTask = Task(
    name: "Backup Data",
    description: "Automated backup",
    category: .automation
)

// Get all available categories
let allCategories = Task.TaskCategory.allCases
print("Available categories: \(allCategories)")
```

### Task Metadata

```swift
// Add custom metadata to tasks
let task = Task(
    name: "Process Data",
    description: "Process user data",
    priority: .medium,
    metadata: [
        "source": "user_uploads",
        "format": "json",
        "encrypted": "true"
    ]
)

// Access metadata
if let source = task.metadata["source"] {
    print("Data source: \(source)")
}
```

### Scheduling Tasks

```swift
// Schedule a task for future execution
let reminderTask = Task(
    name: "Meeting Reminder",
    description: "Remind about team meeting",
    priority: .medium
)

// Schedule for tomorrow at 9 AM
let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
let scheduledDate = Calendar.current.date(
    bySettingHour: 9,
    minute: 0,
    second: 0,
    of: tomorrow
)!

do {
    try agent.scheduleTask(reminderTask, for: scheduledDate)
    print("Task scheduled successfully")
} catch {
    print("Failed to schedule: \(error)")
}
```

## Workflow Automation

### Creating Custom Workflows

```swift
// Create a morning routine workflow
let morningSteps: [WorkflowStep] = [
    WorkflowStep(
        action: "checkWeather",
        parameters: ["location": "current"],
        isCritical: false
    ),
    WorkflowStep(
        action: "checkCalendar",
        parameters: ["timeframe": "today"],
        isCritical: true
    ),
    WorkflowStep(
        action: "readNews",
        parameters: ["categories": "tech,business"],
        isCritical: false
    )
]

let workflow = agent.createWorkflow(
    name: "morning-routine",
    steps: morningSteps
)
```

### Executing Workflows

```swift
// Execute a predefined workflow
Task {
    do {
        let result = try await agent.executeWorkflow("morning-routine")
        print("Workflow completed: \(result.success)")
        print("Tasks completed: \(result.completedTasks.count)")
    } catch {
        print("Workflow failed: \(error)")
    }
}
```

### Complex Workflow Example

```swift
// Create a data processing workflow
let dataProcessingSteps: [WorkflowStep] = [
    WorkflowStep(
        action: "fetchData",
        parameters: ["endpoint": "api/data", "method": "GET"],
        isCritical: true
    ),
    WorkflowStep(
        action: "validateData",
        parameters: ["schema": "v2"],
        isCritical: true
    ),
    WorkflowStep(
        action: "transformData",
        parameters: ["format": "normalized"],
        isCritical: true
    ),
    WorkflowStep(
        action: "saveData",
        parameters: ["destination": "database"],
        isCritical: true
    ),
    WorkflowStep(
        action: "notifyCompletion",
        parameters: ["recipients": "team@example.com"],
        isCritical: false
    )
]

let dataWorkflow = agent.createWorkflow(
    name: "data-processing",
    steps: dataProcessingSteps
)

// Execute the workflow
Task {
    let result = try await agent.executeWorkflow("data-processing")
    print("Processed \(result.completedTasks.count) steps")
}
```

### Listing Available Workflows

```swift
// Get all registered workflows
let workflows = agent.getAvailableWorkflows()

print("Available workflows:")
for workflow in workflows {
    print("- \(workflow.name): \(workflow.steps.count) steps")
}
```

## Natural Language Processing

### Processing Natural Language Requests

```swift
// Simple request
Task {
    let result = try await agent.processRequest("Send a message to John")
    print("Message sent: \(result.success)")
}

// Complex request
Task {
    let result = try await agent.processRequest(
        "Schedule a meeting with the team tomorrow at 2pm about the project update"
    )
    print("Meeting scheduled: \(result.success)")
}

// Multiple actions
Task {
    let result = try await agent.processRequest(
        "Check my calendar for today and send me a summary"
    )
    print("Calendar checked: \(result.success)")
}
```

### Handling NLP Results

```swift
Task {
    do {
        let result = try await agent.processRequest("Remind me to call mom at 5pm")
        
        if result.success {
            print("Reminder created successfully")
            if let taskId = result.taskId {
                print("Task ID: \(taskId)")
            }
        } else {
            print("Failed to create reminder: \(result.error ?? "Unknown error")")
        }
    } catch {
        print("Error processing request: \(error)")
    }
}
```

## iOS Integration

### Siri Integration

```swift
// Enable Siri integration
Task {
    do {
        try await agent.enableSiriIntegration()
        print("Siri integration enabled")
        
        // User can now say: "Hey Siri, run my morning routine"
    } catch {
        print("Failed to enable Siri: \(error)")
    }
}
```

### Shortcuts Integration

```swift
// Connect to an iOS Shortcut
Task {
    do {
        try await agent.integrateWithShortcut("Daily Briefing")
        print("Connected to Shortcut")
    } catch {
        print("Failed to connect: \(error)")
    }
}

// Create multiple shortcut integrations
let shortcuts = ["Morning Routine", "Evening Wrap-up", "Weekly Review"]

for shortcut in shortcuts {
    Task {
        try? await agent.integrateWithShortcut(shortcut)
    }
}
```

### Notifications

```swift
// Task with notification on completion
let task = Task(
    name: "Data Backup",
    description: "Backup user data",
    priority: .high,
    metadata: ["notify_on_complete": "true"]
)

Task {
    let result = try await agent.executeTask(task)
    if result.success {
        // Notification will be sent automatically
    }
}
```

## Advanced Features

### Execution Context

```swift
// Create execution context with custom data
let context = ExecutionContext(
    currentTask: task,
    workflow: workflow,
    userData: [
        "userId": "12345",
        "sessionId": "abc-def-ghi"
    ]
)

// Monitor resource usage
print("Memory used: \(context.resourceUsage.memoryUsed) bytes")
print("CPU used: \(context.resourceUsage.cpuUsed * 100)%")
print("Battery drain: \(context.resourceUsage.batteryDrain)%")
```

### Task Status Tracking

```swift
// Create a task
var task = Task(
    name: "Long Running Task",
    description: "Process large dataset",
    priority: .medium
)

// Update status as task progresses
task.status = .inProgress
print("Task started")

// ... perform work ...

task.status = .completed
task.completedAt = Date()
print("Task completed at: \(task.completedAt!)")
```

### Error Handling

```swift
Task {
    do {
        let result = try await agent.processRequest("Invalid request format")
        print("Success: \(result)")
    } catch TaskError.invalidStatus(let status) {
        print("Invalid task status: \(status)")
    } catch TaskError.executionFailed(let reason) {
        print("Execution failed: \(reason)")
    } catch TaskError.timeout(let duration) {
        print("Task timed out after \(duration) seconds")
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

### Batch Processing

```swift
// Process multiple tasks efficiently
let tasks = [
    Task(name: "Task 1", description: "First task", priority: .high),
    Task(name: "Task 2", description: "Second task", priority: .medium),
    Task(name: "Task 3", description: "Third task", priority: .low)
]

Task {
    for task in tasks {
        do {
            let result = try await agent.executeTask(task)
            print("\(task.name): \(result.success ? "✅" : "❌")")
        } catch {
            print("\(task.name): Error - \(error)")
        }
    }
}
```

### Parallel Execution

```swift
// Execute multiple tasks concurrently
Task {
    async let result1 = agent.processRequest("Check weather")
    async let result2 = agent.processRequest("Read news")
    async let result3 = agent.processRequest("Check calendar")
    
    let results = try await [result1, result2, result3]
    print("All tasks completed: \(results.allSatisfy { $0.success })")
}
```

### Custom Task Filtering

```swift
// Filter tasks by category
let allTasks: [Task] = loadTasks()

let communicationTasks = allTasks.filter { $0.category == .communication }
let highPriorityTasks = allTasks.filter { $0.priority == .high }
let pendingTasks = allTasks.filter { $0.status == .pending }

print("Communication tasks: \(communicationTasks.count)")
print("High priority tasks: \(highPriorityTasks.count)")
print("Pending tasks: \(pendingTasks.count)")
```

### Workflow Composition

```swift
// Compose workflows from other workflows
let dataWorkflow = agent.createWorkflow(
    name: "data-pipeline",
    steps: dataProcessingSteps
)

let notificationWorkflow = agent.createWorkflow(
    name: "notify-team",
    steps: notificationSteps
)

// Create a master workflow
let masterSteps = dataProcessingSteps + notificationSteps

let masterWorkflow = agent.createWorkflow(
    name: "full-pipeline",
    steps: masterSteps
)

// Execute the composed workflow
Task {
    try await agent.executeWorkflow("full-pipeline")
}
```

## Complete Example: Building a Daily Assistant

```swift
import NeuralGate

class DailyAssistant {
    let agent = NeuralGateAgent()
    
    func setup() async throws {
        // Enable integrations
        try await agent.enableSiriIntegration()
        try await agent.integrateWithShortcut("Daily Assistant")
        
        // Create morning routine
        createMorningRoutine()
        
        // Create evening routine
        createEveningRoutine()
        
        print("Daily assistant ready!")
    }
    
    private func createMorningRoutine() {
        let steps: [WorkflowStep] = [
            WorkflowStep(action: "checkWeather", parameters: [:], isCritical: false),
            WorkflowStep(action: "checkCalendar", parameters: [:], isCritical: true),
            WorkflowStep(action: "readNews", parameters: [:], isCritical: false),
            WorkflowStep(action: "checkEmail", parameters: [:], isCritical: true)
        ]
        
        _ = agent.createWorkflow(name: "morning-routine", steps: steps)
    }
    
    private func createEveningRoutine() {
        let steps: [WorkflowStep] = [
            WorkflowStep(action: "summarizeDay", parameters: [:], isCritical: true),
            WorkflowStep(action: "planTomorrow", parameters: [:], isCritical: true),
            WorkflowStep(action: "setReminders", parameters: [:], isCritical: false)
        ]
        
        _ = agent.createWorkflow(name: "evening-routine", steps: steps)
    }
    
    func runMorningRoutine() async throws {
        print("Starting morning routine...")
        let result = try await agent.executeWorkflow("morning-routine")
        print("Morning routine completed: \(result.success)")
    }
    
    func processUserRequest(_ request: String) async throws {
        print("Processing: \(request)")
        let result = try await agent.processRequest(request)
        print("Result: \(result.success ? "✅" : "❌")")
    }
}

// Usage
let assistant = DailyAssistant()

Task {
    try await assistant.setup()
    try await assistant.runMorningRoutine()
    try await assistant.processUserRequest("Schedule team meeting for 2pm")
}
```

## Additional Resources

- [DOCUMENTATION.md](DOCUMENTATION.md) - Comprehensive API reference
- [EXAMPLES.md](EXAMPLES.md) - More usage examples
- [BEST_PRACTICES.md](BEST_PRACTICES.md) - Development best practices
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

---

For more examples and detailed documentation, visit the [project repository](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate).
