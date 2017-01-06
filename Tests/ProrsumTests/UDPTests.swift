//
//  UDPTest.swift
//  Prorsum
//
//  Created by Yuki Takei on 2017/01/05.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import XCTest
import Foundation
@testable import Prorsum

class UDPTests: XCTestCase {

    static var allTests : [(String, (UDPTests) -> () throws -> Void)] {
        return [
            ("testUDPClientAndServer", testUDPClientAndServer)
        ]
    }
    
    func testUDPClientAndServer() {
        let udp = try! UDPSocket(addressFamily: .inet)
        let address = Address(host: "0.0.0.0", port: 22222)
        try! udp.bind(host: address.host, port: address.port)
        
        try! udp.sendto(address: address, bytes: "Hello".bytes)
        
        while !udp.isClosed {
            let (bytes, _) = try! udp.recvfrom()
            udp.close()
            XCTAssertEqual(bytes, [72, 101, 108, 108, 111])
        }
    }
}


