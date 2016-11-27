//
//  BodyStream.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/28.
//
//

public enum BodyStreamError : Error {
    case receiveUnsupported
}

final class BodyStream : DuplexStream {

    var isClosed = false
    
    let transport: DuplexStream
    
    init(_ transport: DuplexStream) {
        self.transport = transport
    }
    
    public func open(deadline: Double) throws {
        isClosed = false
    }
    
    func close() {
        isClosed = true
    }
    
    func read(upTo numOfBytes: Int, deadline: Double = 0) throws -> Bytes {
        throw BodyStreamError.receiveUnsupported
    }
    
    func write(_ bytes: Bytes, deadline: Double = 0) throws {
        guard !bytes.isEmpty else {
            return
        }
        
        if isClosed {
            throw StreamError.alreadyClosed
        }
        
        try transport.write(String(bytes.count, radix: 16).bytes, deadline: deadline)
        try transport.write("\r\n".bytes, deadline: deadline)
        try transport.write(bytes, deadline: deadline)
        try transport.write("\r\n".bytes, deadline: deadline)
    }
}
