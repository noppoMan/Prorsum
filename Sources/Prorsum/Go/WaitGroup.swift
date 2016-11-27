//
//  WaitGroup.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

import Foundation
import Dispatch

public enum WaitGroupError: Error {
    case negativeWaitGroupCount
}

public class WaitGrpup {
    
    let cond = Cond()
    
    var count = 0
    
    public init(){}
    
    public func add(_ delta: Int){
        cond.mutex.lock()
        count+=delta
        if count < 0 {
            swiftPanic(error: WaitGroupError.negativeWaitGroupCount)
        }
        cond.broadcast()
        cond.mutex.unlock()
    }
    
    public func wait(){
        cond.mutex.lock()
        while count > 0 {
            cond.wait()
        }
        cond.mutex.unlock()
    }
    
    public func done(){
        add(-1)
    }
}
