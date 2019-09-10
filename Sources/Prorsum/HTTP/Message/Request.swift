//The MIT License (MIT)
//
//Copyright (c) 2015 Zewo
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

import Foundation

public struct Request : Message {
    public enum Method {
        case delete
        case get
        case head
        case post
        case put
        case connect
        case options
        case trace
        case patch
        case other(method: String)
    }
    
    public var method: Method
    public var url: URL
    public var version: Version
    public var headers: Headers
    public var body: Body
    public var storage: [String: Any]
    
    public init(method: Method, url: URL, version: Version, headers: Headers, body: Body) {
        self.method = method
        self.url = url
        self.version = version
        self.headers = headers
        self.body = body
        self.storage = [:]
    }
}

public protocol RequestInitializable {
    init(request: Request)
}

public protocol RequestRepresentable {
    var request: Request { get }
}

public protocol RequestConvertible : RequestInitializable, RequestRepresentable {}

extension Request : RequestConvertible {
    public init(request: Request) {
        self = request
    }
    
    public var request: Request {
        return self
    }
}

extension Request {
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: Body) {
        self.init(
            method: method,
            url: url,
            version: Version(major: 1, minor: 1),
            headers: headers,
            body: body
        )
        
        switch body {
        case let .buffer(body):
            self.headers["Content-Length"] = body.count.description
        default:
            self.headers["Transfer-Encoding"] = "chunked"
        }
    }
    
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: DataRepresentable = Data()) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .buffer(body.data)
        )
    }
    
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: ReadableStream) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .reader(body)
        )
    }
    
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: Headers = [:], body: @escaping (WritableStream) throws -> Void) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .writer(body)
        )
    }
}

extension Request {
    public init?(method: Method = .get, url: String, headers: Headers = [:], body: DataRepresentable = Data()) {
        guard let url = URL(string: url) else {
            return nil
        }
        
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: body
        )
    }
    
    public init?(method: Method = .get, url: String, headers: Headers = [:], body: ReadableStream) {
        guard let url = URL(string: url) else {
            return nil
        }
        
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: body
        )
    }
    
    public init?(method: Method = .get, url: String, headers: Headers = [:], body: @escaping (WritableStream) throws -> Void) {
        guard let url = URL(string: url) else {
            return nil
        }
        
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: body
        )
    }
}

extension Request {
    public var path: String? {
        return url.path
    }
    
    public var queryItems: [URLQueryItem] {
        return url.queryItems
    }
}

extension Request {
    public var accept: [MediaType] {
        get {
            var acceptedMediaTypes: [MediaType] = []
            
            if let acceptString = headers["Accept"] {
                let acceptedTypesString = acceptString.split(separator: ",")
                
                for acceptedTypeString in acceptedTypesString {
                    let acceptedTypeTokens = acceptedTypeString.split(separator: ";")
                    
                    if acceptedTypeTokens.count >= 1 {
                        let mediaTypeString = acceptedTypeTokens[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        if let acceptedMediaType = try? MediaType(string: mediaTypeString) {
                            acceptedMediaTypes.append(acceptedMediaType)
                        }
                    }
                }
            }
            
            return acceptedMediaTypes
        }
        
        set(accept) {
            headers["Accept"] = accept.map({$0.type + "/" + $0.subtype}).joined(separator: ", ")
        }
    }
    
    public var cookies: Set<Cookie> {
        get {
            return headers["Cookie"].flatMap({Set<Cookie>(cookieHeader: $0)}) ?? []
        }
        
        set(cookies) {
            headers["Cookie"] = cookies.map({$0.description}).joined(separator: ", ")
        }
    }
    
    public var authorization: String? {
        get {
            return headers["Authorization"]
        }
        
        set(authorization) {
            headers["Authorization"] = authorization
        }
    }
    
    public var host: String? {
        get {
            return headers["Host"]
        }
        
        set(host) {
            headers["Host"] = host
        }
    }
    
    public var userAgent: String? {
        get {
            return headers["User-Agent"]
        }
        
        set(userAgent) {
            headers["User-Agent"] = userAgent
        }
    }
}

extension Request {
    public var pathParameters: [String: String] {
        get {
            return storage["pathParameters"] as? [String: String] ?? [:]
        }
        
        set(pathParameters) {
            storage["pathParameters"] = pathParameters
        }
    }
}

extension Request : CustomStringConvertible {
    public var requestLineDescription: String {
        return String(describing: method) + " " + url.absoluteString + " HTTP/" + String(describing: version.major) + "." + String(describing: version.minor) + "\n"
    }
    
    public var description: String {
        return requestLineDescription +
            headers.description
    }
}

extension Request : CustomDebugStringConvertible {
    public var debugDescription: String {
        return description + "\n" + storageDescription
    }
}
