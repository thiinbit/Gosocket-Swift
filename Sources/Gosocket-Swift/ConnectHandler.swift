//
//  ConnectHandler.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

@_silgen_name("ytcpsocket_close") private func c_ytcpsocket_close(_ fd: Int32) -> Int32

@_silgen_name("ytcpsocket_pull") private func c_ytcpsocket_pull(_ fd: Int32, buff: UnsafePointer<Byte>, len: Int32, timeout: Int32) -> Int32


class ConnectHandler<C: Codec, L: MessageListener>
where C.MessageType == L.MessageType {
    
    let serialQueue = DispatchQueue.init(label: "TCPConnectDispatch", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    let messageQueue = [C.MessageType]()
    
    private let cli: TCPClient<C, L>
    
    init(cli: TCPClient<C, L>) {
        self.cli = cli
    }
    
    
    func handleConnect() throws {
        serialQueue.async {
            do {
                try self.handleWrite()
            } catch {
                self.cli.hangup(error: error)
            }
        }
        serialQueue.async {
            do {
                try self.handleRead()
            } catch {
                self.cli.hangup(error: error)
            }
        }
    }
    
    private func handleWrite() throws {
        debugLog("Cli \(self.cli.name) start handle write.")
        while true {
            if self.cli.status != ClientStatus.Running {
                debugLog("Cli \(self.cli.name) stop write!")
                break
            }
            
            guard let m = cli.sendMessageQueue.dequeue(wallTimeout: DispatchWallTime.now() + .seconds(5)) else {
                debugLog("Cli \(self.cli.name) waiting for message")
                continue
            }
            
            let data = try self.cli.codec.encode(message: m)
            
            let p = Packet(ver: UInt8(PACKET_VERSION), len: UInt32(data.count), body: data, checksum: Adler32.checksum(data: data))
            
            debugLog("Cli \(self.cli.name) send packet. ver: \(p.ver), size: \(p.len), checksum: \(p.checksum)")
            
            try self.cli.packetHandler?.handlePacketSend(packet: p)
        }
    }
    
    private func handleRead() throws {
        debugLog("Cli \(self.cli.name) start handle read.")
        while true {
            if self.cli.status != ClientStatus.Running {
                debugLog("Cli \(self.cli.name) stop read!")
                break
            }
            
            guard let fd = self.cli.fd else {
                throw ConnectError.fdNotExist
            }
            
            var verBuff = [Byte](repeating: 0x0, count: P_VER_LEN)
            
            let readLen = c_ytcpsocket_pull(fd, buff: &verBuff, len: Int32(P_VER_LEN), timeout: Int32(5))
            
            if readLen < P_VER_LEN {
                continue
            } else if verBuff[0] != PACKET_VERSION && verBuff[0] != PACKET_HEARTBEAT_VERSION {
                throw ConnectError.readVerError
            }
            
            var sizeBuff = [Byte](repeating: 0x0, count: P_LEN_LEN)
            let readLenOfSize = c_ytcpsocket_pull(fd, buff: &sizeBuff, len: Int32(P_LEN_LEN), timeout: Int32(5))
            
            if readLenOfSize < P_LEN_LEN {
                throw ConnectError.readLengthError
            }
            
            let bodySize = UnsafeRawPointer(sizeBuff).assumingMemoryBound(to: UInt32.self).pointee.bigEndian
            
            var bodyBuff = [Byte](repeating: 0x0, count: Int(bodySize))
            let readLenOfBody = c_ytcpsocket_pull(fd, buff: &bodyBuff, len: Int32(bodySize), timeout: Int32(42))
            
            if readLenOfBody < bodySize {
                throw ConnectError.readBodyError
            }
            
            var checksumBuff = [Byte](repeating: 0x0, count: Int(P_CHECKSUM_LEN))
            let readLenOfChecksum = c_ytcpsocket_pull(fd, buff: &checksumBuff, len: Int32(P_CHECKSUM_LEN), timeout: Int32(5))
            
            if (readLenOfChecksum < P_CHECKSUM_LEN) {
                throw ConnectError.readChecksumError
            }
            let checksum = UnsafeRawPointer(checksumBuff).assumingMemoryBound(to: UInt32.self).pointee.bigEndian
            
            if Adler32.checksum(data: bodyBuff) != checksum {
                throw ConnectError.checksumError
            }
            
            let packet = Packet(ver: verBuff[0], len: bodySize, body: bodyBuff, checksum: checksum)
            
            debugLog("Cli \(self.cli.name) receive packet. ver: \(packet.ver), size: \(packet.len), checksum: \(packet.checksum)")
            
            if verBuff[0] == PACKET_HEARTBEAT_VERSION {
                try self.cli.heartbeatPacketHandler?.heartbeatPacket(packet: packet)
            } else {
                try self.cli.packetHandler?.handlePacketReceived(packet: packet)
            }
        }
    }
    
    func closeConnect() {
        guard let fd = self.cli.fd else {
            return
        }
        _ = c_ytcpsocket_close(fd)
    }
}
