//The MIT License (MIT)
//
//Copyright (c) 2016 Honza Dvorsky
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


public enum Certificates {
    public enum Signature {
        case selfSigned
        case signedFile(caCertificateFile: String)
        case signedDirectory(caCertificateDirectory: String)
        case signedBytes(caCertificateBytes: Bytes)
        
        public var isSelfSigned: Bool {
            switch self {
            case .selfSigned:
                return true
            default:
                return false
            }
        }
    }
    
    case none
    case files(certificateFile: String, privateKeyFile: String, signature: Signature)
    case chain(chainFile: String, signature: Signature)
    case certificateAuthority(signature: Signature)
    case bytes(certificateBytes: Bytes, keyBytes: Bytes, signature: Signature)
    
    public var areSelfSigned: Bool {
        switch self {
        case .none:
            return true
        case .files(_, _, let signature):
            return signature.isSelfSigned
        case .chain(_, let signature):
            return signature.isSelfSigned
        case .certificateAuthority(let signature):
            return signature.isSelfSigned
        case .bytes(certificateBytes: _, keyBytes: _, signature: let signature):
            return signature.isSelfSigned
        }
    }
    
    public static var defaults: Certificates {
        return .openbsd
    }
}

extension Certificates {
    @available(*, deprecated: 1.0, message: "Use `.openbsd` instead.")
    public static var mozilla: Certificates {
        return .certificateAuthority(signature: .signedBytes(caCertificateBytes: mozilla_certs_pem.bytes))
    }
}

extension Certificates {
    public static var openbsd: Certificates {
        return .certificateAuthority(signature: .signedBytes(caCertificateBytes: openbsd_certs_pem.bytes))
    }
}
