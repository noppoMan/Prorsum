//
//  ResponseSerializer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/28.
//
//

public struct ResponseSerializer {
    let stream: DuplexStream
    let bufferSize: Int
    
    public init(stream: DuplexStream, bufferSize: Int = 2048) {
        self.stream = stream
        self.bufferSize = bufferSize
    }
    
    public func serialize(_ response: Response, deadline: Double) throws {
        var header = "HTTP/"
        header += response.version.major.description
        header += "."
        header += response.version.minor.description
        header += " "
        header += response.status.statusCode.description
        header += " "
        header += response.reasonPhrase
        header += "\r\n"
        
        for (name, value) in response.headers.headers {
            header += name.string
            header += ": "
            header += value
            header += "\r\n"
        }
        
        for cookie in response.cookieHeaders {
            header += "Set-Cookie: "
            header += cookie
            header += "\r\n"
        }
        
        header += "\r\n"
        
        try stream.write(Array(header.utf8), deadline: deadline)
        
        switch response.body {
        case .buffer(let buffer):
            try stream.write(buffer.withUnsafeBytes { [UInt8]($0) }, deadline: deadline)
        case .reader(let reader):
            while !reader.isClosed {
                let bytes = try reader.read(upTo: bufferSize, deadline: deadline)
                
                guard !bytes.isEmpty else {
                    break
                }
                
                try stream.write(Array(String(bytes.count, radix: 16).utf8), deadline: deadline)
                try stream.write(Array("\r\n".utf8), deadline: deadline)
                try stream.write(bytes, deadline: deadline)
                try stream.write(Array("\r\n".utf8), deadline: deadline)
            }
            
            try stream.write(Array("0\r\n\r\n".utf8), deadline: deadline)
        case .writer(let writer):
            let body = BodyStream(stream)
            try writer(body)
            try stream.write(Array("0\r\n\r\n".utf8), deadline: deadline)
        }
    }
}
