import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Gosocket_SwiftTests.allTests),
    ]
}
#endif
