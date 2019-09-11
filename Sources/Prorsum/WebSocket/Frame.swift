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


//	0                   1                   2                   3
//	0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
//	+-+-+-+-+-------+-+-------------+-------------------------------+
//	|F|R|R|R| opcode|M| Payload len |    Extended payload length    |
//	|I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
//	|N|V|V|V|       |S|             |   (if payload len==126/127)   |
//	| |1|2|3|       |K|             |                               |
//	+-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
//	|     Extended payload length continued, if payload len == 127  |
//	+ - - - - - - - - - - - - - - - +-------------------------------+
//	|                               |Masking-key, if MASK set to 1  |
//	+-------------------------------+-------------------------------+
//	| Masking-key (continued)       |          Payload Data         |
//	+-------------------------------- - - - - - - - - - - - - - - - +
//	:                     Payload Data continued ...                :
//	+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
//	|                     Payload Data continued ...                |
//	+---------------------------------------------------------------+

import Foundation

struct Frame {
    fileprivate static let finMask: UInt8 = 0b10000000
    fileprivate static let rsv1Mask: UInt8 = 0b01000000
    fileprivate static let rsv2Mask: UInt8 = 0b00100000
    fileprivate static let rsv3Mask: UInt8 = 0b00010000
    fileprivate static let opCodeMask: UInt8 = 0b00001111
    
    fileprivate static let maskMask: UInt8 = 0b10000000
    fileprivate static let payloadLenMask: UInt8 = 0b01111111
    
    enum OpCode: UInt8 {
        case continuation   = 0x0
        case text           = 0x1
        case binary         = 0x2
        // 0x3 -> 0x7 reserved
        case close          = 0x8
        case ping           = 0x9
        case pong           = 0xA
        // 0xB -> 0xF reserved
        case invalid        = 0x10
        
        var isControl: Bool {
            return self == .close || self == .ping || self == .pong
        }
    }
    
    var fin: Bool {
        return data[0] & Frame.finMask != 0
    }
    
    var rsv1: Bool {
        return data[0] & Frame.rsv1Mask != 0
    }
    
    var rsv2: Bool {
        return data[0] & Frame.rsv2Mask != 0
    }
    
    var rsv3: Bool {
        return data[0] & Frame.rsv3Mask != 0
    }
    
    var opCode: OpCode {
        if let opCode = OpCode(rawValue: data[0] & Frame.opCodeMask) {
            return opCode
        }
        return .invalid
    }
    
    var masked: Bool {
        return data[1] & Frame.maskMask != 0
    }
    
    var payloadLength: UInt64 {
        return UInt64(data[1] & Frame.payloadLenMask)
    }
    
    var payload: Data {
        var offset = 2
        
        if payloadLength == 126 {
            offset += 2
        } else if payloadLength == 127 {
            offset += 8
        }
        
        if masked {
            offset += 4
            
            // TODO: remove copy
            var unmaskedPayloadData = Array(data.suffix(from: offset))
            
            var maskOffset = 0
            let maskKey = self.maskKey
            for i in 0..<unmaskedPayloadData.count {
                unmaskedPayloadData[i] ^= maskKey[maskOffset % 4]
                maskOffset += 1
            }
            
            return Data(unmaskedPayloadData)
        }
        
        return data[offset..<data.count]
    }
    
    var isComplete: Bool {
        switch data.count {
        case 0..<2,
             0..<4 where payloadLength == 126,
             0..<10 where payloadLength == 127:
            return false
        case let count:
            return UInt64(count) >= totalFrameSize
        }
    }
    
    fileprivate var extendedPayloadLength: UInt64 {
        if payloadLength == 126 {
            return data.toInt(2, offset: 2)
        } else if payloadLength == 127 {
            return data.toInt(8, offset: 2)
        }
        return payloadLength
    }
    
    fileprivate var maskKey: Data {
        if payloadLength <= 125 {
            return data[2..<6]
        } else if payloadLength == 126 {
            return data[4..<8]
        }
        return data[10..<14]
    }
    
    fileprivate var totalFrameSize: UInt64 {
        let extendedPayloadExtraBytes = (payloadLength == 126 ? 2 : (payloadLength == 127 ? 8 : 0))
        let maskBytes = masked ? 4 : 0
        return UInt64(2 + extendedPayloadExtraBytes + maskBytes) + extendedPayloadLength
    }
    
    fileprivate(set) var data = Data()
    
    init() {}
    
    init(opCode: OpCode, data: DataRepresentable, maskKey: DataRepresentable) {
        let data = data.data
        let maskKey = maskKey.data
        
        let op7 = 1 << 7
        let op6 = 0 << 6
        let op5 = 0 << 5
        let op4 = 0 << 4
        var op = op7 | op6 | op5 | op4 | Int(opCode.rawValue)
        self.data.append([UInt8](Data(bytes: &op, count: MemoryLayout<Int>.size)))
        
        let masked: Bool = maskKey.count == 4
        let mask: UInt8 = masked ? 1 : 0
        let payloadLength = UInt64(data.count)
        
        if payloadLength > UInt64(UInt16.max) {
            self.data.append(mask << 7 | 127)
            self.data.append(Data(number: payloadLength))
        } else if payloadLength > 125 {
            self.data.append(mask << 7 | 126)
            self.data.append(Data(number: UInt16(payloadLength)))
        } else {
            self.data.append(mask << 7 | (UInt8(payloadLength) & 0x7F))
        }
        if masked {
            self.data.append(maskKey)
            
            // TODO: get rid of this copy
            var maskedData = Array(data)
            
            var maskOffset = 0
            for i in 0..<maskedData.count {
                maskedData[i] ^= maskKey[maskOffset % 4]
                maskOffset += 1
            }
            
            self.data.append(maskedData, count: maskedData.count)
        } else {
            self.data.append(data)
        }
    }
    
    mutating func add(_ data: Data) -> Data {
        self.data.append(data)
        
        if isComplete {
            // Int(totalFrameSize) cast is bad, will break spec max frame size of UInt64
            let remainingData = self.data[Int(totalFrameSize)..<self.data.count]
            self.data = self.data[0..<Int(totalFrameSize)]
            return remainingData
        }
        
        return Data()
    }
    
}

extension Sequence where Self.Iterator.Element == Frame {
    var payload: Data {
        var payload = Data()
        
        for frame in self {
            payload.append(frame.payload)
        }
        
        return payload
    }
}
