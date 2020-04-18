//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-07.
//

import Foundation

enum ParseError: Error {
    case unexpectedToken(Token)
    case unexpectedEOF
}

internal final class Parser {
    private var index = 0
    private let tokens: [Token]
    
    public init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    private var currentToken: Token? {
        return index < tokens.count ? tokens[index] : nil
    }
    
    private func consumeToken(n: Int = 1) {
        index += n
    }
    
    public func parse() -> Message? {
        return try? parseMessage()
    }
    
    public func parseMessage() throws -> Message {
        guard let token = currentToken else {
            throw ParseError.unexpectedEOF
        }
        
        guard tokens.count == 5 else {
            return try parseRequest()
        }
        
        parseOperator()
        parseSubject()
        parseSID()
        parseBytes()
        parsePayload()
        
        throw ParseError.unexpectedEOF
    }
    
    public func parseRequest() throws -> Message {
        throw ParseError.unexpectedEOF
    }
    
    private func parseOperator() -> Operator {
        return .connect
    }
    
    private func parsePayload() {
        
    }
    
    private func parseBytes() {
        
    }
    
    private func parseSID() {
        
    }
    
    private func parseSubject() {
        
    }
    
    private func parseReplyTo() {
        
    }
}
