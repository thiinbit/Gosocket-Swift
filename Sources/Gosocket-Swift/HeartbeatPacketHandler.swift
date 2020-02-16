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
    
    func heartbeatPacket(packet: Packet) throws {
        
        let pongCmd: [Byte] = [1]
        let checksum = Adler32.checksum(data: pongCmd)
        
        let pac = Packet(ver: PACKET_HEARTBEAT_VERSION, len: 1, body: pongCmd, checksum: checksum)
        
        try self.cli.packetHandler?.handlePacketSend(packet: pac)
    }
}
