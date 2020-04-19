//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-07.
//

import Foundation


internal final class Parser {
    enum Error: Swift.Error {
        case unexpectedToken(Token)
        case unexpectedEOF
        case unexpectedOperator(Operator)
        case unexpectedPayload(String)
    }
    
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
    
    public func parse() throws -> Message {
        let `operator` = try parseOperator()
        consumeToken()
        
        switch `operator` {
        case .info:
            return try parseInfo()
        case .msg:
            return try parseMessage()
        case .ok:
            return .ok
        case .error:
            return try parseError()
        case .ping:
            return .ping
        case .pong:
            return .pong
        default:
            throw Error.unexpectedOperator(`operator`)
        }
    }
    
    private func parseInfo() throws -> Message {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .string(message) = token else {
            throw Error.unexpectedToken(token)
        }
        
        return .info(message)
    }
    
    private func parseError() throws -> Message {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .string(message) = token else {
            throw Error.unexpectedToken(token)
        }
        
        return .error(message)
    }
    
    private func parseMessage() throws -> Message {
        if tokens.count < 5 {
            throw Error.unexpectedEOF
        }
        
        guard tokens.count == 5 else {
            return try parseRequest()
        }
        
        let subject = try parseSubject()
        consumeToken()
        
        let sid = try parseSID()
        consumeToken()
        
        let bytes = try parseBytes()
        consumeToken()
        
        let payload = try parsePayload()
        consumeToken()
        
        return Message.msg(subject: subject, sid: sid, bytes: bytes, payload: payload)
    }
    
    public func parseRequest() throws -> Message {
        let subject = try parseSubject()
        consumeToken()

        let sid = try parseSID()
        consumeToken()
        
        let replyTo = try parseReplyTo()
        consumeToken()
        
        let bytes = try parseBytes()
        consumeToken()
        
        let payload = try parsePayload()
        consumeToken()
        
        return Message.msg(subject: subject, sid: sid, replyTo: replyTo, bytes: bytes, payload: payload)
    }
    
    private func parseOperator() throws -> Operator {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case .op(let op) = token else {
            throw Error.unexpectedToken(token)
        }
        
        return op
    }
    
    private func parseSubject() throws -> String {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .string(subject) = token else {
            throw Error.unexpectedToken(token)
        }
        
        return subject
    }
    
    private func parseReplyTo() throws -> String {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .string(replyTo) = token else {
            throw Error.unexpectedToken(token)
        }
        
        return replyTo
    }
    
    private func parseSID() throws -> String {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .string(sid) = token else {
            throw Error.unexpectedToken(token)
        }
        
        return sid
    }
    
    private func parseBytes() throws -> Int {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .string(byteString) = token else {
            throw Error.unexpectedToken(token)
        }
        
        guard let bytes = Int(byteString) else {
            throw Error.unexpectedToken(token)
        }
        
        return bytes
    }
    
    private func parsePayload() throws -> Data {
        guard let token = currentToken else {
            throw Error.unexpectedEOF
        }
        
        guard case let .payload(payload) = token else {
            throw Error.unexpectedToken(token)
        }
        
        guard let data = payload.data(using: .utf8) else {
            throw Error.unexpectedPayload(payload)
        }
        
        return data
    }
}
