//
//  AIError.swift
//  AWSSDKSwift
//
//  Created by Yuki Takei on 2017/04/21.
//
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public enum AIError: Error {
    // address
    case addressfamily
    case again
    case badflags
    case fail
    case family
    case memory
    case nodata
    case nonname
    case service
    case socktype
    case system
}

extension AIError {
    public init?(errorNumber: Int32) {
        switch errorNumber {
        case EAI_ADDRFAMILY: self = .addressfamily
        case EAI_AGAIN: self = .again
        case EAI_BADFLAGS: self = .badflags
        case EAI_FAIL: self = .fail
        case EAI_FAMILY: self = .family
        case EAI_MEMORY: self = .memory
        case EAI_NODATA: self = .nodata
        case EAI_NONAME: self = .nonname
        case EAI_SERVICE: self = .service
        case EAI_SOCKTYPE: self = .socktype
        case EAI_SYSTEM: self = .system
        default:
            return nil
        }
    }
    
    public var errorNumber: Int32 {
        switch self {
        case .addressfamily:
            return EAI_ADDRFAMILY
        case .again:
            return EAI_AGAIN
        case .badflags:
            return EAI_BADFLAGS
        case .fail:
            return EAI_FAIL
        case .family:
            return EAI_FAMILY
        case .memory:
            return EAI_MEMORY
        case .nodata:
            return EAI_NODATA
        case .nonname:
            return EAI_NONAME
        case .service:
            return EAI_SERVICE
        case .socktype:
            return EAI_SOCKTYPE
        case .system:
            return EAI_SYSTEM
        }
    }
}

extension AIError {
    public static func description(for errorNumber: Int32) -> String {
        return String(cString:  gai_strerror(errorNumber))
    }
}

extension AIError : CustomStringConvertible {
    public var description: String {
        return AIError.description(for: self.errorNumber)
    }
}
