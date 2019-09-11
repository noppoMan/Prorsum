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

public struct AttributedCookie {
    public enum Expiration {
        case maxAge(Int)
        case expires(String)
    }
    
    public var name: String
    public var value: String
    
    public var expiration: Expiration?
    public var domain: String?
    public var path: String?
    public var secure: Bool
    public var httpOnly: Bool
    
    public init(name: String, value: String, expiration: Expiration? = nil, domain: String? = nil, path: String? = nil, secure: Bool = false, httpOnly: Bool = false) {
        self.name = name
        self.value = value
        self.expiration = expiration
        self.domain = domain
        self.path = path
        self.secure = secure
        self.httpOnly = httpOnly
    }
    
    public init?(_ string: String) {
        let cookieStringTokens = string.split(separator: ";")
        
        guard let cookieTokens = cookieStringTokens.first?.split(separator: "="), cookieTokens.count == 2 else {
            return nil
        }
        
        let name = String(cookieTokens[0])
        let value = String(cookieTokens[1])
        
        var attributes: [CaseInsensitiveString: String] = [:]
        
        for i in 1 ..< cookieStringTokens.count {
            let attributeTokens = cookieStringTokens[i].split(separator: "=")
            
            switch attributeTokens.count {
            case 1:
                attributes[CaseInsensitiveString(attributeTokens[0].trimmingCharacters(in: .whitespacesAndNewlines))] = ""
            case 2:
                attributes[CaseInsensitiveString(attributeTokens[0].trimmingCharacters(in: .whitespacesAndNewlines))] = attributeTokens[1].trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                return nil
            }
        }
        
        var expiration: Expiration?
        
        if let maxAge = attributes["Max-Age"].flatMap({Int($0)}) {
            expiration = .maxAge(maxAge)
        }
        
        if let expires = attributes["Expires"] {
            expiration = .expires(expires)
        }
        
        let domain = attributes["Domain"]
        let path = attributes["Path"]
        let secure = attributes["Secure"] != nil
        let httpOnly = attributes["HttpOnly"] != nil
        
        self.init(
            name: name,
            value: value,
            expiration: expiration,
            domain: domain,
            path: path,
            secure: secure,
            httpOnly:  httpOnly
        )
    }
}

extension AttributedCookie : Hashable {
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name.hashValue)
    }
}

public func == (lhs: AttributedCookie, rhs: AttributedCookie) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension AttributedCookie : CustomStringConvertible {
    public var description: String {
        var string = "\(name)=\(value)"
        
        if let expiration = expiration {
            switch expiration {
            case .expires(let expires):
                string += "; Expires=\(expires)"
            case .maxAge(let maxAge):
                string += "; Max-Age=\(maxAge)"
            }
        }
        
        if let domain = domain {
            string += "; Domain=\(domain)"
        }
        
        if let path = path {
            string += "; Path=\(path)"
        }
        
        if secure {
            string += "; Secure"
        }
        
        if httpOnly {
            string += "; HttpOnly"
        }
        
        return string
    }
}

extension AttributedCookie.Expiration : Equatable {}

public func == (lhs: AttributedCookie.Expiration, rhs: AttributedCookie.Expiration) -> Bool {
    switch (lhs, rhs) {
    case let (.maxAge(l), .maxAge(r)): return l == r
    case let (.expires(l), .expires(r)): return l == r
    default: return false
    }
}
