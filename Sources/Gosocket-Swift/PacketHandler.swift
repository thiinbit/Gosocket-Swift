//
//  PacketHandler.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation


@_silgen_name("ytcpsocket_send") private func c_ytcpsocket_send(_ fd: Int32, buff: UnsafePointer<Byte>, len: Int32) -> Int32


class PacketHandler<L: MessageListener, C: Codec>
where L.MessageType == C.MessageType{
    
    private let cli: TCPClient<L, C>
    
    init(cli: TCPClient<L, C>) {
        self.cli = cli
    }
    
    func handlePacketReceived(packet: Packet) throws {
        let m = try self.cli.codec.decode(data: packet.body)
        
        self.cli.messageListener.OnMessage(message: m)
    }
    
    func handlePacketSend(packet: Packet) throws {
        guard let fd = self.cli.fd else {
            throw ConnectError.fdNotExist
        }
        
        let uint32Size = MemoryLayout<UInt32>.size
        
        let verBuf: [UInt8] = [packet.ver]
    
        var lenBigEndian = packet.len.bigEndian
        let lenPtr = withUnsafePointer(to: &lenBigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: uint32Size) {
                UnsafeBufferPointer(start: $0, count: uint32Size)
            }
        }
        let lenBuf: [UInt8] = Array(lenPtr)
        
        var checksumBigEndian = packet.checksum.bigEndian
        let csPtr = withUnsafePointer(to: &checksumBigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: uint32Size) {
                UnsafeBufferPointer(start: $0, count: uint32Size)
            }
        }
        let checksumBuf: [UInt8] = Array(csPtr)
        
        let data = verBuf + lenBuf + packet.body + checksumBuf
        
        let sendSize: Int32 = c_ytcpsocket_send(fd, buff: data, len: Int32(data.count))
        
        if Int(sendSize) != data.count {
            throw ConnectError.sendSizeError
        }
    }
}
