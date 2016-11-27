//
//  Stream.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/25.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation
import Dispatch

public enum StreamError: Error {
    case alreadyClosed
}

public protocol ReadableStream: class {
    var socket: Socket { get }
//    var io: DispatchIO { get }
    var isClosed: Bool { get set }
    func read(upTo numOfBytes: Int) throws -> Bytes
    func close()
}

extension ReadableStream {
    
    public func read(upTo numOfBytes: Int = 1024) throws -> Bytes {
        if isClosed {
            throw StreamError.alreadyClosed
        }
        
        try self.socket.setBlocking(shouldBlock: true)
        
        var buf = Bytes(repeating: 0, count: numOfBytes)
        let bytesRead = Darwin.recv(socket.fd, &buf, numOfBytes, 0)
        
        guard bytesRead > -1 else {
            throw SystemError.lastOperationError!
        }
        
        if bytesRead == 0 {
            isClosed = true
        }
        
        return Bytes(buf[0..<bytesRead])
    }
}

public protocol WritableStream {
    var socket: Socket { get }
//    var io: DispatchIO { get }
    var isClosed: Bool { get }
    func write(_ bytes: Bytes) throws
    func close()
}


extension WritableStream {
    
    public func write(_ bytes: Bytes) throws {
        if isClosed {
            throw StreamError.alreadyClosed
        }
        
        let len = bytes.count
        let result = send(socket.fd, bytes, len, Int32(SOCK_NOSIGNAL))
        guard result == len else {
            throw SystemError.lastOperationError!
        }

    }
}
