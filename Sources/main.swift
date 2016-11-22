//
//  main.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

import Foundation


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

print("wg done")

let chan = Channel<Int>.make(capacity: 1)

go {
    try! chan.send(1)
    sleep(1)
    try! chan.send(1)
    sleep(1)
    
    go {
        sleep(1)
        try! chan.send(1)
    }
    
    go {
        sleep(1)
        try! chan.send(1)
    }
}

let sum = try! chan.receive() + chan.receive() + chan.receive() + chan.receive()
assert(sum == 4)
print("sum: \(sum)")
print("channel done")

Prorsum.run()
