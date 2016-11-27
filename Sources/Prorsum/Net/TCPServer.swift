//
//  TCPServer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/25.
//
//

import Foundation
import Dispatch

public class TCPServer {
    let socket: TCP
    
    let handler: (TCP) -> Void
    
    var watcher: DispatchSourceRead?
    
    let loop: CFRunLoop
    
    var isClosed: Bool {
        return socket.isClosed
    }
    
    private var onError: ((Error) -> Void)? = nil
    
    public init(_ handler: @escaping (TCP) -> Void) throws {
        socket = try TCP()
        self.handler = handler
        loop = CFRunLoopGetCurrent()
    }
    
    public func bind(host: String, port: UInt) throws {
        var reuseAddr = 1
        let r = setsockopt(
            socket.socket.fd,
            SOL_SOCKET,
            SO_REUSEADDR,
            &reuseAddr,
            socklen_t(MemoryLayout<Int>.stride)
        )
        
        if let error = SystemError(errorNumber: r) {
            throw error
        }
        
        try socket.bind(host: host, port: port)
    }
    
    public func listen(backlog: Int = 1024) throws {
        try socket.listen(backlog: backlog)
        
        watcher = DispatchSource.makeReadSource(fileDescriptor: socket.socket.fd, queue: .main)
        
        watcher?.setEventHandler { [unowned self] in
            do {
                let client = try self.socket.accept()
                go {
                    self.handler(client)
                }
            } catch {
                go {
                    self.onError?(error)
                }
            }
        }
        
        watcher?.resume()
        CFRunLoopRun()
    }
    
    public func onError(_ handler: @escaping (Error) -> Void){
        self.onError = handler
    }
    
    public func terminate(){
        watcher?.cancel()
        socket.close()
        
        CFRunLoopStop(loop)
    }
}
