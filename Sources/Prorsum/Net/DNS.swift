//
//  DNS.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

import Foundation

public enum DNSError: Error {
    case lookupFailed
}

public struct DNS {
    
    let host: CFHost
    
    public init(host: String){
        self.host = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
    }
    
    public func resolve() throws -> [Address] {
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as? NSArray else {
            throw DNSError.lookupFailed
        }
        
        let resolvedAddresses: [Address] = addresses.flatMap {
            guard let address = $0 as? NSData else {
                return nil
            }
            
            let addr = address.bytes.assumingMemoryBound(to: sockaddr.self)
            
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            
            let r = getnameinfo(
                address.bytes.assumingMemoryBound(to: sockaddr.self),
                socklen_t(address.length),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )
            
            guard r == 0 else {
                return nil
            }
            
            let family =  Int32(addr.pointee.sa_family) == PF_INET6 ? AddressFamily.inet6 : AddressFamily.inet
            return Address(host: String(cString: hostname), port: 0, addressFamily: family, isResolved: true)
        }
        
        if resolvedAddresses.isEmpty {
            throw DNSError.lookupFailed
        }
        
        return resolvedAddresses
    }
    
}
