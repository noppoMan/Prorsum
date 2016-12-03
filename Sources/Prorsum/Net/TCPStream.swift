//
//  TCPClient.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

public class TCPStream: DuplexStream {
    
    let socket: TCPSocket
    
    public var isClosed: Bool {
        return socket.isClosed
    }
    
    public init(socket: TCPSocket) throws {
        self.socket = socket
    }
    
    public convenience init() throws {
        try self.init(socket: TCPSocket())
    }
    
    public func open(deadline: Double) throws {
        throw StreamError.couldNotOpen
    }
    
    public func read(upTo numOfBytes: Int = 1024, deadline: Double = 0) throws -> Bytes {
        return try socket.recv(upTo: numOfBytes, deadline: deadline)
    }
    
    public func write(_ bytes: Bytes, deadline: Double = 0) throws {
        return try socket.send(bytes, deadline: deadline)
    }
    
    public func close() {
        socket.close()
    }
    
}
