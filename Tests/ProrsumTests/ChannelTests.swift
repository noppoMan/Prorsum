//
//  ChannelTests.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/24.
//
//

import XCTest
@testable import Prorsum

class ChannelTests: XCTestCase {
    
    static var allTests : [(String, (ChannelTests) -> () throws -> Void)] {
        return [
            ("testBlockingReceive", testBlockingReceive),
            ("testThrowToSendClosedChannel", testThrowToSendClosedChannel),
            ("testThrowToReceiveClosedChannel", testThrowToReceiveClosedChannel),
        ]
    }
    
    func testBlockingReceive() {
        let exp = expectation(description: "waitGroup")
        let ch = Channel<Int>.make(capacity: 1)
        
        func send(){
            try! ch.send(1)
        }
    
        go(send())

        go {
            try! ch.send(1)
            try! ch.send(1)
        }

        go {
            sleep(1)
            try! ch.send(1)
        }

        go {
            try! ch.send(1)
        }

        let sum = try! ch.receive()+ch.receive()+ch.receive()+ch.receive()
        XCTAssertEqual(sum, 4)
        XCTAssertEqual(try! ch.receive(), 1)
        exp.fulfill()
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testThrowToSendClosedChannel() {
        let ch = Channel<Int>.make(capacity: 1)
        ch.close()
        XCTAssertEqual(ch.isClosed, true)

        do {
            try ch.send(1)
        } catch {
            return
        }

        XCTFail("Here should be never called")
    }

    func testThrowToReceiveClosedChannel() {
        let ch = Channel<Int>.make(capacity: 1)
        try! ch.send(1)
        ch.close()
        XCTAssertEqual(ch.isClosed, true)

        do {
            _ = try ch.receive()
            _ = try ch.receive()
        } catch {
            return
        }

        XCTFail("Here should be never called")
    }
}
