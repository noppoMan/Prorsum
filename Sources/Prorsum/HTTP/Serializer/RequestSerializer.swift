//
//  RequestSerializer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

public struct RequestSerializer {
    let stream: DuplexStream
    let bufferSize: Int
    
    public init(stream: DuplexStream, bufferSize: Int = 2048) {
        self.stream = stream
        self.bufferSize = bufferSize
    }
    
    public func serialize(_ request: Request, deadline: Double) throws {
        let newLine: [UInt8] = [13, 10]
        
        let method = "\(request.method)".uppercased()

        // if host is set
        // build uri from path & query
        // else use absoluteString
        //
        let requestURI: String
        if request.host != nil {
            var uri = !request.url.path.isEmpty ? request.url.path : "/" 
            if let query = request.url.query {
                uri += "?\(query)"
            }
            requestURI = uri
        } else {
            requestURI = request.url.absoluteString
        }

        try stream.write(Array("\(method) \(requestURI) HTTP/\(request.version.major).\(request.version.minor)".utf8), deadline: deadline)
        try stream.write(newLine, deadline: deadline)
        
        for (name, value) in request.headers.headers {
            try stream.write(Array("\(name): \(value)".utf8), deadline: deadline)
            try stream.write(newLine, deadline: deadline)
        }
        
        try stream.write(newLine, deadline: deadline)
        
        switch request.body {
        case .buffer(let buffer):
            try stream.write(buffer.withUnsafeBytes { [UInt8]($0) }, deadline: deadline)
        case .reader(let reader):
            while !reader.isClosed {
                let buffer = try reader.read(upTo: bufferSize, deadline: deadline)
                guard !buffer.isEmpty else {
                    break
                }
                
                try stream.write(Array(String(buffer.count, radix: 16).utf8), deadline: deadline)
                try stream.write(newLine, deadline: deadline)
                try stream.write(buffer, deadline: deadline)
                try stream.write(newLine, deadline: deadline)
            }
            
            try stream.write(Array("0".utf8), deadline: deadline)
            try stream.write(newLine, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
        case .writer(let writer):
            let body = BodyStream(stream)
            try writer(body)
            
            try stream.write(Array("0".utf8), deadline: deadline)
            try stream.write(newLine, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
        }
    }
}
