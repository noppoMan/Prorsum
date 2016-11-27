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


public protocol Message {
    var version: Version { get set }
    var headers: Headers { get set }
    var body: Body { get set }
    var storage: [String: Any] { get set }
}

extension Message {
    public var contentType: MediaType? {
        get {
            return headers["Content-Type"].flatMap({try? MediaType(string: $0)})
        }
        
        set(contentType) {
            headers["Content-Type"] = contentType?.description
        }
    }
    
    public var contentLength: Int? {
        get {
            return headers["Content-Length"].flatMap({Int($0)})
        }
        
        set(contentLength) {
            headers["Content-Length"] = contentLength?.description
        }
    }
    
    public var transferEncoding: String? {
        get {
            return headers["Transfer-Encoding"]
        }
        
        set(transferEncoding) {
            headers["Transfer-Encoding"] = transferEncoding
        }
    }
    
    public var isChunkEncoded: Bool {
        return transferEncoding == "chunked"
    }
    
    public var connection: String? {
        get {
            return headers["Connection"]
        }
        
        set(connection) {
            headers["Connection"] = connection
        }
    }
    
    public var isKeepAlive: Bool {
        if version.minor == 0 {
            return connection?.lowercased() == "keep-alive"
        }
        
        return connection?.lowercased() != "close"
    }
    
    public var isUpgrade: Bool {
        return connection?.lowercased() == "upgrade"
    }
    
    public var upgrade: String? {
        get {
            return headers["Upgrade"]
        }
        
        set(upgrade) {
            headers["Upgrade"] = upgrade
        }
    }
}

extension Message {
    public var storageDescription: String {
        var string = "Storage:\n"
        
        if storage.isEmpty {
            string += "-"
        }
        
        for (key, value) in storage {
            string += "\(key): \(value)\n"
        }
        
        return string
    }
}
