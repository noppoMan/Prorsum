//
//  Data.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/28.
//
//

import Foundation

extension Data {
    public static var empty: Data {
        return Data()
    }
    
    public var bytes: Bytes {
        return self.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
    }
    
    public subscript(bounds: CountableRange<Int>) -> Data {
        return Data(bytes[bounds])
    }
}

public protocol DataRepresentable {
    var data: Data { get }
}

extension Data : DataRepresentable {
    public var data: Data {
        return self
    }
}
