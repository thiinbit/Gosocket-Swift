//
//  Packet.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

let PACKET_VERSION          : UInt8 = 42
let PACKET_HEARTBEAT_VERSION: UInt8 = 255

let P_VER_LEN      = 1
let P_LEN_LEN      = 4
let P_CHECKSUM_LEN = 4

struct Packet {
    let ver: UInt8
    let len: UInt32
    let body: [UInt8]
    let checksum: UInt32
    
    init(ver: UInt8, len: UInt32, body: [UInt8], checksum: UInt32) {
        self.ver = ver
        self.len = len
        self.body = body
        self.checksum = checksum
    }
}
