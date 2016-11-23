//
//  Channel.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//


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
}

public class Channel<T> {
    
    let id : Int
    
    var messages = [T]()
    
    public private(set) var capacity: Int
    
    let cond = Cond()
    
    public fileprivate(set) var isClosed = false
    
    // have to use Channel<T>.make() to initialize the Channel
    init(capacity: Int){
        self.capacity = capacity
        self.id = IDGenerator.shared.currentId()
    }
    
    public func count() -> Int{
        if capacity == 0 {
            return 0
        }
        
        return messages.count
    }
    
    func send(_ message: T) throws {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        
        if isClosed {
            throw ChannelError.sendOnClosedChannel
        }
        
        messages.append(message)
        cond.broadcast()
        
        while messages.count > capacity {
            cond.wait()
        }
    }
    
    public func nonBlockingReceive() throws -> T? {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        
        if messages.count > 0 {
            cond.broadcast()
            return messages.remove(at: 0)
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
            if messages.count > 0 {
                cond.broadcast()
                return messages.remove(at: 0)
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
