import XCTest
@testable import NeuralGateLearningTests

fileprivate extension NeuralGateLearningTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__NeuralGateLearningTests = [
        ("testFeedbackRecording", testFeedbackRecording),
        ("testImprovementExecution", asyncTest(testImprovementExecution)),
        ("testPerformanceMetricsUpdate", testPerformanceMetricsUpdate),
        ("testSelfImprovement", asyncTest(testSelfImprovement))
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __NeuralGateLearningTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NeuralGateLearningTests.__allTests__NeuralGateLearningTests)
    ]
}