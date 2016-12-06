import XCTest
@testable import ProrsumTests

XCTMain([
    testCase(ChannelTests.allTests),
    testCase(HTTPClientTests.allTests),
    testCase(HTTPServerTests.allTests),
    testCase(SelectTests.allTests),
    testCase(TCPTests.allTests),
    testCase(WaitGroupTests.allTests)
])
