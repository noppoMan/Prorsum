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
    
    var cond: pthread_cond_t
    
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
    
    public func signal(){
        pthread_cond_signal(&cond)
    }
    
    deinit{
        pthread_cond_destroy(&cond)
    }
}
