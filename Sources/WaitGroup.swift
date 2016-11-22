//
//  WaitGroup.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

public class WaitGrpup {
    
    var threads = [PThread]()
    
    public init(){}
    
    public func add(_ i: Int){
        for _  in 0..<i {
            threads.append(PThread())
        }
    }
    
    public func wait(){
        for i in 0..<threads.count {
            threads[i].wait()
        }
    }
    
    public func done(){
        if let thread = threads.popLast() {
            thread.signal()
        }
    }
}
