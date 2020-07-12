//
//  GeneratorTests.swift
//  
//
//  Created by Hugo Lundin on 2020-07-12.
//

import Foundation

import XCTest
import Foundation
@testable import nats_swift

final class GeneratorTests: XCTestCase {
    private let generator = Generator()
    
    func testPublish() {
        XCTAssert(
            generator.publish(
                subject: "test.123",
                payload: "",
                replyTo: ""
            ) == "PUB test.123 0\r\n\r\n"
        )
    }
    
    func testPublishWithPayload() {
        XCTAssert(
            generator.publish(
                subject: "test.123",
                payload: "data",
                replyTo: ""
            ) == "PUB test.123 4\r\ndata\r\n"
        )
    }
    
    func testPublishWithPayloadAndReplyTo() {
        XCTAssert(
            generator.publish(
                subject: "test.123",
                payload: "data",
                replyTo: "reply.here"
            ) == "PUB test.123 reply.here 4\r\ndata\r\n"
        )
    }
    
    func testPublishWithoutPayloadButReplyTo() {
        XCTAssert(
            generator.publish(
                subject: "test.123",
                payload: "",
                replyTo: "reply.here"
            ) == "PUB test.123 reply.here 0\r\n\r\n"
        )
    }
    
    func testSubscribe() {
        
    }
    
    func testSubscribeEmpty() {
        
    }
    
    func testSubscribeInvalid() {
        
    }
    
    func testConnect() {
        
    }
}
