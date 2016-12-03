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
    case couldNotOpen
}

public protocol ReadableStream: class {
    var isClosed: Bool { get }
    func open(deadline: Double) throws
    func read(upTo numOfBytes: Int, deadline: Double) throws -> Bytes
    func close()
}

extension ReadableStream {
    public func read(upTo numOfBytes: Int) throws -> Bytes {
        return try self.read(upTo: numOfBytes, deadline: 0)
    }
}

public protocol WritableStream {
    var isClosed: Bool { get }
    func open(deadline: Double) throws
    func write(_ bytes: Bytes, deadline: Double) throws
    func close()
}

extension WritableStream {
    public func write(_ bytes: Bytes) throws {
        try self.write(bytes, deadline: 0)
    }
}

public typealias DuplexStream = ReadableStream & WritableStream
