//
//  TCPTests.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/27.
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

class TCPTests: XCTestCase {
    
    static var allTests : [(String, (TCPTests) -> () throws -> Void)] {
        return [
            ("testTCPConnectAndRead", testTCPConnectAndRead),
        ]
    }
    
    func testTCPConnectAndRead() {
        let server = try! TCPServer { clientStream in
            try! clientStream.write(Array("hello".utf8))
            clientStream.close()
        }
        
        go {
            sleep(1)
            let client = try! TCPSocket()
            try! client.connect(host: "0.0.0", port: 3332)
            
            var received = Bytes()
            
            while !client.isClosed {
                received.append(contentsOf: try! client.recv())
            }
            XCTAssertEqual(received, [104, 101, 108, 108, 111])
            server.terminate()
        }
        
        try! server.bind(host: "0.0.0.0", port: 3332)
        try! server.listen()
    }
    
    
    func testTCPConnectAndReadWithSpecifiedBytesCount() {
        let server = try! TCPServer { clientSocket in
            try! clientSocket.write(Array("hello".utf8))
            clientSocket.close()
        }
        
        go {
            sleep(1)
            let client = try! TCPSocket()
            try! client.connect(host: "0.0.0", port: 8080)
            
            while !client.isClosed {
                let bytes = try! client.recv(upTo: 1)
                if bytes.count != 0 {
                    XCTAssertEqual(bytes.count, 1)
                }
            }
            server.terminate()
        }
        
        try! server.bind(host: "0.0.0.0", port: 8080)
        try! server.listen()
    }
}

