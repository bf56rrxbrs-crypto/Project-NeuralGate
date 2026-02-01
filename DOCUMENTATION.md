# NeuralGate - AI Agent for iPhone Task Automation

NeuralGate is an AI-powered agent designed exclusively for iPhone users to automate tasks and workflows through natural language processing and iOS integration.

## Features

### 🤖 AI-Powered Task Understanding
- Natural language processing to understand user intents
- Smart task classification and parameter extraction
- Context-aware priority assignment

### 📱 iPhone-Specific Integrations
- **Siri Integration**: Voice-activated task execution
- **iOS Shortcuts**: Connect with native Shortcuts app
- **Notifications**: Local notification support for task reminders
- **Background Tasks**: Schedule tasks for automatic execution

### ⚡ Workflow Automation
- Pre-built workflows for common tasks:
  - Morning Routine (weather, calendar, news)
  - Email Digest
- Custom workflow creation
- Visual workflow builder support
- Step-by-step execution with error handling

### 📊 Task Management
- Task creation and scheduling
- Priority-based task execution
- Task history and monitoring
- Scheduled task management

## Installation

### Swift Package Manager

Add NeuralGate to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/bf56rrxbrs-crypto/Project-NeuralGate.git", from: "1.0.0")
]
```

### Manual Integration

Clone the repository and add the `Sources/NeuralGate` directory to your Xcode project.

## Quick Start

### Basic Usage

```swift
import NeuralGate

// Initialize the AI agent
let agent = NeuralGateAgent()

// Process natural language requests
Task {
    let result = try await agent.processRequest("Send a message to John")
    print("Task completed: \(result.success)")
}
```

### Using Pre-built Workflows

```swift
// Get available workflows
let workflows = agent.getAvailableWorkflows()

// Execute a workflow
Task {
    let result = try await agent.executeWorkflow("morning-routine")
    print("Workflow completed in \(result.duration) seconds")
}
```

### Creating Custom Workflows

```swift
// Define workflow steps
let steps = [
    WorkflowStep(action: "check", parameters: ["type": "weather"], isCritical: false),
    WorkflowStep(action: "send", parameters: ["type": "summary"], isCritical: true)
]

// Create the workflow
let customWorkflow = agent.createWorkflow(name: "My Custom Workflow", steps: steps)

// Execute it
Task {
    let result = try await agent.executeWorkflow(customWorkflow.id)
}
```

### Scheduling Tasks

```swift
// Create a task
let intent = Intent(
    action: "remind",
    parameters: ["message": "Team meeting"],
    priority: .high,
    originalText: "remind me about team meeting"
)

let task = try agent.taskManager.createTask(from: intent)

// Schedule for future execution
let tomorrow = Date().addingTimeInterval(86400)
try agent.scheduleTask(task, for: tomorrow)
```

### iOS Integration

#### Siri Integration

```swift
// Enable Siri support
Task {
    try await agent.enableSiriIntegration()
}
```

#### Shortcuts Integration

```swift
// Connect to iOS Shortcuts
Task {
    try await agent.integrateWithShortcut("My Shortcut Name")
}
```

## SwiftUI Interface

NeuralGate includes a ready-to-use SwiftUI interface:

```swift
import SwiftUI
import NeuralGate

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NeuralGateView()
        }
    }
}
```

## Architecture

### Core Components

1. **NeuralGateAgent**: Main entry point for the AI agent
2. **TaskManager**: Handles task lifecycle and scheduling
3. **WorkflowEngine**: Executes workflows and manages workflow library
4. **NaturalLanguageProcessor**: Processes natural language to extract intents
5. **iOSIntegration**: Manages iPhone-specific integrations

### Data Models

- **Task**: Represents a single executable task
- **Workflow**: Collection of workflow steps
- **Intent**: Parsed user intent from natural language
- **TaskResult**: Execution result with success status and output
- **WorkflowResult**: Complete workflow execution result

## Examples

### Example 1: Morning Routine Automation

```swift
let agent = NeuralGateAgent()

Task {
    // Execute pre-built morning routine
    let result = try await agent.executeWorkflow("morning-routine")
    
    // Check results
    for stepResult in result.stepResults {
        print("Step: \(stepResult.taskId), Success: \(stepResult.success)")
    }
}
```

### Example 2: Custom Email Processing

```swift
let emailWorkflow = agent.createWorkflow(
    name: "Email Processing",
    steps: [
        WorkflowStep(action: "fetch", parameters: ["type": "unread"], isCritical: true),
        WorkflowStep(action: "filter", parameters: ["importance": "high"], isCritical: false),
        WorkflowStep(action: "summarize", parameters: ["format": "brief"], isCritical: false),
        WorkflowStep(action: "notify", parameters: ["method": "push"], isCritical: false)
    ]
)

Task {
    let result = try await agent.executeWorkflow(emailWorkflow.id)
}
```

### Example 3: Voice-Activated Tasks

```swift
// Enable Siri first
try await agent.enableSiriIntegration()

// User can now say: "Hey Siri, use NeuralGate to send a message to John"
// The agent will process this automatically through Siri intents
```

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.9+

## Permissions Required

Your app needs to request these permissions:

- **Siri & Shortcuts**: For voice commands and Shortcuts integration
- **Notifications**: For task reminders and alerts
- **Background App Refresh**: For scheduled task execution

Add to your `Info.plist`:

```xml
<key>NSSiriUsageDescription</key>
<string>NeuralGate needs Siri access to process voice commands</string>

<key>NSUserNotificationsUsageDescription</key>
<string>NeuralGate sends notifications for task reminders</string>
```

## Advanced Features

### Task Priority System

Tasks are automatically assigned priorities based on natural language cues:

- **Critical**: Urgent, ASAP, immediately
- **High**: Important, priority, soon
- **Normal**: Standard tasks
- **Low**: Background tasks

### Error Handling

```swift
do {
    let result = try await agent.processRequest("complex task")
    if result.success {
        print("Success: \(result.output ?? "")")
    } else {
        print("Failed: \(result.error ?? "")")
    }
} catch {
    print("Error: \(error)")
}
```

### Workflow History

```swift
let history = agent.workflowEngine.getExecutionHistory(for: workflowId)
for execution in history {
    print("Executed at: \(execution.timestamp)")
    print("Duration: \(execution.duration)")
    print("Success: \(execution.success)")
}
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is available for use exclusively for iPhone/iOS applications.

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact the maintainers

## Roadmap

Future enhancements planned:

- [ ] Machine learning-based intent classification
- [ ] Integration with more iOS apps (Mail, Calendar, Reminders)
- [ ] Multi-language support
- [ ] Cloud sync for workflows
- [ ] Workflow marketplace
- [ ] Advanced automation triggers (location, time, app state)
- [ ] HomeKit integration
- [ ] HealthKit integration

---

**Note**: NeuralGate is designed exclusively for iPhone users and leverages iOS-specific features and frameworks.
