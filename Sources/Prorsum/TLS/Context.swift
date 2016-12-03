//The MIT License (MIT)
//
//Copyright (c) 2016 Honza Dvorsky
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.


import CLibreSSL
import Foundation

/**
 An SSL context that contains the
 optional certificates as well as references
 to all initialized SSL libraries and configurations.
 The context is used to create secure sockets and should
 be reused when creating multiple sockets.
 */

public final class SSLContext {
    public typealias CContext = OpaquePointer
    public let mode: Mode
    public var cContext: CContext
    
    static let initializeTlsOnce = {
        tls_init()
    }()
    
    /**
     Creates an SSL Context.
     - parameter mode: Client or Server.
     - parameter certificates: The certificates for the Client or Server.
     */
    public init(mode: Mode) throws {
        _ = SSLContext.initializeTlsOnce
        
        switch mode {
        case .server:
            cContext = tls_server()
        case .client:
            cContext = tls_client()
        }
        
        self.mode = mode
    }
    
    deinit {
        tls_free(cContext)
    }
    
    /**
     The last error emitted using
     this context.
     */
    public var error: String {
        let string: String
        
        if let reason = tls_error(cContext) {
            string = String(validatingUTF8: reason) ?? "Unknown"
        } else {
            string = "Unknown"
        }
        
        return string
    }
}
