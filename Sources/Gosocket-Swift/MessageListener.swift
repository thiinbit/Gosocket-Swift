//
//  MessageListener.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation

public protocol MessageListener {

    associatedtype MessageType

    func OnMessage(message: MessageType)
}


public class StringMessageListener: MessageListener {
    
    public typealias MessageType = String
    
    public typealias MessageHandler = (MessageType)  -> Void
    
    var msgHandler: MessageHandler
    
    public init(messageHandler: @escaping MessageHandler) {
        self.msgHandler = messageHandler
    }
    
    public func OnMessage(message: String) {
        self.msgHandler(message)
    }
}
