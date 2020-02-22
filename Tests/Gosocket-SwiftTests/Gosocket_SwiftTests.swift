import XCTest
@testable import Gosocket_Swift

final class Gosocket_SwiftTests: XCTestCase {
    
    // swift test --filter Gosocket_SwiftTests.Gosocket_SwiftTests/testExample
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let start = DispatchTime.now()
        let c = Adler32.checksum(data: Array("Hello, Gosocket!".utf8))
        let end = DispatchTime.now()
        
        debugLog(c)
        debugLog("use time: \((end.uptimeNanoseconds - start.uptimeNanoseconds))")
        
        XCTAssertEqual(Gosocket_Swift().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
