//
//  ResponseWriter.swift
//  TSSSJSONRPCServer
//
//  Created by Yuki Takei on 2016/12/02.
//
//

public struct ResponrWriter {
    
    let stream: DuplexStream
    
    public init(stream: DuplexStream){
        self.stream = stream
    }
    
    public func serialize(_ response: Response, deadline: Double = 0) throws {
        let serializer = ResponseSerializer(stream: stream)
        try serializer.serialize(response, deadline: 0)
    }
    
    public func close() {
        stream.close()
    }
}
