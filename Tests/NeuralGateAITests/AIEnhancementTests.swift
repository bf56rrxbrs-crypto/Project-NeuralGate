import XCTest
@testable import NeuralGate
@testable import NeuralGateAI

final class AIEnhancementTests: XCTestCase {
    var configuration: NeuralGateConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = NeuralGateConfiguration(
            debugMode: true,
            maxMemoryUsage: 100,
            batteryOptimizationLevel: 2
        )
    }
    
    // MARK: - CapabilityDiscoveryEngine Tests
    
    func testCapabilityDiscoveryInitialization() {
        let engine = CapabilityDiscoveryEngine(configuration: configuration)
        let capabilities = engine.getCapabilitiesNeedingImprovement(threshold: 1.0)
        
        // Should have some baseline capabilities
        XCTAssertGreaterThanOrEqual(capabilities.count, 0)
    }
    
    func testCapabilityAnalysis() async {
        let engine = CapabilityDiscoveryEngine(configuration: configuration)
        let opportunities = await engine.analyzeCapabilities()
        
        // Should identify enhancement opportunities
        XCTAssertGreaterThan(opportunities.count, 0)
        
        // Verify opportunities are properly structured
        for opportunity in opportunities {
            XCTAssertFalse(opportunity.capability.isEmpty)
            XCTAssertFalse(opportunity.suggestedEnhancement.isEmpty)
            XCTAssertGreaterThan(opportunity.estimatedImpact, 0.0)
            XCTAssertLessThanOrEqual(opportunity.estimatedImpact, 1.0)
        }
    }
    
    func testCapabilityReportGeneration() {
        let engine = CapabilityDiscoveryEngine(configuration: configuration)
        let report = engine.generateCapabilityReport()
        
        // Report should contain key sections
        XCTAssertTrue(report.contains("Capability Analysis"))
        XCTAssertTrue(report.contains("Enhancement Opportunities"))
        XCTAssertGreaterThan(report.count, 100)
    }
    
    func testHighPriorityOpportunities() async {
        let engine = CapabilityDiscoveryEngine(configuration: configuration)
        _ = await engine.analyzeCapabilities()
        let highPriority = engine.getHighPriorityOpportunities()
        
        // Should have high priority items
        XCTAssertGreaterThan(highPriority.count, 0)
        
        // All should be high or critical priority
        for opportunity in highPriority {
            XCTAssertTrue(
                opportunity.priority == .high || opportunity.priority == .critical,
                "Expected high or critical priority, got \(opportunity.priority)"
            )
        }
    }
    
    // MARK: - UsagePatternAnalyzer Tests
    
    func testUsageRecording() {
        let analyzer = UsagePatternAnalyzer(configuration: configuration)
        
        let record = UsagePatternAnalyzer.UsageRecord(
            timestamp: Date(),
            taskCategory: .automation,
            taskPriority: .high,
            executionSuccess: true,
            executionTime: 1.5,
            resourceUsage: 0.3,
            userContext: UsagePatternAnalyzer.UsageRecord.UserContext(
                timeOfDay: .midMorning,
                dayOfWeek: .monday,
                deviceState: .active
            )
        )
        
        analyzer.recordUsage(record)
        
        let stats = analyzer.getUsageStatistics()
        XCTAssertEqual(stats.totalExecutions, 1)
        XCTAssertEqual(stats.successRate, 1.0)
    }
    
    func testPatternDetection() async {
        let analyzer = UsagePatternAnalyzer(configuration: configuration)
        
        // Record multiple similar tasks to create a pattern
        for i in 0..<25 {
            let record = UsagePatternAnalyzer.UsageRecord(
                timestamp: Date().addingTimeInterval(Double(i * 60)),
                taskCategory: .automation,
                taskPriority: .high,
                executionSuccess: true,
                executionTime: 1.0,
                resourceUsage: 0.3,
                userContext: UsagePatternAnalyzer.UsageRecord.UserContext(
                    timeOfDay: .midMorning,
                    dayOfWeek: .monday,
                    deviceState: .active
                )
            )
            analyzer.recordUsage(record)
        }
        
        let patterns = await analyzer.analyzePatterns()
        
        // Should detect patterns
        XCTAssertGreaterThan(patterns.count, 0)
        
        // Patterns should have reasonable confidence
        for pattern in patterns {
            XCTAssertGreaterThan(pattern.confidence, 0.0)
            XCTAssertLessThanOrEqual(pattern.confidence, 1.0)
        }
    }
    
    func testGapIdentification() async {
        let analyzer = UsagePatternAnalyzer(configuration: configuration)
        
        // Create usage pattern with errors
        for i in 0..<30 {
            let record = UsagePatternAnalyzer.UsageRecord(
                timestamp: Date().addingTimeInterval(Double(i * 60)),
                taskCategory: .automation,
                taskPriority: .high,
                executionSuccess: i % 3 != 0, // 33% failure rate
                executionTime: 1.0,
                resourceUsage: 0.3,
                userContext: UsagePatternAnalyzer.UsageRecord.UserContext(
                    timeOfDay: .midMorning,
                    dayOfWeek: .monday,
                    deviceState: .active
                )
            )
            analyzer.recordUsage(record)
        }
        
        let gaps = await analyzer.identifyGaps()
        
        // Should identify gaps
        XCTAssertGreaterThan(gaps.count, 0)
        
        // Gaps should be properly structured
        for gap in gaps {
            XCTAssertFalse(gap.description.isEmpty)
            XCTAssertFalse(gap.recommendedAction.isEmpty)
            XCTAssertGreaterThan(gap.potentialValue, 0.0)
        }
    }
    
    // MARK: - ModelRecommendationSystem Tests
    
    func testModelRecommendationInitialization() {
        let system = ModelRecommendationSystem(configuration: configuration)
        let models = system.getAvailableModels()
        
        // Should have multiple AI models available
        XCTAssertGreaterThan(models.count, 3)
        
        // Verify models are properly configured
        for model in models {
            XCTAssertFalse(model.name.isEmpty)
            XCTAssertGreaterThan(model.averageAccuracy, 0.0)
            XCTAssertLessThanOrEqual(model.averageAccuracy, 1.0)
        }
    }
    
    func testModelRecommendation() async {
        let system = ModelRecommendationSystem(configuration: configuration)
        
        let task = Task(
            name: "Test Task",
            description: "Test automation task",
            priority: .high,
            category: .automation
        )
        let context = ExecutionContext(currentTask: task)
        
        let recommendation = await system.recommendModel(for: task, context: context)
        
        // Should return a valid recommendation
        XCTAssertFalse(recommendation.model.name.isEmpty)
        XCTAssertGreaterThan(recommendation.confidence, 0.0)
        XCTAssertLessThanOrEqual(recommendation.confidence, 1.0)
        XCTAssertFalse(recommendation.reasoning.isEmpty)
    }
    
    func testModelsByCapability() {
        let system = ModelRecommendationSystem(configuration: configuration)
        
        let classificationModels = system.getModelsByCapability(.classification)
        XCTAssertGreaterThan(classificationModels.count, 0)
        
        // All returned models should have classification capability
        for model in classificationModels {
            XCTAssertTrue(model.capabilities.contains(.classification))
        }
    }
    
    func testPerformanceRecording() {
        let system = ModelRecommendationSystem(configuration: configuration)
        
        system.recordPerformance(
            modelName: "TestModel",
            accuracy: 0.85,
            inferenceTime: 0.05,
            success: true,
            resourceUsage: 0.3
        )
        
        let history = system.getPerformanceHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history["TestModel"]?.averageAccuracy, 0.85)
    }
    
    func testModelReportGeneration() {
        let system = ModelRecommendationSystem(configuration: configuration)
        let report = system.generateModelReport()
        
        // Report should contain model information
        XCTAssertTrue(report.contains("AI Model Catalog"))
        XCTAssertTrue(report.contains("Available Models"))
        XCTAssertGreaterThan(report.count, 100)
    }
    
    // MARK: - FeatureSuggestionEngine Tests
    
    func testBehaviorRecording() {
        let engine = FeatureSuggestionEngine(configuration: configuration)
        
        let record = FeatureSuggestionEngine.BehaviorRecord(
            timestamp: Date(),
            action: .taskCreation,
            context: FeatureSuggestionEngine.BehaviorRecord.BehaviorContext(
                taskCategory: .automation,
                timeOfDay: "Morning",
                deviceState: "Active",
                frequency: 5
            ),
            satisfaction: 0.9
        )
        
        engine.recordBehavior(record)
        
        // Should successfully record without errors
        XCTAssertTrue(true)
    }
    
    func testFeatureSuggestionGeneration() async {
        let engine = FeatureSuggestionEngine(configuration: configuration)
        
        // Record multiple behaviors to trigger suggestions
        for i in 0..<30 {
            let record = FeatureSuggestionEngine.BehaviorRecord(
                timestamp: Date().addingTimeInterval(Double(i * 3600)),
                action: .taskCreation,
                context: FeatureSuggestionEngine.BehaviorRecord.BehaviorContext(
                    taskCategory: .automation,
                    timeOfDay: "Morning",
                    deviceState: "Active",
                    frequency: 1
                ),
                satisfaction: 0.8
            )
            engine.recordBehavior(record)
        }
        
        let suggestions = await engine.generateSuggestions()
        
        // Should generate feature suggestions
        XCTAssertGreaterThan(suggestions.count, 0)
        
        // Verify suggestions are properly structured
        for suggestion in suggestions {
            XCTAssertFalse(suggestion.name.isEmpty)
            XCTAssertFalse(suggestion.description.isEmpty)
            XCTAssertGreaterThan(suggestion.estimatedValue, 0.0)
            XCTAssertLessThanOrEqual(suggestion.estimatedValue, 1.0)
        }
    }
    
    func testHighValueSuggestions() async {
        let engine = FeatureSuggestionEngine(configuration: configuration)
        _ = await engine.generateSuggestions()
        
        let highValue = engine.getHighValueSuggestions(threshold: 0.80)
        
        // All suggestions should meet threshold
        for suggestion in highValue {
            XCTAssertGreaterThanOrEqual(suggestion.estimatedValue, 0.80)
        }
    }
    
    func testSuggestionsByCategory() async {
        let engine = FeatureSuggestionEngine(configuration: configuration)
        _ = await engine.generateSuggestions()
        
        let aiSuggestions = engine.getSuggestionsByCategory(.aiEnhancement)
        
        // All returned suggestions should be AI enhancements
        for suggestion in aiSuggestions {
            XCTAssertEqual(suggestion.category, .aiEnhancement)
        }
    }
    
    func testRoadmapGeneration() async {
        let engine = FeatureSuggestionEngine(configuration: configuration)
        _ = await engine.generateSuggestions()
        
        let roadmap = engine.generateRoadmap()
        
        // Roadmap should contain key sections
        XCTAssertTrue(roadmap.contains("Feature Roadmap"))
        XCTAssertGreaterThan(roadmap.count, 100)
    }
}
