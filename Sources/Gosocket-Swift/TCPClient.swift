//
//  TCPClient.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

typealias Byte = UInt8

@_silgen_name("ytcpsocket_connect") private func c_ytcpsocket_connect(_ host: UnsafePointer<Byte>, port: Int32, timeout: Int32) -> Int32


//@_silgen_name("ytcpsocket_bytes_available") private func c_ytcpsocket_bytes_available(_ fd: Int32) -> Int32


public class TCPClient< C: Codec, L: MessageListener>
where C.MessageType == L.MessageType {
    private let s = DispatchSemaphore(value: 0)
    
    let serialQueue = DispatchQueue.init(label: "TCPClientDispatch", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    let name: String
    let host: String
    let port: Int32
    var fd: Optional<Int32>
    var status: ClientStatus
    var codec: C
    var messageListener: L
    var connectHandler: Optional<ConnectHandler<C, L>>
    var packetHandler: Optional<PacketHandler<C, L>>
    var heartbeatPacketHandler: Optional<HeartbeatPacketHandler<C, L>>
    let sendMessageQueue = BlockingQueue<C.MessageType>()
    var lastActive: Date
    
    
    public init(host: String, port: Int32, codec: C, listener: L) throws {
//        if !isValidIPv4IP(ip: host) {
//            throw ClientError.invalidServerHost
//        }
        
        self.name = UUID().uuidString
        self.host = host
        self.port = port
        self.fd = nil
        self.status = ClientStatus.Preparing
        self.codec = StringCodec() as! C
        self.messageListener = listener
        self.connectHandler = nil
        self.packetHandler = nil
        self.heartbeatPacketHandler = nil
        self.lastActive = Date.init()
        
        setCurEnv(runEnv: RunEnv.DEBUG)
        
        debugLog("Cli init: \(self.name)")
    }
    
    public func dial() throws -> Self {
        
        let rs: Int32 = c_ytcpsocket_connect(self.host, port: self.port, timeout: 5)
        
        if rs > 0 {
            self.fd = rs
        } else {
            switch rs {
            case -1:
                throw ConnectError.queryFailed
            case -2:
                throw ConnectError.connectionClosed
            case -3:
                throw ConnectError.connectionTimeout
            case -4:
                throw ConnectError.connectFail
            default:
                debugLog("Cli \(self.name) throw unkoneError, rs: \(rs)")
                throw ConnectError.unknownError
            }
        }
        
        debugLog("Cli \(self.name) connected to: \(host):\(port).")
        
        self.connectHandler = ConnectHandler(cli: self)
        self.packetHandler = PacketHandler(cli: self)
        self.heartbeatPacketHandler = HeartbeatPacketHandler(cli: self)
        
        serialQueue.sync {
            self.status = ClientStatus.Running
        }
        
        try self.connectHandler!.handleConnect()
        
        debugLog("Cli \(self.name) dialed!")
        
        return self
    }
    
    public func hangup(error: Error) {
        print(error)  // TODO: hold error
        hangup()
    }
    
    public func updateLastActive() {
        self.lastActive = Date.init()
    }
    
    public func debugMode(on: Bool) -> Self {
        if on {
            setCurEnv(runEnv: RunEnv.DEBUG)
        } else {
            setCurEnv(runEnv: RunEnv.RELEASE)
        }
        
        return self
    }
    
    public func isDialed() -> Bool {
        return self.status == ClientStatus.Running
    }
    
    public func hangup() {
        serialQueue.sync {
            self.status = ClientStatus.Stop
        }
        
        // wait 1 sec if has message not sent in queue.
        for _ in 1...5 {
            if self.sendMessageQueue.count() > 0 {
                _ = s.wait(timeout: DispatchTime.now() + .milliseconds(200))
            }
        }
        
        self.connectHandler?.closeConnect()
        self.updateLastActive()
    }
    
    public func sendMessage(message: C.MessageType) throws {
        try serialQueue.sync {
            if self.status != ClientStatus.Running {
                throw ClientError.clientNotRunning
            }
        }
            
        self.sendMessageQueue.append(newElement: message)
        debugLog("Cli \(self.name) sent a message: \(message)")
    }
}




