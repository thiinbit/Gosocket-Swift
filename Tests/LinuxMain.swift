import XCTest

import Gosocket_SwiftTests

var tests = [XCTestCaseEntry]()
tests += Gosocket_SwiftTests.allTests()
tests += TCPClient_SwiftTests.allTests()
tests += BlockingQueue_SwiftTests.allTests()
XCTMain(tests)
