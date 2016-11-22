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
    print("Hi dude")
    wg.done()
}

wg.wait()

print("done")

Prorsum.run()
