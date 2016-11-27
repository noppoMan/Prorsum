//
//  Body.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/28.
//
//

import Foundation

public enum Body {
    case buffer(Data)
    case reader(ReadableStream)
    case writer((WritableStream) throws -> Void)
}

extension Body {
    public static var empty: Body {
        return .buffer(.empty)
    }
    
    public var isEmpty: Bool {
        switch self {
        case .buffer(let buffer): return buffer.isEmpty
        default: return false
        }
    }
}

extension Body {
    public var isBuffer: Bool {
        switch self {
        case .buffer: return true
        default: return false
        }
    }
    
    public var isReader: Bool {
        switch self {
        case .reader: return true
        default: return false
        }
    }
    
    public var isWriter: Bool {
        switch self {
        case .writer: return true
        default: return false
        }
    }
}
