//
//  HeartbeatPacketHandler.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation


class HeartbeatPacketHandler<C: Codec, L: MessageListener>
where C.MessageType == L.MessageType{
    
    private let cli: TCPClient<C, L>
    
    init(cli: TCPClient<C, L>) {
        self.cli = cli
    }
    
    // Send pong cmd or log pong received
    func receivedHeartbeatPacket(packet: Packet) throws {
        // If received a ping cmd
        if packet.body[0] == 0 {
            let pongCmd: [Byte] = [1] // Pong cmd 1
            let checksum = Adler32.checksum(data: pongCmd)
            
            let pac = Packet(ver: PACKET_HEARTBEAT_VERSION, len: 1, body: pongCmd, checksum: checksum)
            
            try self.cli.packetHandler?.handlePacketSend(packet: pac)
            debugLog("Cli \(self.cli.name) heartbeat. pong sent.")
        }
        // If received a pong cmd
        if packet.body[0] == 1 {
            debugLog("Cli \(self.cli.name) heartbeat. pong received.")
        }
    }
    
    // Send ping cmd
    func sendHeartbeatPacket() throws {
        
        let pongCmd: [Byte] = [0] // Ping cmd 0
        let checksum = Adler32.checksum(data: pongCmd)
        
        let pac = Packet(ver: PACKET_HEARTBEAT_VERSION, len: 1, body: pongCmd, checksum: checksum)
        
        try self.cli.packetHandler?.handlePacketSend(packet: pac)
    }
}
