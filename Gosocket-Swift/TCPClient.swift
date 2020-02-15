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


public class TCPClient<L: MessageListener, C: Codec>
    where L.MessageType == C.MessageType {
    
    let serialQueue = DispatchQueue.init(label: "TCPClientDispatch", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    let name: String
    let host: String
    let port: Int32
    var fd: Optional<Int32>
    var env: RunEnv
    var status: ClientStatus
    var codec: C
    var messageListener: L
    var connectHandler: Optional<ConnectHandler<L, C>>
    var packetHandler: Optional<PacketHandler<L, C>>
    var heartbeatPacketHandler: Optional<HeartbeatPacketHandler<L, C>>
    let sendMessageQueue = BlockingQueue<C.MessageType>()


    init(host: String, port: Int32, codec: C, listener: L) throws {
            if !IsValidHost(ip: host) {
                throw ClientError.invalidServerHost
            }

            self.name = UUID().uuidString
            self.host = host
            self.port = port
            self.fd = nil
            self.env = RunEnv.DEBUG
            self.status = ClientStatus.Preparing
            self.codec = StringCodec() as! C
            self.messageListener = listener
            self.connectHandler = nil
            self.packetHandler = nil
            self.heartbeatPacketHandler = nil
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
            default:
                throw ConnectError.unknownError
            }
        }

        self.connectHandler = ConnectHandler(cli: self)
        self.packetHandler = PacketHandler(cli: self)
        self.heartbeatPacketHandler = HeartbeatPacketHandler(cli: self)
        
        serialQueue.sync {
            self.status = ClientStatus.Running
        }
        
        try self.connectHandler!.handleConnect()

        return self
    }

    public func hangup(error: Error) {
        print(error)  // TODO: hold error
        hangup()
    }
    
    public func hangup() {
        serialQueue.sync {
            self.status = ClientStatus.Stop
        }
        self.connectHandler?.closeConnect()
    }

    public func sendMessage(message: C.MessageType) {
        self.sendMessageQueue.append(newElement: message)
    }
}




