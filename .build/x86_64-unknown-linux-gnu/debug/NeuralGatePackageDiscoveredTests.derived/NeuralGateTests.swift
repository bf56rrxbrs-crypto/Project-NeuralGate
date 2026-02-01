import XCTest
@testable import NeuralGateTests

fileprivate extension NeuralGateTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__NeuralGateTests = [
        ("testConfigurationInitialization", testConfigurationInitialization),
        ("testErrorDescriptions", testErrorDescriptions),
        ("testExplainableResult", testExplainableResult),
        ("testTaskCreation", testTaskCreation),
        ("testWorkflowCreation", testWorkflowCreation)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __NeuralGateTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NeuralGateTests.__allTests__NeuralGateTests)
    ]
}