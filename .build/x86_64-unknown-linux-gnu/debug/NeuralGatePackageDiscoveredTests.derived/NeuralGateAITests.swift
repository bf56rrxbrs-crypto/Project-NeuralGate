import XCTest
@testable import NeuralGateAITests

fileprivate extension NeuralGateAITests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__NeuralGateAITests = [
        ("testAIDecisionEngine", asyncTest(testAIDecisionEngine)),
        ("testBaselineModel", asyncTest(testBaselineModel)),
        ("testPredictiveAnalytics", testPredictiveAnalytics),
        ("testResourceAwareModel", testResourceAwareModel)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __NeuralGateAITests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NeuralGateAITests.__allTests__NeuralGateAITests)
    ]
}