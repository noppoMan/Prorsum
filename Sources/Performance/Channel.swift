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

import Foundation
import Prorsum


func channelTest(){
    print("--- [Performance] Channel<Eelement> Millions of roundtrips ---")
    let start = Date()
    let count = 1000000

    let ch = Channel<Int>.make(capacity: 1)
    
    for i in 0..<count {
        go {
            try! ch.send(i)
        }
    }
    
    forSelect { done in
        when(ch) {
            if $0 == count-1 {
                done()
            }
        }
    }

    let timeElapsed = -start.timeIntervalSinceNow

    print("done, Time Elapsed: \(timeElapsed)")
    print("")
}
