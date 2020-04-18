//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-14.
//

import Foundation

public enum Token: Equatable {
    case op(Operator)
    case string(String)
    case payload(String)
    case newline
}

public enum Operator: String, Equatable {
    case info = "INFO"
    case connect = "CONNECT"
    case msg = "MSG"
    case ok = "+OK"
    case error = "-ERR"
    case ping = "PING"
    case pong = "PONG"
}

public final class Lexer {
    private let input: String
    private var index: String.Index
    
    public init(input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    private var current: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    private func advanceIndex() {
        index = input.index(after: index)
    }
    
    private func readString() -> String {
        var str = ""
        
        while let c = current, !c.isNewline {
            str.append(c)
            advanceIndex()
        }
        
        return str
    }
    
    private func readIdentifierOrNumber() -> String {
        var str = ""
        
        while let c = current, (c.isAlphanumeric || c == "."), !c.isNewline {
            str.append(c)
            advanceIndex()
        }
        
        return str
    }
    
    private func advanceNextToken() -> Token? {
        while let character = current, character.isSpace, !character.isNewline {
            advanceIndex()
        }
        
        guard let character = current else {
            return nil
        }
                
        if character.isNewline {
            advanceIndex()
            let payload = readString()
            advanceIndex()
            
            return .payload(payload)
        }
        
        if character.isAlphanumeric {
            let value = readIdentifierOrNumber()
            
            if let op = Operator(rawValue: value) {
                return .op(op)
            }
            
            return .string(value)
        }
        
        return nil
    }
    
    public func lex() -> [Token] {
        var tokens = [Token]()
        
        while let token = advanceNextToken() {
            tokens.append(token)
        }
        
        return tokens
    }
}

extension Character {
    var isAlphanumeric: Bool {
        return isalnum(value) != 0 || self == "_"
    }
}

extension Character {
    var isSpace: Bool {
        return isspace(value) != 0
    }
}

extension Character {
    var value: Int32 {
        guard let unicodeScalar = String(self).unicodeScalars.first else {
            return 0
        }
        
        return Int32(unicodeScalar.value)
    }
}
