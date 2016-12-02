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
    
    public func resolve() throws -> String {
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? NSData else {
                throw DNSError.lookupFailed
        }
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        
        let r = getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
        
        guard r == 0 else {
            throw DNSError.lookupFailed
        }
        
        return String(cString: hostname)
    }
    
}
