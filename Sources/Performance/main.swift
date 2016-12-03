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

let url = URL(string: "https://google.com")
let client = try! HTTPClient(url: url!)
try! client.open()
let response = try! client.request()

print(response)

let allTests = [
    channelTest
]

if CommandLine.arguments.count >= 1 {
    for i in 0..<allTests.count {
        allTests[i]()
    }
    exit(0)
}

let testTarget = CommandLine.arguments[1]

switch testTarget {
case "channel":
allTests[0]()
default:
    print("unknow pref.")
    exit(1)
}

print("All items are completed.")
