//
//  BlockingQueue_SwiftTests.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//


import XCTest
@testable import Gosocket_Swift

final class BlockingQueue_SwiftTests: XCTestCase {
    
    private let s = DispatchSemaphore(value: 0)
    
    let serialQueue = DispatchQueue.init(label: "TestDispatch", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    // swift test --filter Gosocket_SwiftTests.BlockingQueue_SwiftTests/testBlockingQueue
    func testBlockingQueue() {
        
        let queue = BlockingQueue<String>()
        serialQueue.async {
            _ = self.s.wait(wallTimeout: DispatchWallTime.now() + 2)
            queue.append(newElement: "Hello!")
            debugLog("append Hello!")
            
            _ = self.s.wait(wallTimeout: DispatchWallTime.now() + 2)
            queue.append(newElement: "Gosocket!")
            debugLog("append Gosocket!")
            
            let e = queue.dequeue(wallTimeout: DispatchWallTime.now() + .seconds(3))
            debugLog(e as Any)
            
            let e2 = queue.dequeue(wallTimeout: DispatchWallTime.now() + .seconds(3))
            debugLog(e2 as Any)
            
            let e3 = queue.dequeue(wallTimeout: DispatchWallTime.now() + .seconds(3))
            debugLog(e3 as Any)
            
            XCTAssertEqual("", "")
        }
    }
    static var allTests = [
        ("testBlockingQueue", testBlockingQueue),
    ]
}
