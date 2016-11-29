//
//  WaitGroupTests.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/24.
//
//

import XCTest
@testable import Prorsum

class WaitGroupTests: XCTestCase {

    static var allTests : [(String, (WaitGroupTests) -> () throws -> Void)] {
        return [
            ("testWG", testWG),
        ]
    }
    
    func testWG() {
        let exp = expectation(description: "waitGroup")
        let wg = WaitGroup()
        
        wg.add(1)
        go {
            wg.done()
        }

        wg.add(1)
        go {
            wg.done()
        }

        wg.add(2)
        go {
            wg.done()
        }
        
        go {
            wg.done()
        }
        
        wg.wait()
        exp.fulfill()

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
