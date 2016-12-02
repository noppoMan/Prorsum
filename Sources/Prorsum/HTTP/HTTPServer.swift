#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation

public final class HTTPServer {
    
    var server: TCPServer? = nil
    
    public init(_ handler: @escaping (Request, ResponrWriter) -> Void) throws {
        server = try TCPServer { [unowned self] clientSocket in
            do {
                let parser = MessageParser(mode: .request)
                
                while !clientSocket.isClosed {
                    let bytes = try clientSocket.read()
                    for message in try parser.parse(bytes) {
                        handler(message as! Request, ResponrWriter(stream: clientSocket))
                    }
                }
            } catch {
                self.server?.onError?(error)
                clientSocket.close()
            }
        }
    }
    
    public func onError(_ handler: @escaping (Error) -> Void) {
        server?.onError(handler)
    }
    
    public func bind(host: String, port: UInt) throws {
        try server?.bind(host: host, port: port)
    }
    
    public func listen(backlog: Int = 1024) throws {
        try server?.listen(backlog: backlog)
    }
    
}
