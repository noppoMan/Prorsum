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

public struct Cookie : CookieProtocol {
    public var name: String
    public var value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension Cookie : Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
}

extension Cookie : Equatable {}

public func == (lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension Cookie : CustomStringConvertible {
    public var description: String {
        return "\(name)=\(value)"
    }
}

public protocol CookieProtocol {
    init(name: String, value: String)
}

extension Set where Element : CookieProtocol {
    public init?(cookieHeader: String) {
        var cookies = Set<Element>()
        let tokens = cookieHeader.split(separator: ";")
        
        for token in tokens {
            let cookieTokens = token.split(separator: "=", maxSplits: 1)
            
            guard cookieTokens.count == 2 else {
                return nil
            }
            
            cookies.insert(Element(name: cookieTokens[0].trimmingCharacters(in: .whitespacesAndNewlines), value: cookieTokens[1].trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        
        self = cookies
    }
}
