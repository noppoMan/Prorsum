#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation

public final class HTTPServer {
    
    var server: TCPServer? = nil
    
    var onError: ((Error) -> Void)? = nil
    
    public init(_ handler: @escaping (Request, ResponrWriter) -> Void) throws {
        server = try TCPServer { [weak self] clientStream in
            do {
                let parser = MessageParser(mode: .request)
                
                while !clientStream.isClosed {
                    let bytes = try clientStream.read()
                    for message in try parser.parse(bytes) {
                        handler(message as! Request, ResponrWriter(stream: clientStream))
                    }
                }
            } catch {
                self?.onError?(error)
                clientStream.close()
            }
        }
    }
    
    public func onError(_ handler: @escaping (Error) -> Void) {
        server?.onError(handler)
        onError = handler
    }
    
    public func bind(host: String, port: UInt) throws {
        try server?.bind(host: host, port: port)
    }
    
    public func listen(backlog: Int = 1024) throws {
        try server?.listen(backlog: backlog)
    }
    
    public func terminate() {
        server?.terminate()
    }
    
}
