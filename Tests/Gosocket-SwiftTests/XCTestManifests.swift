import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Gosocket_SwiftTests.allTests),
        testCase(TCPClient_SwiftTests.allTests),
        testCase(BlockingQueue_SwiftTests.allTests),
    ]
}
#endif
