import NeuralGate
import Foundation

/// Example demonstrating basic NeuralGate usage
@available(iOS 16.0, *)
class BasicExample {
    
    let agent = NeuralGateAgent()
    
    func runExample() async {
        print("=== NeuralGate Basic Example ===\n")
        
        // Example 1: Process natural language request
        await processNaturalLanguageRequest()
        
        // Example 2: Execute pre-built workflow
        await executePrebuiltWorkflow()
        
        // Example 3: Create and execute custom workflow
        await createCustomWorkflow()
        
        // Example 4: Schedule a task
        await scheduleTask()
    }
    
    // MARK: - Example 1: Natural Language Processing
    
    func processNaturalLanguageRequest() async {
        print("Example 1: Processing natural language request")
        
        do {
            let result = try await agent.processRequest("Send an important message to John")
            
            print("✅ Task processed successfully")
            print("   Task ID: \(result.taskId)")
            print("   Success: \(result.success)")
            print("   Duration: \(String(format: "%.2f", result.duration))s")
            
            if let output = result.output {
                print("   Output: \(output)")
            }
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("\n")
    }
    
    // MARK: - Example 2: Pre-built Workflows
    
    func executePrebuiltWorkflow() async {
        print("Example 2: Executing pre-built workflow")
        
        // List available workflows
        let workflows = agent.getAvailableWorkflows()
        print("Available workflows:")
        for workflow in workflows {
            print("  - \(workflow.name) (\(workflow.steps.count) steps)")
        }
        
        // Execute morning routine
        do {
            let result = try await agent.executeWorkflow("morning-routine")
            
            print("\n✅ Workflow '\(result.workflowName)' completed")
            print("   Total duration: \(String(format: "%.2f", result.duration))s")
            print("   Steps executed: \(result.stepResults.count)")
            
            for (index, stepResult) in result.stepResults.enumerated() {
                let status = stepResult.success ? "✓" : "✗"
                print("   \(status) Step \(index + 1): \(stepResult.success ? "Success" : "Failed")")
            }
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("\n")
    }
    
    // MARK: - Example 3: Custom Workflows
    
    func createCustomWorkflow() async {
        print("Example 3: Creating custom workflow")
        
        // Define custom workflow steps
        let steps = [
            WorkflowStep(
                action: "check",
                parameters: ["type": "weather", "location": "current"],
                isCritical: false
            ),
            WorkflowStep(
                action: "check",
                parameters: ["type": "calendar", "range": "today"],
                isCritical: true
            ),
            WorkflowStep(
                action: "send",
                parameters: ["type": "summary", "recipient": "self"],
                isCritical: false
            )
        ]
        
        // Create workflow
        let customWorkflow = agent.createWorkflow(
            name: "My Custom Morning Brief",
            steps: steps
        )
        
        print("Created workflow: \(customWorkflow.name)")
        print("Workflow ID: \(customWorkflow.id)")
        print("Number of steps: \(customWorkflow.steps.count)")
        
        // Execute the custom workflow
        do {
            let result = try await agent.executeWorkflow(customWorkflow.id)
            print("\n✅ Custom workflow completed successfully")
            print("   Duration: \(String(format: "%.2f", result.duration))s")
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("\n")
    }
    
    // MARK: - Example 4: Task Scheduling
    
    func scheduleTask() async {
        print("Example 4: Scheduling a task")
        
        do {
            // Create a task
            let intent = Intent(
                action: "remind",
                parameters: [
                    "message": "Team standup meeting",
                    "time": "9:00 AM"
                ],
                priority: .high,
                originalText: "Remind me about team standup at 9 AM"
            )
            
            let task = try agent.taskManager.createTask(from: intent)
            
            // Schedule for tomorrow at 9 AM
            let tomorrow = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Date()
            )!
            
            try agent.scheduleTask(task, for: tomorrow)
            
            print("✅ Task scheduled successfully")
            print("   Task ID: \(task.id)")
            print("   Type: \(task.type)")
            print("   Priority: \(task.priority.rawValue)")
            print("   Scheduled for: \(tomorrow.formatted())")
            
            // Show all scheduled tasks
            let scheduledTasks = agent.taskManager.getScheduledTasks()
            print("\nTotal scheduled tasks: \(scheduledTasks.count)")
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("\n")
    }
}
