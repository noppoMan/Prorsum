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
@testable import Prorsum

class TCPTests: XCTestCase {
    
    static var allTests : [(String, (TCPTests) -> () throws -> Void)] {
        return [
            ("testTCPConnectAndRead", testTCPConnectAndRead),
        ]
    }
    
    func testTCPConnectAndRead() {
        let server = try! TCPServer { clientSocket in
            try! clientSocket.write(Array("hello".utf8))
            clientSocket.close()
        }
        
        go {
            sleep(1)
            let client = try! TCP()
            try! client.connect(host: "0.0.0", port: 8080)
            
            var received = Bytes()
            
            while !client.isClosed {
                received.append(contentsOf: try! client.read())
            }
            XCTAssertEqual(received, [104, 101, 108, 108, 111])
            server.terminate()
        }
        
        try! server.bind(host: "0.0.0.0", port: 8080)
        try! server.listen()
    }
    
    
    func testTCPConnectAndReadWithSpecifiedBytesCount() {
        let server = try! TCPServer { clientSocket in
            try! clientSocket.write(Array("hello".utf8))
            clientSocket.close()
        }
        
        go {
            sleep(1)
            let client = try! TCP()
            try! client.connect(host: "0.0.0", port: 8080)
            
            while !client.isClosed {
                let bytes = try! client.read(upTo: 1)
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

