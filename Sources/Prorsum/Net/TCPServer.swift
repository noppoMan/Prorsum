//
//  TCPServer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/25.
//
//

import Foundation
import Dispatch

private let sourceReadQ = DispatchQueue(label: "prorsum.net.source-read.queue")

private let tcpIncommingRequestHandleQ = DispatchQueue(label: "prorsum.tcp.concurrent-queue", attributes: .concurrent)

public final class TCPServer {
    let stream: TCPStream
    
    let handler: (TCPStream) -> Void
    
    var watcher: DispatchSourceRead?
    
    var isClosed: Bool {
        return stream.isClosed
    }
    
    var onError: ((Error) -> Void)? = nil
    
    public init(_ handler: @escaping (TCPStream) -> Void) throws {
        signal(SIGPIPE, SIG_IGN)
        stream = try TCPStream()
        self.handler = handler
    }
    
    public func bind(host: String, port: UInt) throws {
        var reuseAddr = 1
        let r = setsockopt(
            stream.socket.fd,
            SOL_SOCKET,
            SO_REUSEADDR,
            &reuseAddr,
            socklen_t(MemoryLayout<Int>.stride)
        )
        
        if let error = SystemError(errorNumber: r) {
            throw error
        }
        
        try stream.socket.bind(host: host, port: port)
    }
    
    public func listen(backlog: Int = 1024) throws {
        try stream.socket.listen(backlog: backlog)
        
        watcher = DispatchSource.makeReadSource(fileDescriptor: stream.socket.fd, queue: sourceReadQ)
        
        watcher?.setEventHandler { [unowned self] in
            tcpIncommingRequestHandleQ.async {
                do {
                    let client = try TCPStream(socket: self.stream.socket.accept())
                    self.handler(client)
                } catch {
                    self.onError?(error)
                }
            }
        }
        
        watcher?.resume()
    }
    
    public func onError(_ handler: @escaping (Error) -> Void){
        self.onError = handler
    }
    
    public func terminate(){
        watcher?.cancel()
        stream.socket.close()
    }
}
