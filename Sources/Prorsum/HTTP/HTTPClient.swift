//
//  HTTPClient.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

import Foundation
import SSLService

public enum HTTPClientError: Error {
    case invalidSchema
    case hostRequired
    case maxRedirectionExceeded(max: Int)
}

public class HTTPClient {
    
    public static var maxRedirection = 10
    
    let stream: DuplexStream
    
    public private(set) var url: URL
    
    public var followRedirect = true
    
    private var currentRedirectCount = 0
    
    public let isSecure: Bool
    
    public var port: UInt {
        return isSecure ? 443 : UInt(url.port ?? 80)
    }
    
    private convenience init(url: URL, redirectCount: Int = 0) throws {
        if redirectCount >= HTTPClient.maxRedirection {
            throw HTTPClientError.maxRedirectionExceeded(max: HTTPClient.maxRedirection)
        }
        
        try self.init(url: url)
        self.currentRedirectCount = redirectCount
    }
    
    public init(url: URL) throws {
        if url.scheme != "http" && url.scheme != "https" {
            throw HTTPClientError.invalidSchema
        }
        
        self.isSecure = url.scheme == "https"
        self.url = url
        
        guard let host = url.host else {
            throw HTTPClientError.hostRequired
        }
        
        let port = isSecure ? 443 : UInt(url.port ?? 80)
        
        if isSecure {
            self.stream = try SSLTCPStream(host: host, port: port)
        } else {
            self.stream = try TCPStream(host: DNS(host: host).resolve().inets().first!.host, port: port)
        }
    }
    
    public func open(deadline: Double = 0) throws {
        try self.stream.open(deadline: deadline)
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
            guard let message = try parser.parse(stream.read(upTo: 2048)).first else {
                continue
            }
            
            let response = message as! Response
            
            if response.isRedirection, followRedirect, let location = response.headers["Location"], let newUrl = URL(string: location) {
                
                var newUrl = newUrl
                if newUrl.host == nil {
                    newUrl = URL(string: "\(self.url.scheme!)://\(self.url.host!)\(newUrl)")!
                }
                
                if newUrl.host == self.url.host, newUrl.scheme == self.url.scheme {
                    //reuse connection
                    self.url = newUrl
                    currentRedirectCount+=1
                    return try self.request()
                } else {
                    // Try to get the next content with a new connection.
                    self.stream.close()
                    let client = try HTTPClient(url:newUrl, redirectCount: currentRedirectCount+1)
                    try client.open()
                    return try client.request()
                }
            }
            
            return response
        }
        
        throw StreamError.alreadyClosed
    }
}
