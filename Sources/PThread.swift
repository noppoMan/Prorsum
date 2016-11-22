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

public class Mutex {
    var mutex: pthread_mutex_t
    
    public init(){
        mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
    }
}

public class Cond {
    var cond: pthread_cond_t
    
    public init(){
        cond = pthread_cond_t()
        pthread_cond_init(&cond, nil)
    }
    
    public func wait(_ mutex: Mutex){
        pthread_cond_wait(&cond, &mutex.mutex)
    }
    
    public func signal(){
        pthread_cond_signal(&cond)
    }
}

public class PThread {
    let mutex = Mutex()
    
    let cond = Cond()
    
    public func wait(){
        cond.wait(mutex)
    }
    
    public func signal(){
        cond.signal()
    }
}
