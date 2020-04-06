//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-06.
//

import XCTest
@testable import nats_swift

final class LexerTests: XCTestCase {
    func testPing() {
        let lexer = Lexer("PING\r\n")
        
        guard let result = try? lexer.lex() else {
            return assertionFailure()
        }
        
        assert(result.count == 0)
    }

    static var allTests = [
        ("testPing", testPing),
    ]
}
