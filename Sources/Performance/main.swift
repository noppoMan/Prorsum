//
//  main.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/28.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation
import Prorsum

let allTests = [
    channelTest
]

let testTarget: String
if CommandLine.arguments.count <= 1 {
    testTarget = "all"
} else {
    testTarget = CommandLine.arguments[1]
}

switch testTarget {
case "all":
    for i in 0..<allTests.count {
        allTests[i]()
    }
    
case "http-server":
    httpServerTest()

default:
    print("unknow pref.")
    exit(1)
}

print("All items are completed.")
