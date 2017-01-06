//
//  Socket.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/24.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import Dispatch

public enum SockType {
    case stream
    case dgram
    case seqPacket
    case raw
    case rdm
}

extension SockType {
    var rawValue: Int32 {
        switch self {
        case .stream:
            return SOCK_STREAM
        case .dgram:
            return SOCK_DGRAM
        case .seqPacket:
            return SOCK_SEQPACKET
        case .raw:
            return SOCK_RAW
        case .rdm:
            return SOCK_RDM
        }
    }
}

public enum ProtocolType {
    case tcp
    case udp
}

extension ProtocolType {
    var rawValue: Int32 {
        switch self {
        case .tcp:
            return IPPROTO_TCP
        case .udp:
            return IPPROTO_UDP
        }
    }
}


public enum SocketError: Error {
    case alreadyClosed
}

public protocol SocketType: class {
    var fd: Int32 { get }
    var addressFamily: AddressFamily { get }
    var sockType: SockType { get }
    var protocolType: ProtocolType { get }
    var isClosed: Bool { get set }
}

extension SocketType {
    
    public func setBlocking(shouldBlock: Bool) throws {
        let flags = fcntl(fd, F_GETFL, 0)
        if flags < 0 {
            throw SystemError.lastOperationError!
        }
        
        let result = fcntl(fd, F_SETFL, (shouldBlock ? flags & ~O_NONBLOCK: flags | O_NONBLOCK))
        
        if result < 0 {
            throw SystemError.lastOperationError!
        }
    }
    
    public func connect(host: String, port: UInt) throws {
        try setBlocking(shouldBlock: true)
        
        let address = Address(host: host, port: port, addressFamily: .inet)
        let resolvedAddress = try address.resolve(sockType: sockType, protocolType: protocolType)
        
        let r = sys_connect(fd, resolvedAddress.rawaddr!, resolvedAddress.len)
        if r < 0 {
            throw SystemError.lastOperationError!
        }
    }
    
    public func bind(host: String, port: UInt) throws {
        let addr = Address(host: host, port: port, addressFamily: addressFamily)
        let resolvedAddr = try addr.resolve(sockType: sockType, protocolType: protocolType)
        
        let r = sys_bind(fd, resolvedAddr.rawaddr!, resolvedAddr.len)
        
        if r != 0 {
            throw SystemError.lastOperationError!
        }
    }
    
    public func close(){
        _ = sys_close(fd) // no error
        self.isClosed = true
    }
}

public class Socket: SocketType {
    
    public let fd: Int32
    
    public let addressFamily: AddressFamily
    
    public let sockType: SockType
    
    public let protocolType: ProtocolType
    
    public var isClosed = false
    
    public init(fd: Int32, addressFamily: AddressFamily, sockType: SockType, protocolType: ProtocolType){
        self.addressFamily = addressFamily
        self.sockType = sockType
        self.protocolType = protocolType
        self.fd = fd
    }
    
    public convenience init(addressFamily: AddressFamily, sockType: SockType, protocolType: ProtocolType) throws {
        let fd = sys_socket(addressFamily.rawValue, sockType.rawValue, 0)
        guard fd >= 0 else {
            throw SystemError.lastOperationError!
        }
        self.init(fd: fd, addressFamily: addressFamily, sockType: sockType, protocolType: protocolType)
    }
    
    public func recv(upTo numOfBytes: Int = 1024, deadline: Double = 0) throws -> Bytes {
        if isClosed {
            throw SocketError.alreadyClosed
        }
        
        try self.setBlocking(shouldBlock: true)
        
        var buf = Bytes(repeating: 0, count: numOfBytes)
        let bytesRead = sys_recv(fd, &buf, numOfBytes, 0)
        
        guard bytesRead > -1 else {
            throw SystemError.lastOperationError!
        }
        
        if bytesRead == 0 {
            isClosed = true
        }
        
        return Bytes(buf[0..<bytesRead])
    }
    
    public func send(_ bytes: Bytes, deadline: Double = 0) throws {
        if isClosed {
            throw SocketError.alreadyClosed
        }
        
        let len = bytes.count
        let result = sys_send(fd, bytes, len, Int32(SOCK_NOSIGNAL))
        guard result == len else {
            throw SystemError.lastOperationError!
        }
    }
    
    public func listen(backlog: Int = 1024) throws {
        let r = sys_listen(fd, Int32(backlog))
        if r != 0 {
            throw SystemError.lastOperationError!
        }
    }
}
