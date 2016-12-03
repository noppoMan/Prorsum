//
//  TCP.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/25.
//
//


#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Dispatch

public final class TCPSocket: Socket {
    
    //public let io: DispatchIO // for async i/o
    
//    public init(socket: Socket) {
//        self.socket = socket
//        io = DispatchIO(type: .stream, fileDescriptor: socket.fd, queue: .main) { _errorno in
//            if let error = SystemError(errorNumber: _errorno) {
//                fatalError("\(error)")
//            }
//        }
//    }
    
    public convenience init(addressFamily: AddressFamily = .inet) throws {
        try self.init(addressFamily: addressFamily, sockType: .stream)
    }
    
    public func accept() throws -> TCPSocket {
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        defer {
            addr.deallocate(capacity: 1)
        }
    
        let clientFD = sys_accept(fd, addrSockAddr, &length)
        
        guard fd > -1 else {
            throw SystemError.lastOperationError!
        }
        
        return TCPSocket(fd: clientFD, addressFamily: .inet, sockType: .stream)
    }
    
    public func bind(host: String, port: UInt) throws {
        let addr = Address(host: host, port: port, addressFamily: .inet)
        let resolvedAddr = try addr.resolve(sockType: .stream, protocolType: IPPROTO_TCP)
        
        let r = sys_bind(fd, resolvedAddr.rawaddr!, resolvedAddr.len)
        
        if r != 0 {
            throw SystemError.lastOperationError!
        }
    }
    
    public func listen(backlog: Int = 1024) throws {
        let r = sys_listen(fd, Int32(backlog))
        if r != 0 {
            throw SystemError.lastOperationError!
        }
    }
    
    public func connect(host: String, port: UInt) throws {
        try setBlocking(shouldBlock: true)
        
        let address = Address(host: host, port: port, addressFamily: .inet)
        let resolvedAddress = try address.resolve(sockType: .stream, protocolType: IPPROTO_TCP)
        
        let r = sys_connect(fd, resolvedAddress.rawaddr!, resolvedAddress.len)
        if r < 0 {
            throw SystemError.lastOperationError!
        }
    }
}
