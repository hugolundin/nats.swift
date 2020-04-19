//
//  LexerTests.swift
//  
//
//  Created by Hugo Lundin on 2020-04-14.
//

import XCTest
import Foundation
@testable import nats_swift

final class LexerTests: XCTestCase {
    
    let lexer = Lexer()
    
    func testMessage() {
        let tokens = lexer.lex(input: "MSG test.test 123 5\r\nhejsan sten\r\n")
        
        XCTAssert(tokens.count > 0, "No lexed tokens")
        XCTAssert(tokens.count == 5, "Invalid number of tokens")
    }
    
    func testPing() {
        let tokens = lexer.lex(input: "PING\r\n")
        
        XCTAssert(tokens.count == 1, "Unexpected number of tokens")
        XCTAssert(tokens.first! == .op(.ping))
    }
    
    func testPong() {
        let tokens = lexer.lex(input: "PONG\r\n")
        
        XCTAssert(tokens.count == 1, "Unexpected number of tokens")
        XCTAssert(tokens.first! == .op(.pong))
    }
    
    func testOK() {
        let tokens = lexer.lex(input: "+OK")
        
        XCTAssert(tokens.count == 1, "Unexpected number of tokens")
        XCTAssert(tokens.first! == .op(.ok))
    }
    
    func testError() {
//        let tokens = lexer.lex(input: "-ERR 'Parser Error'")
//
//        XCTAssert(tokens.count == 1, "Unexpected number of tokens")
//        XCTAssert(tokens.first! == .op(.error))
    }
    
    func testInfo() {
        
    }
    
    static var allTests = [
        ("testMessage", testMessage),
        ("testPing", testPing),
        ("testPong", testPong),
        ("testOK", testOK),
        ("testError", testError),
        ("testInfo", testInfo),
    ]
}
