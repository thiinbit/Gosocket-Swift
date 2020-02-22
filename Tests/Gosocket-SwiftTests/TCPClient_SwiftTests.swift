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
    
    // swift test --filter Gosocket_SwiftTests.TCPClient_SwiftTests/testClient
    func testClient() {
        debugLog("TCPClientTest Starting ...")
        let host = "127.0.0.1"
        
        do {
            let tcpCli: TCPClient = try TCPClient(host: host, port: 8888, codec: StringCodec(), listener: StringMessageListener())
                .debugMode(on: true)
                .dial()
            
            tcpCli.sendMessage(message: "Hello, Gosocket!")
            
            _ = s.wait(wallTimeout: DispatchWallTime.now() + .seconds(40))
            
            tcpCli.sendMessage(message: "See you!")
            
            _ = s.wait(wallTimeout: DispatchWallTime.now() + .seconds(42))
            
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
