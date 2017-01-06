//
//  UDPSocket.swift
//  Prorsum
//
//  Created by Yuki Takei on 2017/01/05.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public class UDPSocket: SocketType {
    
    public let fd: Int32
    
    public let addressFamily: AddressFamily
    
    public let sockType: SockType
    
    public let protocolType: ProtocolType
    
    public var isClosed = false
    
    public init(fd: Int32, addressFamily: AddressFamily) throws {
        self.addressFamily = addressFamily
        self.sockType = .dgram
        self.protocolType = .udp
        self.fd = fd
    }
    
    public convenience init(addressFamily: AddressFamily) throws {
        let fd = sys_socket(addressFamily.rawValue, SockType.dgram.rawValue, 0)
        guard fd >= 0 else {
            throw SystemError.lastOperationError!
        }
        try self.init(fd: fd, addressFamily: addressFamily)
    }
    
    public func recvfrom(upTo numOfBytes: Int = 1024, deadline: Double = 0) throws -> (Bytes, Address) {
        if isClosed {
            throw SocketError.alreadyClosed
        }
        
        var buf = Bytes(repeating: 0, count: numOfBytes)
        var length = UInt32(MemoryLayout<sockaddr_storage>.size)
        let addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        let addrSockAddr = UnsafeMutablePointer<sockaddr>(OpaquePointer(addr))
        
        let bytesRead = sys_recvfrom(
            fd,
            &buf,
            numOfBytes,
            0,
            addrSockAddr,
            &length
        )
        
        guard bytesRead > -1 else {
            throw SystemError.lastOperationError!
        }
        
        let peer = try Address(raw: addr, isResolved: true)
        
        return (Bytes(buf[0..<bytesRead]), peer)
    }
    
    public func sendto(address: Address, bytes: Bytes) throws {
        if isClosed {
            throw SocketError.alreadyClosed
        }
        
        var address = address
        
        if !address.isResolved {
            address = try address.resolve(sockType: .dgram, protocolType: .udp)
        }
        
        let addr = address.rawaddr
        let len = address.len
        
        let r = sys_sendto(
            fd,
            bytes,
            bytes.count,
            0,
            addr,
            len
        )
        
        guard r == bytes.count else {
            throw SystemError.lastOperationError!
        }
    }
    
}
