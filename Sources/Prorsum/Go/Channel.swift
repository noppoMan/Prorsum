//
//  Channel.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

import Foundation.NSThread

class IDGenerator {
    static let shared = IDGenerator()
    
    private var _currentId = 0
    
    private let mutex = Mutex()
    
    init(){}
    
    func currentId() -> Int {
        mutex.lock()
        _currentId+=1
        mutex.unlock()
        return _currentId
    }
}

public enum ChannelError: Error {
    case receivedOnClosedChannel
    case sendOnClosedChannel
    case bufferSizeLimitExceeded(Int)
}

public class Channel<T> {
    
    let id : Int
    
    var messageQ = Queue<T>()
    
    public private(set) var capacity: Int
    
    let cond = Cond()
    
    public fileprivate(set) var isClosed = false
    
    // have to use Channel<T>.make() to initialize the Channel
    init(capacity: Int){
        self.capacity = capacity
        self.id = IDGenerator.shared.currentId()
    }
    
    public func count() -> Int {
        if capacity == 0 {
            return 0
        }
        
        return messageQ.count
    }
    
    public func send(_ message: T) throws {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        
        if isClosed {
            throw ChannelError.sendOnClosedChannel
        }
        
        messageQ.push(message)
        cond.broadcast()
        
        if Thread.current.isMainThread, messageQ.count > capacity {
            throw ChannelError.bufferSizeLimitExceeded(capacity)
        }
    }
    
    public func nonBlockingReceive() throws -> T? {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }

        if let f = messageQ.front {
            messageQ.pop()
            cond.broadcast()
            return f.value
        }
        
        if isClosed {
            throw ChannelError.receivedOnClosedChannel
        }
        
        return nil
    }
    
    public func receive() throws -> T {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        
        while true {
            if let f = messageQ.front {
                messageQ.pop()
                cond.broadcast()
                return f.value
            }
            
            if isClosed {
                throw ChannelError.receivedOnClosedChannel
            }
            cond.wait()
        }
    }
    
    public func close(){
        cond.mutex.lock()
        isClosed = true
        cond.mutex.unlock()
    }
}

extension Channel {
    public static func make(capacity: Int = 0) -> Channel<T> {
        return Channel<T>(capacity: capacity)
    }
}
