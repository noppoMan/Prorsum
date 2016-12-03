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

/**
 An SSL Socket.
 */
public final class SSLSocket {
    public let socket: TCPSocket
    public let config: SSLConfig
    
    /**
     Creates a Socket from an SSL context and an
     unsecured socket's file descriptor.
     
     - parameter context: Re-usable SSL.Context in either Client or Server mode
     - parameter descriptor: The file descriptor from an unsecure socket already created.
     */
    public init(config: SSLConfig, socket: TCPSocket) throws {
        self.config = config
        self.socket = socket
    }
    
    public var currSocket: TCPSocket?
    public var currContext: OpaquePointer?
    public var lastError:String? {
        guard let context = currContext, let reason = tls_error(context) else {
            return nil
        }
        return String(validatingUTF8: reason)
    }
    
    public convenience init(
        mode: Mode,
        certificates: Certificates = .defaults,
        verifyHost: Bool = true,
        verifyCertificates: Bool = true,
        cipher: SSLConfig.Cipher = .compat,
        proto: [SSLConfig.TLSProtocol] = [.all]
        ) throws {
        let context = try SSLContext(mode: mode)
        let config = try SSLConfig(
            context: context,
            certificates: certificates,
            verifyHost: verifyHost,
            verifyCertificates: verifyCertificates,
            cipher: cipher,
            proto: proto
        )
        
        let socket = try TCPSocket()
        
        try self.init(config: config, socket: socket)
    }
    
    
    /**
     Connects to an SSL server from this client.
     
     This should only be called if the Context's mode is `.client`
     */
    public func connect(hostname: String, port: UInt16 = 443) throws {
        try socket.connect(host: hostname, port: UInt(port))
        let connectResult = tls_connect_socket(
            config.context.cContext,
            socket.fd,
            hostname
        )
        currSocket = socket
        currContext = config.context.cContext
        
        guard connectResult == Result.OK else {
            throw TLSError.connect(lastError ?? "Unknown")
        }
        
        // handshake is performed automatically when using tls_read or tls_write, but by doing it here, handshake errors can be properly reported
        guard tls_handshake(config.context.cContext) == Result.OK else {
            throw TLSError.handshake(lastError ?? "Unknown")
        }
    }
    
    /**
     Accepts a connection to this SSL server from a client.
     
     This should only be called if the Context's mode is `.server`
     */
    public func accept() throws {
        let new = try socket.accept()
        let result = tls_accept_socket(
            config.context.cContext,
            &currContext,
            new.fd
        )
        currSocket = new
        
        guard result == Result.OK else {
            new.close()
            throw TLSError.accept(config.context.error)
        }
        
        // handshake is performed automatically when using tls_read or tls_write, but by doing it here, handshake errors can be properly reported
        guard tls_handshake(currContext) == Result.OK else {
            new.close()
            throw TLSError.handshake(lastError ?? "Unknown")
        }
    }
    
    /**
     Receives bytes from the secure socket.
     
     - parameter max: The maximum amount of bytes to receive.
     */
    public func receive(max: Int) throws -> [UInt8]  {
        guard let context = currContext else {
            throw TLSError.receive("Context is nil")
        }
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: max)
        defer {
            pointer.deallocate(capacity: max)
        }
        
        let result = tls_read(context, pointer, max)
        let bytesRead = Int(result)
        
        guard bytesRead >= 0 else {
            throw TLSError.receive(lastError ?? "Unknown")
        }
        
        let buffer = UnsafeBufferPointer<UInt8>.init(start: pointer, count: bytesRead)
        return Array(buffer)
    }
    
    /**
     Sends bytes to the secure socket.
     
     - parameter bytes: An array of bytes to send.
     */
    public func send(_ bytes: [UInt8]) throws {
        guard let context = currContext else {
            throw TLSError.send("Context is nil")
        }
        
        var totalBytesSent = 0
        let buffer = UnsafeBufferPointer<UInt8>(start: bytes, count: bytes.count)
        guard let bufferBaseAddress = buffer.baseAddress else {
            throw TLSError.send("Failed to get buffer base address")
        }
        
        while totalBytesSent < bytes.count {
            let bytesSent = tls_write(context, bufferBaseAddress.advanced(by: totalBytesSent), bytes.count - totalBytesSent)
            if bytesSent <= 0 {
                throw TLSError.send(lastError ?? "Unknown")
            }
            totalBytesSent += bytesSent
        }
    }
    
    /**
     Sends a shutdown to secure socket
     */
    public func close() throws {
        var result = Result.OK
        if let context = currContext {
            result = tls_close(context)
        }
        currSocket?.close()
        guard result == Result.OK else {
            throw TLSError.close(lastError ?? "Unknown")
        }
    }
}
