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

import CLibreSSL

/// Configuration for the TLS communication.
/// See http://man.openbsd.org/OpenBSD-current/man3/tls_init.3
public final class SSLConfig {
    public enum Cipher: String {
        case secure
        case compat
        case legacy
        case insecure
    }
    public enum TLSProtocol: String {
        case tlsv1_0 = "tlsv1.0"
        case tlsv1_1 = "tlsv1.1"
        case tlsv1_2 = "tlsv1.2"
        case secure = "secure" // currently TLSv1.2 only
        case all = "all"
    }
    
    public typealias CConfig = OpaquePointer
    
    public let context: SSLContext
    
    public let cConfig: CConfig
    
    /// Specifies the used certificates.
    /// (Client and Server)
    public let certificates: Certificates
    
    /// Allows you to disable server name verification. Be careful when using this option.
    /// (Client)
    public let verifyHost: Bool
    
    /// Allows you to disable certificate verification. Be extremely careful when using this option.
    /// (Client and Server)
    public let verifyCertificates: Bool
    
    public init(
        context: SSLContext,
        certificates: Certificates = .defaults,
        verifyHost: Bool = true,
        verifyCertificates: Bool = true,
        cipher: Cipher = .compat,
        proto: [SSLConfig.TLSProtocol] = [.all]
        ) throws {
        self.context = context
        
        cConfig = tls_config_new()
        
        let protocolsString = proto.count > 0 ? proto.map { $0.rawValue }.joined(separator: ",") : TLSProtocol.all.rawValue
        var protocols:UInt32 = 0
        guard tls_config_parse_protocols(&protocols, protocolsString) >= 0 else {
            throw TLSError.parsingProtocolsFailed(context.error)
        }
        tls_config_set_protocols(cConfig, protocols)
        
        let cipherSetResult = tls_config_set_ciphers(cConfig, cipher.rawValue)
        guard cipherSetResult != -1 else {
            throw TLSError.cipherListFailed
        }
        
        self.certificates = certificates
        self.verifyHost = verifyHost
        self.verifyCertificates = verifyCertificates
        
        try loadCertificates(certificates)
        
        if !verifyCertificates  {
            tls_config_insecure_noverifycert(cConfig)
        } else {
            if case .none = certificates {
                print("[TLS] Warning: No certificates were supplied. This may prevent TLS from successfully connecting unless the `verifyCertificates` option is set to false.")
            }
        }
        
        if !verifyHost {
            tls_config_insecure_noverifyname(cConfig)
        }
        
        guard tls_configure(context.cContext, cConfig) >= 0 else {
            throw TLSError.configureFailed(context.error)
        }
    }
    
    public convenience init(
        mode: Mode,
        certificates: Certificates = .defaults,
        verifyHost: Bool = true,
        verifyCertificates: Bool = true
        ) throws {
        let context = try SSLContext(mode: mode)
        try self.init(
            context: context,
            certificates: certificates,
            verifyHost: verifyHost,
            verifyCertificates: verifyCertificates
        )
    }
    
    /**
     Loads and sets the appropriate
     certificate files.
     */
    private func loadSignature(_ signature: Certificates.Signature) throws {
        switch signature {
        case .signedDirectory(caCertificateDirectory: let dir):
            guard tls_config_set_ca_path(cConfig, dir) == Result.OK else {
                throw TLSError.setCAPath(path: dir, context.error)
            }
        case .signedFile(caCertificateFile: let file):
            guard tls_config_set_ca_file(cConfig, file) == Result.OK else {
                throw TLSError.setCAFile(file: file, context.error)
            }
        case .signedBytes(caCertificateBytes: let bytes):
            guard tls_config_set_ca_mem(cConfig, bytes, bytes.count) == Result.OK else {
                throw TLSError.setCABytes(context.error)
            }
        case .selfSigned:
            break
        }
    }
    
    private func loadCertificates(_ certificates: Certificates) throws {
        switch certificates {
        case .chain(let file, let signature):
            guard tls_config_set_cert_file(cConfig, file) == Result.OK else {
                throw TLSError.setCertificateFile(context.error)
            }
            try loadSignature(signature)
        case .files(let certFile, let keyFile, let signature):
            guard tls_config_set_cert_file(cConfig, certFile) == Result.OK else {
                throw TLSError.setCertificateFile(context.error)
            }
            guard tls_config_set_key_file(cConfig, keyFile) == Result.OK else {
                throw TLSError.setKeyFile(context.error)
            }
            try loadSignature(signature)
        case .certificateAuthority(let signature):
            try loadSignature(signature)
        case .bytes(certificateBytes: let cert, keyBytes: let key, signature: let signature):
            guard tls_config_set_cert_mem(cConfig, cert, cert.count) == Result.OK else {
                throw TLSError.setCertificateBytes(context.error)
            }
            guard tls_config_set_key_mem(cConfig, key, key.count) == Result.OK else {
                throw TLSError.setKeyBytes(context.error)
            }
            try loadSignature(signature)
        case .none:
            break
        }
    }
    
    deinit {
        tls_config_free(cConfig)
    }
    
}
