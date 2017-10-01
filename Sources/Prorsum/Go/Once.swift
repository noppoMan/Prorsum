//
//  Once.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

import Foundation

public class Once {
    fileprivate let cond = Cond()
    
    private var done = false
    
    public func `do`(_ task: @escaping () -> Void){
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        
        if !done {
            done = true
            task()
        }
    }
}
