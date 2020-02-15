//
//  Enums.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

enum ClientStatus {
    case Preparing
    case Running
    case Stop
}

enum RunEnv {
    case DEBUG
    case RELEASE
}

enum VER: UInt8 {
    case PacketVersion = 42
    case PacketHeartbeatVersion = 255
}


