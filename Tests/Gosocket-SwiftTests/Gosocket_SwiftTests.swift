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
        
        let ip1 = "10.20.30.40"
        let ip2 = "255.255.255.256"
        
        XCTAssertTrue(isValidIPv4IP(ip: ip1))
        XCTAssertFalse(isValidIPv4IP(ip: ip2))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
