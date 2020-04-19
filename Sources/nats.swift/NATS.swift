//
//  NATS.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-19.
//

import Foundation

public final class NATS {
    private let lexer = Lexer()
    private let parser = Parser()
    
    public func parse(input: String) -> Message? {
        let tokens = lexer.lex(input: input)
        return try? parser.parse(tokens: tokens)
    }
}
