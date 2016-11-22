//
//  main.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//


let wg = WaitGrpup()

wg.add(1)

go {
    print("Hi dude")
    wg.done()
}

wg.wait()

Prorsum.run()
