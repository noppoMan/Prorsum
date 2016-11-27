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

public class Socket {
    
    public let fd: Int32
    
    public let addressFamily: AddressFamily
    
    public let sockType: SockType
    
    public init(fd: Int32, addressFamily: AddressFamily, sockType: SockType){
        self.addressFamily = addressFamily
        self.sockType = sockType
        self.fd = fd
    }
    
    public init(addressFamily: AddressFamily, sockType: SockType) throws {
        self.addressFamily = addressFamily
        self.sockType = sockType
        fd = sys_socket(addressFamily.rawValue, sockType.rawValue, 0)
        guard fd >= 0 else {
            throw SystemError.lastOperationError!
        }
    }
    
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
    
    public func close(){
        _ = sys_close(fd) // no error
    }
    
}
