import XCTest

import nats_swiftTests

var tests = [XCTestCaseEntry]()
tests += nats_swiftTests.allTests()
XCTMain(tests)
