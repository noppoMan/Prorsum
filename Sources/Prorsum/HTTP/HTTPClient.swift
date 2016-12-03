//
//  HTTPClient.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

import Foundation

public enum HTTPClientError: Error {
    case invalidSchema
    case hostRequired
}

public class HTTPClient {
    
    let stream: TCPStream
    
    let url: URL
    
    public init(url: URL) throws {
        self.stream = try TCPStream()
        if url.scheme != "http" && url.scheme != "https" {
            throw HTTPClientError.invalidSchema
        }
        self.url = url
    }
    
    public func connect() throws {
        guard let host = url.host else {
            throw HTTPClientError.hostRequired
        }
        
        let hostname = try DNS(host: host).resolve()
        let port = url.scheme == "https" ? 443 : url.port ?? 80
        try self.stream.socket.connect(host: hostname, port: UInt(port))
    }
    
    public func request(method: Request.Method = .get, headers: Headers = [:], body: Data = Data(), deadline: Double = 0) throws -> Response {
        
        var request = Request(
            method: method,
            url: url,
            headers: headers,
            body: .buffer(body)
        )
        
        if request.userAgent == nil {
            request.userAgent = "Prorsum HTTP Client"
        }
        
        if !request.isKeepAlive {
            request.connection = "Close"
        }
        
        if request.host == nil {
           request.host = url.host
        }
        
        if request.accept.isEmpty {
            request.accept = [try MediaType(string: "Accept: */*")]
        }
        
        let serializer = RequestSerializer(stream: stream)
        try serializer.serialize(request, deadline: 0)
        
        let parser = MessageParser(mode: .response)
        
        while !stream.isClosed {
            guard let message = try parser.parse(stream.read()).first else {
                continue
            }
            
            return message as! Response
        }
        
        throw StreamError.alreadyClosed
    }
}
