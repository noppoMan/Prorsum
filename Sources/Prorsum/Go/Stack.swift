//
//  Stack.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

class Stack<T> {
    
    var stackArray: [T]
    
    public var top: T? {
        return stackArray.first
    }
    
    public var count: Int {
        return stackArray.count
    }
    
    public init(){
        stackArray = [T]()
    }
    
    public func push(_ element: T) {
        stackArray.insert(element, at: 0)
    }
    
    @discardableResult
    public func pop() -> T? {
        if stackArray.count > 0 {
            return stackArray.removeFirst()
        } else {
            return nil
        }
    }
}

extension Stack: CustomStringConvertible {
    public var description: String {
        return "\(self.stackArray)"
    }
}

