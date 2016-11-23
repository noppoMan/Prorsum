//
//  main.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

import Foundation
import Dispatch

//let PRORSUM_MAX_PROC: Int
//if let proc = CommandLine.arguments["PRORSUM_MAX_PROC"] {
//    
//} else {
//    
//}

let testCh = Channel<Int>.make(capacity: 1)
let doneCh = Channel<String>.make(capacity: 1)

go {
    try! testCh.send(1)
    try! testCh.send(2)
    try! testCh.send(3)
    try! doneCh.send("done")
}

forSelect { done in
    when(testCh) {
        print($0)
    }

    otherwise {
        print("otherwise")
    }

    when(doneCh) {
        print($0)
        done()
    }
}

////while true {
//    select {
//        when(testCh) {
//            print($0)
//        }
//
//        otherwise {
//            print("aaaaaaaa")
//        }
//    }
////}
//
//    select {
//        when(testCh) {
//            print($0)
//        }
//    }
//
//    select {
//        when(testCh) {
//            print($0)
//        }
//    }
//
//    select {
//        otherwise {
//            print("aaaaaaaa")
//        }
//    }
//
//    select {
//        when(doneCh) {
//            print($0)
//        }
//    }

let wg = WaitGrpup()

wg.add(1)

go {
    sleep(1)
    print("wg: 1")
    wg.done()
}

wg.add(1)

go {
    sleep(2)
    print("wg: 2")
    wg.done()
}

wg.wait()
//
//print("wg done")
//
//let chan = Channel<Int>.make(capacity: 1)
//
//go {
//    try! chan.send(1)
//    sleep(1)
//    try! chan.send(1)
//    sleep(1)
//    
//    go {
//        sleep(1)
//        try! chan.send(1)
//    }
//    
//    go {
//        sleep(1)
//        try! chan.send(1)
//    }
//}
//
//let sum = try! chan.receive() + chan.receive() + chan.receive() + chan.receive()
//assert(sum == 4)
//print("sum: \(sum)")
//print("channel done")
//

//Prorsum.runLoop()
