//
//  SelectTests.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/24.
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

class SelectTests: XCTestCase {
    
    static var allTests : [(String, (SelectTests) -> () throws -> Void)] {
        return [
            ("testSelect", testSelect),
            ("testSelectOtherwise", testSelectOtherwise),
            ("testForSelect", testForSelect),
            ("testForSelectOtherwise", testForSelectOtherwise),
        ]
    }
    
    func testSelect() {
        let ch = Channel<Int>.make(capacity: 1)
        
        go {
            try! ch.send(1)
        }

        select {
            when(ch) {
                XCTAssertEqual($0, 1)
            }
        }
    }
    
    func testSelectOtherwise() {
        let ch = Channel<Int>.make(capacity: 1)
        
        select {
            otherwise {
                sleep(1)
                try! ch.send(1000)
            }
        }

        XCTAssertEqual(try! ch.receive(), 1000)
    }
    
    func testForSelect() {
        let ch = Channel<Int>.make(capacity: 1)
        let doneCh = Channel<String>.make(capacity: 1)
        
        go {
            try! ch.send(1)
            try! ch.send(2)
            try! ch.send(3)
            try! doneCh.send("done")
        }
        
        var i = 0
        forSelect { done in
            when(ch) {
                i+=1
                XCTAssertEqual($0, i)
            }

            when(doneCh) {
                XCTAssertEqual($0, "done")
                done()
            }
        }
    }

    func testForSelectOtherwise() {
        let ch = Channel<Int>.make(capacity: 1)
        
        go {
            try! ch.send(1)
        }

        forSelect { done in
            when(ch) {
                XCTAssertEqual($0, 1)
            }

            otherwise {
                done()
            }
        }
    }
}
