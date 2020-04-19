//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-14.
//

import Foundation

internal final class Lexer {
    private var input: String
    private var index: String.Index
    
    internal init() {
        self.input = ""
        self.index = self.input.startIndex
    }
    
    
    internal func lex(input: String) -> [Token] {
        self.input = input
        self.index = self.input.startIndex
        
        var tokens = [Token]()
        
        while let token = advanceNextToken() {
            tokens.append(token)
        }
        
        return tokens
    }
    
    private var current: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    private var hasNext: Bool {
        if index == input.endIndex {
            return false
        }
        
        return input.index(after: index) < input.endIndex
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
        
        while let c = current, !c.isSpace, !c.isNewline {
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
            
            if hasNext {
                let payload = readString()
                advanceIndex()
                return .payload(payload)
            }
            
            return nil
        }
        
        
        let value = readIdentifierOrNumber()
            
        if let op = Operator(rawValue: value) {
            return .op(op)
        }
            
        return .string(value)
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
