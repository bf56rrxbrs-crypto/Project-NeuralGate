import XCTest
@testable import NeuralGateAI
@testable import NeuralGate

final class DecisionRouterTests: XCTestCase {
    var router: DecisionRouter!
    
    override func setUp() async throws {
        router = DecisionRouter()
    }
    
    // MARK: - Complexity Calculation Tests
    
    func testComplexityInRange() async {
        // Test various inputs to ensure complexity is always in [0, 1]
        let testPrompts = [
            "Hello",
            "What is the weather today?",
            "Can you analyze the financial implications of implementing a machine learning pipeline for fraud detection?",
            "Explain quantum computing in simple terms",
            "Calculate the optimal resource allocation strategy",
            String(repeating: "word ", count: 100), // Very long prompt
            ""
        ]
        
        for prompt in testPrompts {
            let complexity = await router.calculateComplexity(for: prompt)
            XCTAssertGreaterThanOrEqual(complexity, 0.0, "Complexity should be >= 0 for prompt: '\(prompt.prefix(50))'")
            XCTAssertLessThanOrEqual(complexity, 1.0, "Complexity should be <= 1 for prompt: '\(prompt.prefix(50))'")
        }
    }
    
    func testEmptyPromptComplexity() async {
        let complexity = await router.calculateComplexity(for: "")
        XCTAssertEqual(complexity, 0.0, "Empty prompt should have 0 complexity")
    }
    
    func testWhitespaceOnlyComplexity() async {
        let complexity = await router.calculateComplexity(for: "   \n\t  ")
        XCTAssertEqual(complexity, 0.0, "Whitespace-only prompt should have 0 complexity")
    }
    
    func testSimplePromptComplexity() async {
        let complexity = await router.calculateComplexity(for: "Hello")
        XCTAssertLessThan(complexity, 0.3, "Simple single-word prompt should have low complexity")
    }
    
    func testComplexPromptWithKeywords() async {
        let prompt = "Analyze and compare the performance metrics, then optimize and predict future outcomes"
        let complexity = await router.calculateComplexity(for: prompt)
        XCTAssertGreaterThan(complexity, 0.4, "Prompt with complexity keywords should have higher score")
    }
    
    func testLongPromptComplexity() async {
        // 60 words should approach or reach max length score
        let longPrompt = String(repeating: "word ", count: 60)
        let complexity = await router.calculateComplexity(for: longPrompt)
        XCTAssertGreaterThanOrEqual(complexity, 0.7, "Long prompt should have high complexity")
    }
    
    func testDeterministicComplexity() async {
        // Same prompt should always yield same complexity
        let prompt = "Explain machine learning algorithms"
        let complexity1 = await router.calculateComplexity(for: prompt)
        let complexity2 = await router.calculateComplexity(for: prompt)
        XCTAssertEqual(complexity1, complexity2, accuracy: 0.0001, "Complexity calculation should be deterministic")
    }
    
    func testComplexityKeywordBoost() async {
        // Two prompts with similar length but different keywords
        let simplePrompt = "Tell me about the weather today and what to wear"
        let complexPrompt = "Analyze compare evaluate synthesize explain calculate optimize predict"
        
        let simpleComplexity = await router.calculateComplexity(for: simplePrompt)
        let complexComplexity = await router.calculateComplexity(for: complexPrompt)
        
        XCTAssertGreaterThan(complexComplexity, simpleComplexity, "Keywords should boost complexity score")
    }
    
    // MARK: - Routing Decision Tests
    
    func testSensitiveDataAlwaysLocal() async {
        let prompt = "Share my password: secret123"
        let mode = await router.determineBestMode(for: prompt, containsSensitiveData: true)
        XCTAssertEqual(mode, .local, "Sensitive data should always use local mode")
    }
    
    func testSimplePromptRoutesToLocal() async {
        let prompt = "Hello"
        let mode = await router.determineBestMode(for: prompt, containsSensitiveData: false)
        XCTAssertEqual(mode, .local, "Simple prompt should route to local mode")
    }
    
    func testComplexPromptRoutesToRemote() async {
        // Create a very complex prompt that exceeds default threshold
        let prompt = "Analyze and compare the comprehensive evaluation of multiple machine learning algorithms, synthesize the results, and predict optimal configurations while calculating resource requirements and explaining the entire process in detail with supporting evidence"
        let mode = await router.determineBestMode(for: prompt, containsSensitiveData: false)
        XCTAssertEqual(mode, .remote, "Complex prompt should route to remote mode")
    }
    
    func testThresholdConfiguration() async {
        // Test with low threshold - even simple prompts go remote
        let lowThresholdRouter = DecisionRouter(complexityThreshold: 0.1)
        let simplePrompt = "What is the time?"
        let mode1 = await lowThresholdRouter.determineBestMode(for: simplePrompt, containsSensitiveData: false)
        
        // With very low threshold, most prompts should go remote
        let complexity = await lowThresholdRouter.calculateComplexity(for: simplePrompt)
        if complexity >= 0.1 {
            XCTAssertEqual(mode1, .remote, "With low threshold, this should route to remote")
        }
        
        // Test with high threshold - even complex prompts stay local
        let highThresholdRouter = DecisionRouter(complexityThreshold: 0.9)
        let complexPrompt = "Analyze and evaluate these requirements"
        let mode2 = await highThresholdRouter.determineBestMode(for: complexPrompt, containsSensitiveData: false)
        XCTAssertEqual(mode2, .local, "With high threshold, this should route to local")
    }
    
    func testThresholdBounds() async {
        // Test threshold clamping
        let tooLowRouter = DecisionRouter(complexityThreshold: -0.5)
        let tooHighRouter = DecisionRouter(complexityThreshold: 1.5)
        
        // Both should work without crashing
        let _ = await tooLowRouter.determineBestMode(for: "test", containsSensitiveData: false)
        let _ = await tooHighRouter.determineBestMode(for: "test", containsSensitiveData: false)
    }
    
    // MARK: - Malformed Input Tests
    
    func testMalformedInputs() async {
        let malformedInputs = [
            String(repeating: "\n", count: 100),
            String(repeating: " ", count: 1000),
            "\0\0\0",
            "😀🎉💻🚀" // Emoji only
        ]
        
        for input in malformedInputs {
            let complexity = await router.calculateComplexity(for: input)
            XCTAssertGreaterThanOrEqual(complexity, 0.0, "Malformed input should have valid complexity >= 0")
            XCTAssertLessThanOrEqual(complexity, 1.0, "Malformed input should have valid complexity <= 1")
            
            // Should not crash when routing
            let mode = await router.determineBestMode(for: input, containsSensitiveData: false)
            XCTAssertTrue([.local, .remote, .hybrid].contains(mode), "Should return valid mode")
        }
    }
    
    func testUnicodeAndSpecialCharacters() async {
        let unicodePrompt = "Cómo está el tiempo hoy? 你好世界 🌍"
        let complexity = await router.calculateComplexity(for: unicodePrompt)
        XCTAssertGreaterThanOrEqual(complexity, 0.0)
        XCTAssertLessThanOrEqual(complexity, 1.0)
        
        let mode = await router.determineBestMode(for: unicodePrompt, containsSensitiveData: false)
        XCTAssertTrue([.local, .remote, .hybrid].contains(mode))
    }
    
    // MARK: - Privacy Tests
    
    func testPrivacyProtection() async {
        // Verify that routing decisions work without exposing raw prompts
        let sensitivePrompt = "My social security number is 123-45-6789"
        let mode = await router.determineBestMode(for: sensitivePrompt, containsSensitiveData: true)
        
        // Should always be local for sensitive data
        XCTAssertEqual(mode, .local)
        
        // The logging should use hashes, but we can't directly test that here
        // This is verified by code inspection of the DecisionRouter implementation
    }
}
