//
//  Address.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/27.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation

public enum AddressFamily {
    case unix
    case inet
    case inet6
    case ipx
    case netlink
}

extension AddressFamily {
    public init?(value: Int32){
        switch value {
        case AF_UNIX:
            self = .unix
        case AF_INET:
            self = .inet
        case AF_INET6:
            self = .inet6
        case AF_IPX:
            self = .ipx
        case AF_APPLETALK:
            self = .netlink
        default:
            return nil
        }
    }
    
    public var rawValue: Int32 {
        switch self {
        case .unix:
            return AF_UNIX
        case .inet:
            return AF_INET
        case .inet6:
            return AF_INET6
        case .ipx:
            return AF_IPX
        case .netlink:
            return AF_APPLETALK
        }
    }
}

public enum AddressError: Error {
    case ipAddressResolutionFailed
    case unsupportedAddressFamily
    case addressIsAlreadyResolved
    case unknownAddressFamily
}

public class Address {
    
    public let host: String
    
    public let port: UInt
    
    public let addressFamily: AddressFamily
    
    public private(set) var isResolved = false
    
    private(set) var sockStorageRef: UnsafeMutablePointer<sockaddr_storage>?
    
    var rawaddr: UnsafeMutablePointer<sockaddr>? {
        guard let sockStorageRef = sockStorageRef else {
            return nil
        }
        return UnsafeMutablePointer<sockaddr>(OpaquePointer(sockStorageRef))
    }
    
    public init(host: String, port: UInt, addressFamily: AddressFamily = .inet, isResolved: Bool = false){
        self.host = host
        self.port = port
        self.addressFamily = addressFamily
        self.isResolved = isResolved
    }
    
    public var len: socklen_t {
        switch addressFamily {
        case .inet: return socklen_t(MemoryLayout<sockaddr_in>.size)
        case .inet6: return socklen_t(MemoryLayout<sockaddr_in6>.size)
        default: return 0
        }
    }
    
    public init(raw: UnsafeMutablePointer<sockaddr_storage>, addressFamily: AddressFamily = .inet, isResolved: Bool = false) throws {
        
        self.sockStorageRef = raw
        
        switch addressFamily {
        case .inet:
            let maxLen = socklen_t(INET_ADDRSTRLEN)
            let strData = UnsafeMutablePointer<Int8>.allocate(capacity: Int(maxLen))
            var ptr = UnsafeMutablePointer<sockaddr_in>(OpaquePointer(raw)).pointee.sin_addr
            inet_ntop(addressFamily.rawValue, &ptr, strData, maxLen)
            let port = UnsafePointer<sockaddr_in>(OpaquePointer(raw)).pointee.sin_port
            
            self.host = String(validatingUTF8: strData)!
            self.port = UInt(port)
            self.addressFamily = addressFamily
            self.isResolved = isResolved
            
            strData.deallocate(capacity: Int(maxLen))
            
        case .inet6:
            let maxLen = socklen_t(INET6_ADDRSTRLEN)
            let strData = UnsafeMutablePointer<Int8>.allocate(capacity: Int(maxLen))
            var ptr = UnsafeMutablePointer<sockaddr_in6>(OpaquePointer(raw)).pointee.sin6_addr
            inet_ntop(addressFamily.rawValue, &ptr, strData, maxLen)
            let port = UnsafePointer<sockaddr_in6>(OpaquePointer(raw)).pointee.sin6_port
            
            self.host = String(validatingUTF8: strData)!
            self.port = UInt(port)
            self.addressFamily = addressFamily
            self.isResolved = isResolved
            
            strData.deallocate(capacity: Int(maxLen))
        default:
            throw AddressError.unsupportedAddressFamily
        }
    }
    
    public func resolve(sockType: SockType, protocolType: ProtocolType) throws -> Address {
        if isResolved {
            throw AddressError.addressIsAlreadyResolved
        }
        
        var addrInfoRef: UnsafeMutablePointer<addrinfo>?
        var hints = addrinfo()
        hints.ai_flags = AI_PASSIVE
        hints.ai_family = addressFamily.rawValue
        hints.ai_socktype = sockType.rawValue
        hints.ai_protocol = protocolType.rawValue
        hints.ai_addrlen = 0

        let ret = getaddrinfo(host, String(port), &hints, &addrInfoRef)
        guard ret == 0 else {
            throw SystemError.lastOperationError!
        }
        
        guard let addrList = addrInfoRef else {
            throw AddressError.ipAddressResolutionFailed
        }
        
        guard let addrInfo = addrList.pointee.ai_addr else {
            throw AddressError.ipAddressResolutionFailed
        }
        
        guard let family = AddressFamily(value: Int32(addrInfo.pointee.sa_family)) else {
            throw AddressError.unknownAddressFamily
        }
        
        let sockStorageRef = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        sockStorageRef.initialize(to: sockaddr_storage())
        
        let address: Address?
        switch family {
        case .inet:
            let addr = UnsafeMutablePointer<sockaddr_in>.init(OpaquePointer(addrInfo))!
            let specPtr = UnsafeMutablePointer<sockaddr_in>(OpaquePointer(sockStorageRef))
            specPtr.assign(from: addr, count: 1)
            address = try Address(raw: sockStorageRef, addressFamily: .inet, isResolved: true)
            
        case .inet6:
            let addr = UnsafeMutablePointer<sockaddr_in6>.init(OpaquePointer(addrInfo))!
            let specPtr = UnsafeMutablePointer<sockaddr_in6>(OpaquePointer(sockStorageRef))
            specPtr.assign(from: addr, count: 1)
            address = try Address(raw: sockStorageRef, addressFamily: .inet, isResolved: true)
        default:
            throw AddressError.unsupportedAddressFamily
        }
        
        freeaddrinfo(addrList)
        
        return address!
    }
    
    deinit {
        sockStorageRef?.deallocate(capacity: 1)
    }
}


extension Collection where Self.Iterator.Element == Address {
    
    public func inets() -> [Address] {
        return self.filter {
            switch $0.addressFamily {
            case .inet:
                return true
            default:
                return false
            }
        }
    }
    
    public func inet6s() -> [Address] {
        return self.filter {
            switch $0.addressFamily {
            case .inet6:
                return true
            default:
                return false
            }
        }
    }
}
