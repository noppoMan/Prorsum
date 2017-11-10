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

public struct Headers {
    public var headers: [CaseInsensitiveString: String]
    
    public init(_ headers: [CaseInsensitiveString: String]) {
        self.headers = headers
    }
}

extension Headers {
    public static var empty: Headers {
        return Headers()
    }
}

extension Headers : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (CaseInsensitiveString, String)...) {
        var headers: [CaseInsensitiveString: String] = [:]
        
        for (key, value) in elements {
            headers[key] = value
        }
        
        self.headers = headers
    }
}

extension Headers : Sequence {
    public func makeIterator() -> DictionaryIterator<CaseInsensitiveString, String> {
        return headers.makeIterator()
    }
    
    public var count: Int {
        return headers.count
    }
    
    public var isEmpty: Bool {
        return headers.isEmpty
    }
    
    public subscript(field: CaseInsensitiveString) -> String? {
        get {
            return headers[field]
        }
        
        set(header) {
            headers[field] = header
            
            if field == "Content-Length" && header != nil && headers["Transfer-Encoding"] == "chunked" {
                headers["Transfer-Encoding"] = nil
            } else if field == "Transfer-Encoding" && header == "chunked" {
                headers["Content-Length"] = nil
            }
        }
    }
    
    public subscript(field: CaseInsensitiveStringRepresentable) -> String? {
        get {
            return self[field.caseInsensitiveString]
        }
        
        set(header) {
            self[field.caseInsensitiveString] = header
        }
    }
}

extension Headers : CustomStringConvertible {
    public var description: String {
        var string = ""
        
        for (header, value) in headers {
            string += "\(header): \(value)\n"
        }
        
        return string
    }
}

extension Headers : Equatable {}

public func == (lhs: Headers, rhs: Headers) -> Bool {
    return lhs.headers == rhs.headers
}
