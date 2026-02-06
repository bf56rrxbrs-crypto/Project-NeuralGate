// TaskPrioritizationEngineTests.swift
// NeuralGateAI Tests - Task Prioritization Tests

import XCTest
@testable import NeuralGateAI

final class TaskPrioritizationEngineTests: XCTestCase {
    
    var engine: TaskPrioritizationEngine!
    
    override func setUp() async throws {
        try await super.setUp()
        engine = TaskPrioritizationEngine()
    }
    
    override func tearDown() async throws {
        engine = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Prioritization Tests
    
    func testSimpleTaskPrioritization() async throws {
        let task1 = PrioritizedTask(
            name: "Low Priority Task",
            description: "Non-urgent task",
            parameters: PrioritizationParameters(
                importance: .low,
                urgency: .low
            )
        )
        
        let task2 = PrioritizedTask(
            name: "High Priority Task",
            description: "Urgent and important",
            parameters: PrioritizationParameters(
                importance: .high,
                urgency: .high
            )
        )
        
        let result = await engine.prioritizeTasks([task1, task2])
        
        XCTAssertEqual(result.tasks.count, 2)
        // High priority task should be first
        XCTAssertEqual(result.tasks[0].name, "High Priority Task")
        XCTAssertGreaterThan(result.tasks[0].priorityScore, result.tasks[1].priorityScore)
    }
    
    func testDeadlineBasedPrioritization() async throws {
        let now = Date()
        
        let urgentTask = PrioritizedTask(
            name: "Due in 30 Minutes",
            description: "Imminent deadline",
            parameters: PrioritizationParameters(
                deadline: now.addingTimeInterval(1800),  // 30 minutes
                importance: .medium
            )
        )
        
        let futureTask = PrioritizedTask(
            name: "Due Next Week",
            description: "Future deadline",
            parameters: PrioritizationParameters(
                deadline: now.addingTimeInterval(604800),  // 7 days
                importance: .high
            )
        )
        
        let result = await engine.prioritizeTasks([futureTask, urgentTask])
        
        // Imminent deadline should be prioritized over future task
        XCTAssertEqual(result.tasks[0].name, "Due in 30 Minutes")
        XCTAssertGreaterThan(result.tasks[0].priorityScore, result.tasks[1].priorityScore)
        
        // Should have warning about imminent deadline
        XCTAssertFalse(result.warnings.isEmpty)
        XCTAssertTrue(result.warnings[0].contains("imminent"))
    }
    
    func testOverdueTaskPrioritization() async throws {
        let overdueTask = PrioritizedTask(
            name: "Overdue Task",
            description: "Past deadline",
            parameters: PrioritizationParameters(
                deadline: Date().addingTimeInterval(-3600),  // 1 hour ago
                importance: .medium
            )
        )
        
        let normalTask = PrioritizedTask(
            name: "Normal Task",
            description: "Future deadline",
            parameters: PrioritizationParameters(
                deadline: Date().addingTimeInterval(86400),  // Tomorrow
                importance: .high
            )
        )
        
        let result = await engine.prioritizeTasks([normalTask, overdueTask])
        
        // Overdue task should have very high priority
        XCTAssertEqual(result.tasks[0].name, "Overdue Task")
        XCTAssertTrue(result.warnings.contains { $0.contains("overdue") })
    }
    
    // MARK: - Complexity Tests
    
    func testComplexityConsideration() async throws {
        let simpleTask = PrioritizedTask(
            name: "Simple Task",
            description: "Easy to complete",
            parameters: PrioritizationParameters(
                complexity: .trivial,
                importance: .medium,
                estimatedDuration: 300
            )
        )
        
        let complexTask = PrioritizedTask(
            name: "Complex Task",
            description: "Difficult to complete",
            parameters: PrioritizationParameters(
                complexity: .veryHigh,
                importance: .medium,
                estimatedDuration: 7200
            )
        )
        
        let result = await engine.prioritizeTasks([complexTask, simpleTask])
        
        // With same importance, simpler task should be prioritized (quick wins)
        XCTAssertEqual(result.tasks[0].name, "Simple Task")
    }
    
    // MARK: - Dependency Tests
    
    func testTaskDependencies() async throws {
        let taskA = PrioritizedTask(
            name: "Task A (Independent)",
            description: "No dependencies",
            parameters: PrioritizationParameters(
                importance: .medium,
                dependencies: []
            )
        )
        
        let taskB = PrioritizedTask(
            name: "Task B (Depends on A)",
            description: "Has dependencies",
            parameters: PrioritizationParameters(
                importance: .medium,
                dependencies: [taskA.id]
            )
        )
        
        let result = await engine.prioritizeTasks([taskB, taskA])
        
        // Task without dependencies should be prioritized
        XCTAssertEqual(result.tasks[0].name, "Task A (Independent)")
        
        // Check dependency chain
        let chain = await engine.getDependencyChain(for: taskB.id)
        XCTAssertTrue(chain.contains(taskA.id))
    }
    
    func testScheduleRespectsDependencies() async throws {
        let task1 = PrioritizedTask(
            id: UUID(),
            name: "Task 1",
            description: "First task",
            parameters: PrioritizationParameters(
                estimatedDuration: 1800,
                dependencies: []
            )
        )
        
        let task2 = PrioritizedTask(
            id: UUID(),
            name: "Task 2",
            description: "Depends on Task 1",
            parameters: PrioritizationParameters(
                estimatedDuration: 1800,
                dependencies: [task1.id]
            )
        )
        
        let result = await engine.prioritizeTasks([task2, task1])
        
        // Task 2 should be scheduled after Task 1
        if let time1 = result.suggestedSchedule[task1.id],
           let time2 = result.suggestedSchedule[task2.id] {
            XCTAssertTrue(time2 > time1)
        } else {
            XCTFail("Schedule not generated")
        }
    }
    
    // MARK: - Resource Tests
    
    func testResourceAwarePrioritization() async throws {
        let cpuIntensiveTask = PrioritizedTask(
            name: "CPU Intensive Task",
            description: "Requires high CPU",
            parameters: PrioritizationParameters(
                importance: .medium,
                resourceRequirements: .init(
                    cpuIntensive: true,
                    batteryImpact: 0.8
                )
            )
        )
        
        let lightTask = PrioritizedTask(
            name: "Light Task",
            description: "Low resource usage",
            parameters: PrioritizationParameters(
                importance: .medium,
                resourceRequirements: .init(
                    cpuIntensive: false,
                    batteryImpact: 0.1
                )
            )
        )
        
        // Test with low battery
        let lowBatteryContext = EnvironmentContext(batteryLevel: 0.15)
        let result = await engine.prioritizeTasks(
            [cpuIntensiveTask, lightTask],
            context: lowBatteryContext
        )
        
        // Light task should be prioritized on low battery
        XCTAssertEqual(result.tasks[0].name, "Light Task")
    }
    
    func testNetworkAwarePrioritization() async throws {
        let networkTask = PrioritizedTask(
            name: "Network Task",
            description: "Requires internet",
            parameters: PrioritizationParameters(
                importance: .high,
                resourceRequirements: .init(networkRequired: true)
            )
        )
        
        let offlineTask = PrioritizedTask(
            name: "Offline Task",
            description: "Works offline",
            parameters: PrioritizationParameters(
                importance: .medium,
                resourceRequirements: .init(networkRequired: false)
            )
        )
        
        // Test when offline
        let offlineContext = EnvironmentContext(isOnline: false)
        let result = await engine.prioritizeTasks(
            [networkTask, offlineTask],
            context: offlineContext
        )
        
        // Offline task should be prioritized when no network
        XCTAssertEqual(result.tasks[0].name, "Offline Task")
    }
    
    // MARK: - Adaptive Learning Tests
    
    func testCompletionRecording() async throws {
        let task = PrioritizedTask(
            name: "Test Task",
            description: "For completion tracking",
            parameters: PrioritizationParameters()
        )
        
        let result = await engine.prioritizeTasks([task])
        let taskId = result.tasks[0].id
        
        await engine.recordCompletion(taskId: taskId, success: true, actualDuration: 1800)
        
        let stats = await engine.getStatistics()
        XCTAssertEqual(stats["totalTasks"] as? Int, 1)
        XCTAssertEqual(stats["completedTasks"] as? Int, 1)
    }
    
    func testStatisticsTracking() async throws {
        // Create and prioritize multiple tasks
        let tasks = (1...5).map { i in
            PrioritizedTask(
                name: "Task \(i)",
                description: "Task \(i)",
                parameters: PrioritizationParameters()
            )
        }
        
        _ = await engine.prioritizeTasks(tasks)
        
        let stats = await engine.getStatistics()
        XCTAssertEqual(stats["totalTasks"] as? Int, 5)
        
        // Check weights are present
        if let weights = stats["currentWeights"] as? [String: Double] {
            XCTAssertNotNil(weights["deadline"])
            XCTAssertNotNil(weights["importance"])
            XCTAssertNotNil(weights["urgency"])
        } else {
            XCTFail("Weights not found in statistics")
        }
    }
    
    // MARK: - Ranking Tests
    
    func testTaskRanking() async throws {
        let tasks = (1...5).map { i in
            PrioritizedTask(
                name: "Task \(i)",
                description: "Task \(i)",
                parameters: PrioritizationParameters(
                    importance: i % 2 == 0 ? .high : .low
                )
            )
        }
        
        let result = await engine.prioritizeTasks(tasks)
        
        // All tasks should have ranks
        for task in result.tasks {
            XCTAssertNotNil(task.rank)
        }
        
        // Ranks should be sequential from 1
        let ranks = result.tasks.compactMap { $0.rank }.sorted()
        XCTAssertEqual(ranks, [1, 2, 3, 4, 5])
    }
    
    // MARK: - Reasoning Tests
    
    func testReasoningExplanations() async throws {
        let task = PrioritizedTask(
            name: "Test Task",
            description: "For reasoning test",
            parameters: PrioritizationParameters(
                deadline: Date().addingTimeInterval(3600),
                complexity: .medium,
                importance: .high
            )
        )
        
        let result = await engine.prioritizeTasks([task])
        
        // Should have reasoning for the task
        XCTAssertFalse(result.reasoning.isEmpty)
        XCTAssertNotNil(result.reasoning[task.id])
        
        if let reasoning = result.reasoning[task.id] {
            XCTAssertTrue(reasoning.contains("Priority"))
            XCTAssertFalse(reasoning.isEmpty)
        }
    }
    
    // MARK: - Integration Tests
    
    func testComplexScenario() async throws {
        let now = Date()
        
        let tasks = [
            PrioritizedTask(
                name: "Critical Bug Fix",
                description: "Production issue",
                parameters: PrioritizationParameters(
                    deadline: now.addingTimeInterval(1800),  // 30 min
                    complexity: .high,
                    importance: .critical,
                    urgency: .immediate
                )
            ),
            PrioritizedTask(
                name: "Quick Win",
                description: "Easy task",
                parameters: PrioritizationParameters(
                    complexity: .trivial,
                    estimatedDuration: 300,
                    importance: .medium
                )
            ),
            PrioritizedTask(
                name: "Long-term Project",
                description: "Important but not urgent",
                parameters: PrioritizationParameters(
                    deadline: now.addingTimeInterval(2592000),  // 30 days
                    complexity: .veryHigh,
                    estimatedDuration: 28800,  // 8 hours
                    importance: .high,
                    urgency: .low
                )
            )
        ]
        
        let result = await engine.prioritizeTasks(tasks)
        
        // Critical bug should be first
        XCTAssertEqual(result.tasks[0].name, "Critical Bug Fix")
        
        // Should have warnings
        XCTAssertFalse(result.warnings.isEmpty)
        
        // Should have schedule
        XCTAssertEqual(result.suggestedSchedule.count, 3)
        
        // Total score should be positive
        XCTAssertGreaterThan(result.totalScore, 0)
    }
}
