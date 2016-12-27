//
//  RequestWriter.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
//
//

public struct RequestWriter {
    
    public let stream: DuplexStream
    
    public init(stream: DuplexStream){
        self.stream = stream
    }
    
    public func serialize(_ request: Request, deadline: Double = 0) throws {
        let serializer = RequestSerializer(stream: stream)
        try serializer.serialize(request, deadline: 0)
    }
    
    public func close() {
        stream.close()
    }
}
