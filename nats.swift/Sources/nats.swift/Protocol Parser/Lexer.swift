//
//  Lexer.swift
//  
//
//  Created by Hugo Lundin on 2020-04-06.
//

import Foundation

internal final class Lexer {
    internal enum Error: Swift.Error {
        
    }
    
    private let keywords: [String : Token] = [
        "+OK"  : .ok,
        "-ERR" : .error,
        "PING" : .ping,
        "PONG" : .pong,
        "INFO" : .info,
        "MSG"  : .msg
    ]
    
    private let input: String
    private var index: String.Index
    
    private var current: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    internal init(_ input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    internal func lex() throws -> [Token] {
        self.index = input.startIndex
        
        guard input.count > 0 else {
            return []
        }
        
        while current != nil {
            print(readString())
        }
        
        return []
    }
    
    private func readString() -> String {
        var str = ""
        
        while let c = current, !c.isNewline {
            str.append(c)
            advanceIndex()
        }
        
        return str
    }
    
    private func advanceIndex() {
        index = input.index(after: index)
    }
}
