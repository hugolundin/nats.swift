//
//  ParserTests.swift
//
//
//  Created by Hugo Lundin on 2020-04-14.
//

import XCTest
import Foundation
@testable import nats_swift

final class ParserTests: XCTestCase {
    func testMessage() {
        
        let msg = expectation(description: "The closure should be called for the parsed message.")
        let ping = expectation(description: "The closure should be called for the parsed ping.")
        
        let parser = Parser() { message in
            switch message {
            case .ping:
                ping.fulfill()
            case .msg(_, _, _, _, _):
                msg.fulfill()
            default:
                break
            }
        }
        
        try? parser.parse(input: "MSG test 123 7\r\n{'Hej'}\r\nPING\r\n")
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    
    
    func testPing() {
        let closure = expectation(description: "The closure should be called.")
        
        let parser = Parser() { message in
            // XCTAssert(message == .ping)
            closure.fulfill()
        }
        
        try? parser.parse(input: "PING\r\n")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    func testPong() {
        let parser = Parser() { message in
            // XCTAssertTrue(message == .pong)
        }
        
        try? parser.parse(input: "PONG\r\n")
    }
    
    func testError() {
        let closure = expectation(description: "The closure should be called.")
        
        let parser = Parser() { message in
            if case .error(let payload) = message {
                XCTAssert(payload == "'{}'")
            }
            
            closure.fulfill()
        }
        
        try? parser.parse(input: "-ERR '{}'\r\n")
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("testMessage", testMessage),
        ("testPing", testPing),
        ("testPong", testPong),
        ("testError", testError)
    ]
}
