//
//  HTTPServer.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/03.
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

class HTTPServerTests: XCTestCase {
    
    static var allTests : [(String, (HTTPServerTests) -> () throws -> Void)] {
        return [
            ("testHTTPConnect", testHTTPConnect),
        ]
    }
    
    func testHTTPConnect() {
        let server = try! HTTPServer { request, writer in
            let response = Response(body: "Hello!".data(using: .utf8)!)
            
            try! writer.serialize(response)
            writer.close()
        }
        
        go {
            sleep(1)
            let url = URL(string: "http://127.0.0.1:3333")
            let client = try! HTTPClient(url: url!)
            try! client.open()
            let response = try! client.request()
            
            switch response.body {
            case .buffer(let data):
                XCTAssertEqual(String(data: data, encoding: .utf8), "Hello!")
            default:
                XCTFail("Here should be never called")
            }
            server.terminate()
        }
        
        try! server.bind(host: "0.0.0.0", port: 3333)
        try! server.listen()
    }
}
