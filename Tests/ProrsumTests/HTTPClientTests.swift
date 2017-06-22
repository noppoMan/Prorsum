//
//  HTTPClientTests.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/12/04.
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

class HTTPClientTests: XCTestCase {
    
    static var allTests : [(String, (HTTPClientTests) -> () throws -> Void)] {
        return [
            ("testConnect", testConnect),
            ("testHTTPSConnect", testHTTPSConnect),
            ("testRedirect", testRedirect),
            ("testRedirectToOtherDomain", testRedirectToOtherDomain),
            ("testRedirectMaxRedirectionExceeded", testRedirectMaxRedirectionExceeded)
        ]
    }
    
    func testConnect() {
        let client = try! HTTPClient(url: URL(string: "http://httpbin.org/get")!)
        try! client.open()
        let response = try! client.request()
        
        XCTAssertEqual(response.statusCode, 200)
    }
    
    func testHTTPSConnect() {
        let client = try! HTTPClient(url: URL(string: "https://httpbin.org/get")!)
        try! client.open()
        let response = try! client.request()
        
        XCTAssertEqual(response.statusCode, 200)
    }
    
    func testRedirect() {
        let client = try! HTTPClient(url: URL(string: "https://httpbin.org/redirect/2")!)
        try! client.open()
        let response = try! client.request()
        
        XCTAssertEqual(response.statusCode, 200)
    }
    
    func testRedirectToOtherDomain() {
        let client = try! HTTPClient(url: URL(string: "https://httpbin.org/redirect-to?url=http%3A%2F%2Fexample.com%2F")!)
        try! client.open()
        let response = try! client.request()
        
        XCTAssertEqual(response.statusCode, 200)
    }
    
    func testRedirectMaxRedirectionExceeded() {
        HTTPClient.maxRedirection = 1
        defer {
            HTTPClient.maxRedirection = 10
        }
        
        let client = try! HTTPClient(url: URL(string: "https://httpbin.org/redirect/1")!)
        try! client.open()
        do {
            _ = try client.request()
        } catch HTTPClientError.maxRedirectionExceeded(let max) {
            XCTAssertEqual(max, 1)
        } catch {
            XCTFail("\(error)")
        }
    }
}

