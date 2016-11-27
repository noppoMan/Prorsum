//
//  Channel.swift
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

import Foundation.NSDate
import Prorsum


func channelTest(){

    print("--- [Performance] Channel<Eelement> Millions of roundtrips ---");

    let _out = Channel<Int>.make(capacity: 10)
    let _in = Channel<Int>.make(capacity: 10)

    let start = Date()

    go {
        repeat {
            let r = try! _in.receive()
            try! _out.send(r)
        } while !_in.isClosed
    }

    for i in 0..<1000000 {
        try! _in.send(i)
        let data = try! _out.receive()
    }

    _out.close()
    _in.close()


    let timeElapsed = -start.timeIntervalSinceNow

    print("done, Time Elapsed: \(timeElapsed)")
    print("")
}
