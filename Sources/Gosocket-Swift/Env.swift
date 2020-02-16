//
//  File.swift
//  
//
//  Created by isnail on 2020/2/16.
//

import Foundation


private var CUR_ENV = RunEnv.DEBUG

func curEnv() -> RunEnv {
    return CUR_ENV
}

func setCurEnv(runEnv: RunEnv) {
    CUR_ENV = runEnv
}
