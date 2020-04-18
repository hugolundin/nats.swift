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
    func testMessage() {
        let lexer = Lexer(input: "MSG test.test 123 5\r\nhejsan sten\r\n")
        let tokens = lexer.lex()
        let parser = Parser(tokens: tokens)
        let message = parser.parse()
        
        assert(tokens.count > 0, "No lexed tokens")
        assert(tokens.count == 5, "Invalid number of tokens")
        assert(message != nil, "Message parsing failed")
    }
    
    static var allTests = [
        ("testMessage", testMessage),
    ]
}
