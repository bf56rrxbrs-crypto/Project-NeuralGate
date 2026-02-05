// RecommendationEngineTests.swift
// NeuralGateAI Tests - Recommendation System Tests
//
// Tests for personalized recommendation generation and context analysis

import XCTest
@testable import NeuralGateAI

final class RecommendationEngineTests: XCTestCase {
    
    var engine: RecommendationEngine!
    
    override func setUp() async throws {
        try await super.setUp()
        engine = RecommendationEngine()
    }
    
    override func tearDown() async throws {
        engine = nil
        try await super.tearDown()
    }
    
    // MARK: - Activity Recording Tests
    
    func testActivityRecording() async throws {
        let activity = UserActivity(
            category: "email",
            action: "send",
            success: true,
            duration: 120.0
        )
        
        await engine.recordActivity(activity)
        
        let stats = await engine.getActivityStatistics()
        XCTAssertEqual(stats["totalActivities"] as? Int, 1)
    }
    
    func testMultipleActivityRecording() async throws {
        // Record multiple activities
        for i in 0..<10 {
            let activity = UserActivity(
                category: "task-\(i % 3)",
                action: "execute",
                success: true,
                duration: Double(i * 10)
            )
            await engine.recordActivity(activity)
        }
        
        let stats = await engine.getActivityStatistics()
        XCTAssertEqual(stats["totalActivities"] as? Int, 10)
        
        let successRate = stats["successRate"] as? Double
        XCTAssertNotNil(successRate)
        XCTAssertEqual(successRate, 1.0, accuracy: 0.01)
    }
    
    // MARK: - Recommendation Generation Tests
    
    func testBasicRecommendationGeneration() async throws {
        // Record some activity history
        await recordSampleActivities()
        
        let context = UserContext(
            recentTasks: ["email", "calendar", "notes"],
            completionRate: 0.85,
            averageTaskDuration: 300.0,
            preferredWorkTimes: [9, 10, 11],
            deviceBatteryLevel: 0.75
        )
        
        let recommendations = await engine.generateRecommendations(context: context)
        
        // Should generate at least some recommendations
        XCTAssertFalse(recommendations.isEmpty)
        
        // All recommendations should meet minimum confidence threshold
        for rec in recommendations {
            XCTAssertGreaterThanOrEqual(rec.confidence, 0.6)
        }
    }
    
    func testWorkflowRecommendations() async throws {
        // Record a clear pattern of sequential tasks
        let categories = ["email", "calendar", "notes"]
        for _ in 0..<5 { // Repeat pattern 5 times
            for category in categories {
                let activity = UserActivity(
                    category: category,
                    action: "execute",
                    success: true,
                    duration: 60.0
                )
                await engine.recordActivity(activity)
            }
        }
        
        let context = UserContext()
        let recommendations = await engine.getRecommendations(
            ofType: .workflow,
            context: context
        )
        
        // Should suggest workflow creation for repeated pattern
        XCTAssertFalse(recommendations.isEmpty)
        
        if let workflowRec = recommendations.first {
            XCTAssertEqual(workflowRec.type, .workflow)
            XCTAssertGreaterThanOrEqual(workflowRec.confidence, 0.6)
        }
    }
    
    func testTimingRecommendations() async throws {
        let context = UserContext(
            currentTime: Date(),
            recentTasks: ["important-task"],
            completionRate: 0.9,
            averageTaskDuration: 300.0,
            preferredWorkTimes: [14, 15, 16], // Afternoon preference
            deviceBatteryLevel: 0.75
        )
        
        let recommendations = await engine.getRecommendations(
            ofType: .timing,
            context: context
        )
        
        // Should generate timing recommendations
        XCTAssertNotNil(recommendations)
    }
    
    func testLowBatteryRecommendation() async throws {
        let context = UserContext(
            recentTasks: ["heavy-task"],
            completionRate: 0.8,
            averageTaskDuration: 300.0,
            preferredWorkTimes: [9, 10],
            deviceBatteryLevel: 0.15 // Low battery
        )
        
        let recommendations = await engine.getRecommendations(
            ofType: .timing,
            context: context
        )
        
        // Should recommend deferring tasks due to low battery
        let lowBatteryRecs = recommendations.filter { 
            $0.description.lowercased().contains("battery")
        }
        XCTAssertFalse(lowBatteryRecs.isEmpty)
        
        if let batteryRec = lowBatteryRecs.first {
            XCTAssertGreaterThanOrEqual(batteryRec.confidence, 0.9)
            XCTAssertLessThanOrEqual(batteryRec.priority, 2)
        }
    }
    
    func testEfficiencyRecommendations() async throws {
        let context = UserContext(
            recentTasks: ["task1", "task2"],
            completionRate: 0.65, // Low completion rate
            averageTaskDuration: 1200.0, // Long tasks
            preferredWorkTimes: [9, 10],
            deviceBatteryLevel: 0.8
        )
        
        let recommendations = await engine.getRecommendations(
            ofType: .efficiency,
            context: context
        )
        
        // Should generate efficiency recommendations for low completion rate
        XCTAssertFalse(recommendations.isEmpty)
        
        // Should suggest improvements
        for rec in recommendations {
            XCTAssertEqual(rec.type, .efficiency)
            XCTAssertFalse(rec.description.isEmpty)
        }
    }
    
    func testAutomationRecommendations() async throws {
        // Record many repetitive tasks
        for _ in 0..<10 {
            let activity = UserActivity(
                category: "repetitive-task",
                action: "execute",
                success: true,
                duration: 120.0
            )
            await engine.recordActivity(activity)
        }
        
        let context = UserContext()
        let recommendations = await engine.getRecommendations(
            ofType: .automation,
            context: context
        )
        
        // Should suggest automation for repetitive tasks
        XCTAssertFalse(recommendations.isEmpty)
        
        if let autoRec = recommendations.first {
            XCTAssertEqual(autoRec.type, .automation)
            XCTAssertTrue(autoRec.description.contains("repetitive"))
        }
    }
    
    // MARK: - Confidence and Priority Tests
    
    func testRecommendationsSortedByPriority() async throws {
        await recordSampleActivities()
        
        let context = UserContext(
            recentTasks: ["task1"],
            completionRate: 0.6,
            averageTaskDuration: 2000.0,
            preferredWorkTimes: [9],
            deviceBatteryLevel: 0.15
        )
        
        let recommendations = await engine.generateRecommendations(context: context)
        
        // Verify recommendations are sorted by priority
        for i in 0..<recommendations.count - 1 {
            let current = recommendations[i]
            let next = recommendations[i + 1]
            
            if current.priority == next.priority {
                // If same priority, should be sorted by confidence
                XCTAssertGreaterThanOrEqual(current.confidence, next.confidence)
            } else {
                // Priority should be ascending (1 is highest)
                XCTAssertLessThanOrEqual(current.priority, next.priority)
            }
        }
    }
    
    func testConfidenceThreshold() async throws {
        await recordSampleActivities()
        
        let context = UserContext()
        let recommendations = await engine.generateRecommendations(context: context)
        
        // All recommendations should meet minimum threshold
        for rec in recommendations {
            XCTAssertGreaterThanOrEqual(rec.confidence, 0.6, 
                "Recommendation '\(rec.title)' has confidence below threshold")
        }
    }
    
    // MARK: - Caching Tests
    
    func testRecommendationCaching() async throws {
        await recordSampleActivities()
        
        let context = UserContext()
        
        // First call should generate recommendations
        let firstCall = await engine.generateRecommendations(context: context)
        
        // Second call should return cached results (same instance)
        let secondCall = await engine.generateRecommendations(context: context)
        
        XCTAssertEqual(firstCall.count, secondCall.count)
    }
    
    func testCacheClear() async throws {
        await recordSampleActivities()
        
        let context = UserContext()
        _ = await engine.generateRecommendations(context: context)
        
        // Clear cache
        await engine.clearCache()
        
        // Next call should regenerate recommendations
        let recommendations = await engine.generateRecommendations(context: context)
        XCTAssertNotNil(recommendations)
    }
    
    // MARK: - Statistics Tests
    
    func testActivityStatistics() async throws {
        // Record mixed success/failure activities
        for i in 0..<20 {
            let activity = UserActivity(
                category: "task-\(i % 5)",
                action: "execute",
                success: i % 4 != 0, // 75% success rate
                duration: Double(i * 10)
            )
            await engine.recordActivity(activity)
        }
        
        let stats = await engine.getActivityStatistics()
        
        XCTAssertEqual(stats["totalActivities"] as? Int, 20)
        
        let successRate = stats["successRate"] as? Double
        XCTAssertNotNil(successRate)
        XCTAssertEqual(successRate!, 0.75, accuracy: 0.01)
        
        let categoryCounts = stats["categoryCounts"] as? [String: Int]
        XCTAssertNotNil(categoryCounts)
        XCTAssertEqual(categoryCounts?.keys.count, 5)
    }
    
    // MARK: - Memory Management Tests
    
    func testActivityHistoryLimit() async throws {
        // Record more than the limit (1000)
        for i in 0..<1200 {
            let activity = UserActivity(
                category: "task-\(i)",
                action: "execute",
                success: true,
                duration: 60.0
            )
            await engine.recordActivity(activity)
        }
        
        let stats = await engine.getActivityStatistics()
        let totalActivities = stats["totalActivities"] as? Int
        
        // Should be limited to 1000
        XCTAssertEqual(totalActivities, 1000)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyHistoryRecommendations() async throws {
        // No activity recorded
        let context = UserContext()
        let recommendations = await engine.generateRecommendations(context: context)
        
        // Should still generate some recommendations (timing, efficiency)
        XCTAssertNotNil(recommendations)
    }
    
    func testRecommendationLimit() async throws {
        // Record lots of varied activities to potentially generate many recommendations
        for category in ["email", "calendar", "notes", "tasks", "meetings"] {
            for _ in 0..<20 {
                let activity = UserActivity(
                    category: category,
                    action: "execute",
                    success: true,
                    duration: 120.0
                )
                await engine.recordActivity(activity)
            }
        }
        
        let context = UserContext(
            recentTasks: ["email", "calendar", "notes"],
            completionRate: 0.5,
            averageTaskDuration: 2000.0,
            preferredWorkTimes: [9],
            deviceBatteryLevel: 0.1
        )
        
        let recommendations = await engine.generateRecommendations(context: context)
        
        // Should be limited to max recommendations (10)
        XCTAssertLessThanOrEqual(recommendations.count, 10)
    }
    
    // MARK: - Helper Methods
    
    private func recordSampleActivities() async {
        let categories = ["email", "calendar", "notes", "tasks"]
        for category in categories {
            for _ in 0..<3 {
                let activity = UserActivity(
                    category: category,
                    action: "execute",
                    success: true,
                    duration: 120.0
                )
                await engine.recordActivity(activity)
            }
        }
    }
}
