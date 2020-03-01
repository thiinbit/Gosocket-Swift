//
//  Codec.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

public protocol Codec {
    
    associatedtype MessageType
    
    func encode(message: MessageType) throws -> [UInt8]
    func decode(data: [UInt8]) throws -> MessageType
}


public class StringCodec: Codec {

    public typealias MessageType = String
    
    public init() {}
    
    public func encode(message: String) throws -> [UInt8] {
        return Array(message.utf8)
    }
    
    public func decode(data: [UInt8]) throws -> String {
        return String(bytes: data, encoding: .utf8) ?? ""
    }
}

