//
//  File.swift
//  
//
//  Created by isnail on 2020/2/16.
//

import Foundation

func debugLog(_ msg: Any) {
    if curEnv() == RunEnv.DEBUG {
        print("[Gosocket-DEBUG] \(Date()): \(msg)")
    }
}

