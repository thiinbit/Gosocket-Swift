//
//  Errors.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation


public enum ClientError: Error {
    case invalidServerHost
    
}


public enum ConnectError: Error {
    case fdNotExist
    
    case queryFailed
    case connectionClosed
    case connectionTimeout
    case connectFail
    case unknownError
    
    case handleConnectFailed
    case readVerError
    case readLengthError
    case readBodyError
    case readChecksumError
    case checksumError
    
    case dequeueError
    case sendSizeError
}
