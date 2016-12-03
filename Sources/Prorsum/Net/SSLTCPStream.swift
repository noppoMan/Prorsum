//
//  SSLTCPStream.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

public class SSLTCPStream: DuplexStream {
    
    let socket: SSLSocket
    
    private var _isClosed = false
    
    public var isClosed: Bool {
        return _isClosed
    }
    
    private var address: Address?
    
    public init(socket: SSLSocket) {
        self.socket = socket
    }
    
    public convenience init(host: String, port: UInt) throws {
        try self.init(config: SSLConfig(mode: .client))
        self.address = Address(host: host, port: port)
    }
    
    public convenience init(config: SSLConfig) throws {
        try self.init(socket: SSLSocket(config: config, socket: TCPSocket()))
    }
    
    public func open(deadline: Double = 0) throws {
        guard let address = self.address else {
            throw StreamError.couldNotOpen
        }
        try self.socket.connect(hostname: address.host)
    }
    
    public func read(upTo numOfBytes: Int = 1024, deadline: Double = 0) throws -> Bytes {
        return try socket.receive(max: numOfBytes)
    }
    
    public func write(_ bytes: Bytes, deadline: Double = 0) throws {
        try socket.send(bytes)
    }
    
    public func close() {
        do { try socket.close() } catch {}
        _isClosed = true
    }
    
}

