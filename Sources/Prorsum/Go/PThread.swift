//
//  PThread.swift
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

import Foundation

public class Mutex {
    fileprivate var mutex: pthread_mutex_t
    
    public init(){
        mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
    }
    
    public func trylock() throws {
        let r = pthread_mutex_trylock(&mutex)
        if r != 0 {
            throw SystemError.lastOperationError!
        }
        
    }
    
    public func lock(){
        pthread_mutex_lock(&mutex)
    }
    
    public func unlock(){
        pthread_mutex_unlock(&mutex)
    }
    
    deinit{
        pthread_mutex_destroy(&mutex)
    }
}

public class Cond {
    
    let mutex = Mutex()
    
    fileprivate var cond: pthread_cond_t
    
    public convenience init(){
        self.init(mutext: Mutex())
    }
    
    public init(mutext: Mutex){
        cond = pthread_cond_t()
        pthread_cond_init(&cond, nil)
    }
    
    public func broadcast() {
        pthread_cond_broadcast(&cond)
    }
    
    public func wait(){
        pthread_cond_wait(&cond, &mutex.mutex)
    }
    
    public func timedwait(_ timeout: TimeInterval) throws {
        let ms = Int(timeout*1000)
        var tv = timeval()
        var ts = timespec()
        gettimeofday(&tv, nil)
        ts.tv_sec = time(nil) + ms / 1000
        let tmp = 1000 * 1000 * (ms % 1000)
        ts.tv_nsec = Int(tv.tv_usec * 1000 + tmp)
        ts.tv_sec += ts.tv_nsec / 1000000000
        ts.tv_nsec %= 1000000000
        
        let r = pthread_cond_timedwait(&cond, &mutex.mutex, &ts)
        if r != 0 {
            throw SystemError.lastOperationError ?? SystemError.operationTimedOut
        }
    }
    
    public func signal(){
        pthread_cond_signal(&cond)
    }
    
    deinit{
        pthread_cond_destroy(&cond)
    }
}
