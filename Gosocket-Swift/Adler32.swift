//
//  Adler32.swift
//  Gosocket-Swift
//
// Copyright 2020 @thiinbit.  All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.
//

import Foundation


public class Adler32 {
    
    // mod is the largest prime that is less than 65536.
    private static var mod: UInt32 = 65521
    // nmax is the largest n such that
    // 255 * n * (n+1) / 2 + (n+1) * (mod-1) <= 2^32-1.
    // It is mentioned in RFC 1950 (search for "5552").
    private static var nmax = 5552
    
    public static func checksum(data: [UInt8]) -> UInt32 {
        return UInt32(update(_d: 1, _p: data))
    }
    
    private static func update(_d: UInt32, _p: [UInt8]) -> UInt32 {
        let d = _d
        var p = ArraySlice(_p)
        
        var s1 = UInt32(d & 0xffff)
        var s2 = UInt32(d >> 16)
        
        
        while p.count > 0 {
            var q: ArraySlice<UInt8> = []
            if p.count > nmax {
                p = p[..<nmax]
                q = p[nmax...]
            }
            while p.count >= 4 {
                s1 += UInt32(p[0])
                s2 += s1
                s1 += UInt32(p[1])
                s2 += s1
                s1 += UInt32(p[2])
                s2 += s1
                s1 += UInt32(p[3])
                s2 += s1
                p = p[4...]
            }
            for x in p {
                s1 += UInt32(x)
                s2 += s1
            }
            s1 %= mod
            s2 %= mod
            p = q
        }
        return UInt32(s2<<16 | s1)
    }
}
