//
//  SHA1.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/27.
//
//

import CLibreSSL

func sha1(_ data: [UInt8]) -> [UInt8] {
    var md = [UInt8].init(repeating: 0, count: Int(SHA_DIGEST_LENGTH))
    var d = data
    SHA1(&d, data.count, &md)
    
    return md
}
