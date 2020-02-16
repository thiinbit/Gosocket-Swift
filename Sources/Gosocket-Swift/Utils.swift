//
//  Utils.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation
import Network

/**
    Is valid host address. "127.0.0.1" or "2001:db8::35:44"
 */
func IsValidHost(ip: String) -> Bool {

    if #available(OSX 10.14, *) {
        if let _ = IPv4Address(ip) {
            return true
        }
    } else {
        return true
    }

    if #available(OSX 10.14, *) {
        if let _ = IPv6Address(ip) {
            return false // not support currently
        }
    } else {
        return false
    }
    
    return false
}
