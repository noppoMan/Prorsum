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

private protocol AnyContext {
    func couldReceiveMsgFromChannel() -> Bool
    func callWhenOrOtherwiseIfNeeded()
}

private class Context<T>: AnyContext {
    var when: ((T) -> Void)?
    var otherwise: (() -> Void)?
    var channel: Channel<T>?
    var message: T?

    init(chan: Channel<T>, when: @escaping (T) -> Void){
        self.channel = chan
        self.when = when
    }

    init(otherwise: @escaping () -> Void){
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
        for key in contexts.keys {
            if key != 0, let ctx = contexts[key], ctx.couldReceiveMsgFromChannel() {
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

        guard contexts[chan.id] == nil else { return }
        
        let context = Context<T>(chan: chan, when: handler)
        contexts[chan.id] = context
    }
    
    func otherwise(_ handler: @escaping () -> Void){
        cond.mutex.lock()
        defer {
            cond.mutex.unlock()
        }

        guard contexts[0] == nil else { return }

        contexts[0] = Context<Void>(otherwise: handler)
    }
}

public func forSelect(_ handler: (@escaping () -> Void) -> Void){
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

public func select(_ handler: () -> Void){
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

public func otherwise(_ handler: @escaping () -> Void){
    if let sel = Select.stack.front?.value {
        sel.otherwise(handler)
    }
}
