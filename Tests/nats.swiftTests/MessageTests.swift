//
//  MessageTests.swift
//
//
//  Created by Hugo Lundin on 2020-04-19.
//

import XCTest
import Foundation
@testable import nats_swift

final class MessageTests: XCTestCase {
    
    let nats = NATS()
    
    func testMessage() {
        let message = nats.parse(input: "MSG test 123 5\r\nHej\r\n")
        XCTAssertNotNil(message)
    }
    
    static var allTests = [
        ("testMessage", testMessage),
    ]
}
