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
        try stream.write("\(method) \(request.url.absoluteString) HTTP/\(request.version.major).\(request.version.minor)".bytes, deadline: deadline)
        try stream.write(newLine, deadline: deadline)
        
        for (name, value) in request.headers.headers {
            try stream.write("\(name): \(value)".bytes, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
        }
        
        try stream.write(newLine, deadline: deadline)
        
        switch request.body {
        case .buffer(let buffer):
            try stream.write(buffer.bytes, deadline: deadline)
        case .reader(let reader):
            while !reader.isClosed {
                let buffer = try reader.read(upTo: bufferSize, deadline: deadline)
                guard !buffer.isEmpty else {
                    break
                }
                
                try stream.write(String(buffer.count, radix: 16).bytes, deadline: deadline)
                try stream.write(newLine, deadline: deadline)
                try stream.write(buffer, deadline: deadline)
                try stream.write(newLine, deadline: deadline)
            }
            
            try stream.write("0".bytes, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
        case .writer(let writer):
            let body = BodyStream(stream)
            try writer(body)
            
            try stream.write("0".bytes, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
            try stream.write(newLine, deadline: deadline)
        }
    }
}
