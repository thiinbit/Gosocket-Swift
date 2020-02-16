//
//  TCPClient_SwiftTests.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import XCTest
@testable import Gosocket_Swift

final class TCPClient_SwiftTests: XCTestCase {
    
    private let s = DispatchSemaphore(value: 0)
    
    func testClient() {
        debugLog("TCPClientTest Starting ...")
        let host = "127.0.0.1"
        
        do {
            let tcpCli: TCPClient = try TCPClient(host: host, port: 8888, codec: StringCodec(), listener: StringMessageListener())
                .dial()
            
            _ = s.wait(wallTimeout: DispatchWallTime.now() + .seconds(3))
            
            tcpCli.hangup()
            debugLog("hangup!")
        } catch {
            debugLog(error)
        }
    }
    
    static var allTests = [
        ("testClient", testClient),
    ]
}
