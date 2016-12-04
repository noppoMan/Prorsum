//
//  GoRoutine.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/23.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

func randomInts(max : Int, addition: Int = 0) -> [Int]{
    var ints = [Int](repeating:0, count: max)
    for i in 0..<max {
        ints[i] = i + addition
    }
    for i in 0..<max {
        let r = Int(arc4random()) % max
        let t = ints[i]
        ints[i] = ints[r]
        ints[r] = t
    }
    return ints
}


private protocol AnyContext {
    func couldReceiveMsgFromChannel() -> Bool
    func callWhenOrOtherwiseIfNeeded()
}

private class Context<T>: AnyContext {
    var when: ((T) -> Void)?
    var otherwise: ((Void) -> Void)?
    var channel: Channel<T>?
    var message: T?

    init(chan: Channel<T>, when: @escaping (T) -> Void){
        self.channel = chan
        self.when = when
    }

    init(otherwise: @escaping (Void) -> Void){
        self.otherwise = otherwise
    }
    
    func couldReceiveMsgFromChannel() -> Bool {
        guard let ch = channel else {
            return false
        }
        
        do {
            message = try ch.nonBlockingReceive()
            return message != nil
        } catch {
            return false
        }
    }

    func callWhenOrOtherwiseIfNeeded(){
        if let when = when, let message = message {
            when(message)
        } else {
            otherwise?()
        }
    }
}

private class Select {
    
    static var stack = Stack<Select>()
    
    static let mutex = Mutex()
    
    let cond = Cond()

    var contexts = [Int: AnyContext]()
    
    init(){}
    
    func select(){
        for i in randomInts(max: contexts.count, addition: 1) {
            if let ctx = contexts[i], ctx.couldReceiveMsgFromChannel() {
                ctx.callWhenOrOtherwiseIfNeeded()
                return
            }
        }
        
        if let ctx = contexts[0] {
            ctx.callWhenOrOtherwiseIfNeeded()
            return
        }
        
        cond.mutex.lock()
        cond.wait(timeout: 0.25)
        cond.mutex.unlock()
    }
    
    func when<T>(_ chan: Channel<T>, _ handler: @escaping (T) -> Void) {
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        
        if contexts[chan.id] != nil {
            return
        }
        
        let context = Context<T>(chan: chan, when: handler)
        contexts[chan.id] = context
    }
    
    func otherwise(_ handler: @escaping (Void) -> Void){
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }
        if contexts[0] != nil {
            return
        }
        contexts[0] = Context<Void>(otherwise: handler)
    }
}

public func forSelect(_ handler: (@escaping (Void) -> Void) -> Void){
    var done = false
    let _done = {
        Select.mutex.lock()
        done = true
        Select.mutex.unlock()
    }
    let sel = Select()
    while done == false {
        Select.mutex.lock()
        Select.stack.pop()
        Select.stack.push(sel)
        handler(_done)
        Select.mutex.unlock()
        sel.select()
    }
}

public func select(_ handler: (Void) -> Void){
    let sel = Select()
    Select.mutex.lock()
    Select.stack.pop()
    Select.stack.push(sel)
    handler()
    Select.mutex.unlock()
    sel.select()
}

public func when<T>(_ chan: Channel<T>, _ handler: @escaping (T) -> Void){
    if let sel = Select.stack.front?.value {
        sel.when(chan, handler)
    }
}

public func otherwise(_ handler: @escaping (Void) -> Void){
    if let sel = Select.stack.front?.value {
        sel.otherwise(handler)
    }
}
