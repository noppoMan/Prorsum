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
        try self.init(addressFamily: addressFamily, sockType: .stream, protocolType: .tcp)
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
        
        return TCPSocket(fd: clientFD, addressFamily: .inet, sockType: sockType, protocolType: protocolType)
    }
}
