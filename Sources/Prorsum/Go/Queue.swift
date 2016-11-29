//
//  Queue.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/29.
//
//

public class QueueNode<T> {
    public let value: T
    public var next: QueueNode?
    
    public init(_ newvalue: T) {
        self.value = newvalue
    }
}

public class Queue<T> {
    
    public typealias Element = T
    
    public private(set) var count = 0
    
    public private(set) var front: QueueNode<Element>?
    
    public private(set) var back: QueueNode<Element>?
    
    public init () {
        back = nil
        front = back
    }
    
    public func push (_ value: Element) {
        let prevBack = back
        back = QueueNode<T>(value)
        if front == nil {
            front = back
        } else {
            prevBack?.next = back
        }
        count+=1
    }
    
    @discardableResult
    public func pop () -> Element? {
        if let newhead = self.front {
            self.front = newhead.next
            if newhead.next == nil {
                back = nil
            }
            count-=1
            return newhead.value
        } else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        return count > 0
    }
}
