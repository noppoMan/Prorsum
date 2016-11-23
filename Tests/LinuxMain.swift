import XCTest
@testable import ProrsumTests

XCTMain([
    testCase(ChannelTests.allTests),
    testCase(WaitGroupTests.allTests),
    testCase(SelectTests.allTests)
])
