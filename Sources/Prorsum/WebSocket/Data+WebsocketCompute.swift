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


#if os(Linux)
    import Glibc
#else
    import Security
#endif

import Foundation

extension Data {
    public mutating func append(_ byte: UInt8) {
        var byte = byte
        self.append(&byte, count: 1)
    }
    
    public mutating func append(_ bytes: [UInt8]) {
        self.append(bytes, count: bytes.count)
    }
    
    init<T: BinaryInteger>(number: T) {
        let totalBytes = MemoryLayout<T>.size
        
        let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        valuePointer.pointee = number
        defer {
            valuePointer.deinitialize()
            valuePointer.deallocate(capacity: 1)
        }
        
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        self = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { p in
            for i in 0..<totalBytes {
                bytes[totalBytes - 1 - i] = (p + i).pointee
            }
            return Data(UnsafeBufferPointer(start: bytes, count: totalBytes))
        }
    }
    
    func toInt(_ size: Int, offset: Int = 0) -> UInt64 {
        guard size > 0 && size <= 8 && count >= offset+size else { return 0 }
        let slice = self[offset..<offset+size]
        var result: UInt64 = 0
        for (idx, byte) in slice.enumerated() {
            let (r, _) = size.subtractingReportingOverflow(idx)
            let shiftAmount = UInt64(r - 1) * 8
            result += UInt64(byte) << shiftAmount
        }
        return result
    }
    
    init(randomBytes byteCount: Int) throws {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        
        #if os(Linux)
            let urandom = open("/dev/urandom", O_RDONLY)
            
            if urandom == -1 {
                try ensureLastOperationSucceeded()
            }
            
            if read(urandom, &bytes, bytes.count) == -1 {
                try ensureLastOperationSucceeded()
            }
            
            if close(urandom) == -1 {
                try ensureLastOperationSucceeded()
            }
        #else
            if SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes) == -1 {
                try ensureLastOperationSucceeded()
            }
        #endif
        
        self.init(bytes)
    }
}
