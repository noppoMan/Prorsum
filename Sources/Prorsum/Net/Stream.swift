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
    var isClosed: Bool { get set }
    func read(upTo numOfBytes: Int, deadline: Double) throws -> Bytes
    func close()
}

extension ReadableStream {
    public func read(upTo numOfBytes: Int) throws -> Bytes {
        return try self.read(upTo: numOfBytes, deadline: 0)
    }
}

public protocol ReadableIOStream: ReadableStream {
    var socket: Socket { get }
    //    var io: DispatchIO { get }
}

extension ReadableIOStream {
    
    public func read(upTo numOfBytes: Int = 1024, deadline: Double = 0) throws -> Bytes {
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
    var isClosed: Bool { get }
    func write(_ bytes: Bytes, deadline: Double) throws
    func close()
}

extension WritableStream {
    public func write(_ bytes: Bytes) throws {
        try self.write(bytes, deadline: 0)
    }
}

public protocol WritableIOStream: WritableStream {
    var socket: Socket { get }
    //    var io: DispatchIO { get }
}

extension WritableIOStream {
    
    public func write(_ bytes: Bytes, deadline: Double = 0) throws {
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

public typealias DuplexStream = ReadableStream & WritableStream

public typealias DuplexIOStream = ReadableIOStream & WritableIOStream
