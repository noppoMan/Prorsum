//
//  Stack.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

public class StackNode<T> {
    public let value: T
    public var next: StackNode?
    
    public init(_ newvalue: T) {
        self.value = newvalue
    }
}

public class Stack<T> {
    
    public typealias Element = T
    
    public private(set) var count = 0
    
    public private(set) var front: StackNode<Element>?
    
    public init () {}
    
    public func push(_ element: T) {
        let node = StackNode<T>(element)
        if front == nil {
            front = node
        } else {
            let prevFront = front
            front = node
            front?.next = prevFront
        }
        count+=1
    }
    
    @discardableResult
    public func pop() -> T? {
        if let front = self.front {
            self.front = self.front?.next
            count-=1
            return front.value
        } else {
            return nil
        }
    }
}

