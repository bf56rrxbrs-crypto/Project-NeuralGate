import XCTest
@testable import NeuralGate
@testable import NeuralGateLearning

final class GeneticAlgorithmTests: XCTestCase {
    var engine: SelfImprovementEngine!
    var config: NeuralGateConfiguration!
    
    override func setUp() async throws {
        config = NeuralGateConfiguration(
            debugMode: false,
            maxMemoryUsage: 100,
            batteryOptimizationLevel: 2,
            enablePredictiveAnalytics: true,
            enableExplainability: true
        )
        engine = SelfImprovementEngine(configuration: config)
    }
    
    func testGeneticPopulationInitialization() async throws {
        // Test that genetic population is initialized
        let best = engine.getBestChromosome()
        XCTAssertNotNil(best, "Best chromosome should exist after initialization")
        
        if let chromosome = best {
            XCTAssertGreaterThanOrEqual(chromosome.learningRate, 0.001)
            XCTAssertLessThanOrEqual(chromosome.learningRate, 0.1)
            XCTAssertGreaterThanOrEqual(chromosome.confidenceThreshold, 0.6)
            XCTAssertLessThanOrEqual(chromosome.confidenceThreshold, 0.95)
            XCTAssertGreaterThanOrEqual(chromosome.cacheSize, 50)
            XCTAssertLessThanOrEqual(chromosome.cacheSize, 200)
        }
    }
    
    func testEvolutionImprovesFitness() async throws {
        // Run evolution several times
        var previousFitness: Double = 0
        
        for generation in 0..<3 {
            // Add some simulated successful tasks to improve metrics
            for i in 0..<10 {
                let taskResult = TaskResult(
                    taskId: UUID(),
                    wasSuccessful: true,
                    executionTime: Double.random(in: 1.0...3.0),
                    memoryUsed: Int.random(in: 10...50),
                    userRating: Double.random(in: 3.5...5.0)
                )
                engine.updateMetrics(taskResult: taskResult)
            }
            
            let result = await engine.evolvePopulation()
            
            XCTAssertGreaterThan(result.generation, 0)
            XCTAssertGreaterThanOrEqual(result.bestFitness, 0.0)
            XCTAssertLessThanOrEqual(result.bestFitness, 1.0)
            
            // Fitness should improve or stay stable over generations
            if generation > 0 {
                XCTAssertGreaterThanOrEqual(result.bestFitness, previousFitness - 0.1,
                    "Fitness should not degrade significantly")
            }
            
            previousFitness = result.bestFitness
        }
    }
    
    func testApplyBestConfiguration() async throws {
        // Add metrics
        for _ in 0..<20 {
            let taskResult = TaskResult(
                taskId: UUID(),
                wasSuccessful: true,
                executionTime: 2.0,
                memoryUsed: 30,
                userRating: 4.5
            )
            engine.updateMetrics(taskResult: taskResult)
        }
        
        // Evolve population
        _ = await engine.evolvePopulation()
        
        // Apply best configuration
        let result = engine.applyBestConfiguration()
        
        XCTAssertTrue(result.success)
        XCTAssertFalse(result.parameters.isEmpty)
        XCTAssertNotNil(result.parameters["learning_rate"])
        XCTAssertNotNil(result.parameters["confidence_threshold"])
        XCTAssertNotNil(result.parameters["fitness"])
    }
    
    func testChromosomeDiversity() async throws {
        // Get best chromosome
        let best = engine.getBestChromosome()
        XCTAssertNotNil(best)
        
        // Evolve and check that population maintains diversity
        _ = await engine.evolvePopulation()
        let newBest = engine.getBestChromosome()
        XCTAssertNotNil(newBest)
        
        // Parameters should be in valid ranges even after evolution
        if let chromosome = newBest {
            XCTAssertGreaterThanOrEqual(chromosome.learningRate, 0.001)
            XCTAssertLessThanOrEqual(chromosome.learningRate, 0.1)
        }
    }
}
