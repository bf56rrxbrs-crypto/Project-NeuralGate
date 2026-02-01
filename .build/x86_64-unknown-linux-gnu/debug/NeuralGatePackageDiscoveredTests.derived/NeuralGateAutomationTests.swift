import XCTest
@testable import NeuralGateAutomationTests

fileprivate extension NeuralGateAutomationTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__NeuralGateAutomationTests = [
        ("testTaskFailover", asyncTest(testTaskFailover)),
        ("testTaskManager", asyncTest(testTaskManager)),
        ("testWorkflowComposition", testWorkflowComposition),
        ("testWorkflowExecution", asyncTest(testWorkflowExecution))
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __NeuralGateAutomationTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NeuralGateAutomationTests.__allTests__NeuralGateAutomationTests)
    ]
}