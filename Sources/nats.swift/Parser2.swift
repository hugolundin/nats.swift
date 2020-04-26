//
//  Parser2.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-26.
//

import Foundation

internal final class Parser2 {
    internal enum State {
        case OP_START
        case OP_PLUS
        case OP_PLUS_O
        case OP_PLUS_OK
        case OP_MINUS
        case OP_MINUS_E
        case OP_MINUS_ER
        case OP_MINUS_ERR
        case OP_MINUS_ERR_SPC
        case MINUS_ERR_ARG
        case OP_M
        case OP_MS
        case OP_MSG
        case OP_MSG_SPC
        case MSG_ARG
        case MSG_PAYLOAD
        case MSG_END
        case OP_P
        case OP_PI
        case OP_PIN
        case OP_PING
        case OP_PO
        case OP_PON
        case OP_PONG
        case OP_I
        case OP_IN
        case OP_INF
        case OP_INFO
        case OP_INFO_SPC
        case INFO_ARG
    }
    
    enum Error: Swift.Error {
        case unexpectedCharacter(Character)
        case unexpectedState
    }
    
    struct MessageArgument {
        internal var subject: String
        internal var reply: String
        internal var sid: Int64
        internal var size: Int
    }
    
    private var state: State
    private var drop: Int
    private var argumentIndex: String.Index?
    private var argumentBuffer: String?
    private var messageArguments: MessageArgument
    
    internal init(_ initial: State = .OP_START) {
        self.state = initial
        self.drop = 0
        self.argumentIndex = nil
        self.argumentBuffer = nil
        self.messageArguments = MessageArgument(subject: "", reply: "", sid: 0, size: 0)
    }
    
    internal func parse(input: String) throws {
        var currentIndex = input.startIndex
        
        while (currentIndex < input.endIndex) {
            let current = input[currentIndex]
            
            switch state {
            case .OP_START:
                switch current {
                case "M", "m":
                    state = .OP_M
                case "P", "p":
                    state = .OP_P
                case "+":
                    state = .OP_PLUS
                case "-":
                    state = .OP_MINUS
                case "I", "i":
                    state = .OP_I
                default:
                    throw Error.unexpectedCharacter(current)
                }
                
            case .OP_M:
                switch current {
                case "S", "s":
                    state = .OP_MS
                default:
                    throw Error.unexpectedCharacter(current)
                }
                
            case .OP_MS:
                switch current {
                case "G", "g":
                    state = .OP_MSG
                default:
                    throw Error.unexpectedCharacter(current)
                }
                
            case .OP_MSG:
                switch current {
                case " ", "\t":
                    state = .OP_MSG_SPC
                default:
                    throw Error.unexpectedCharacter(current)
                }
                
            case .OP_MSG_SPC:
                switch current {
                case " ", "\t":
                    continue
                default:
                    state = .MSG_ARG
                    self.argumentIndex = currentIndex
                }
                
            case .MSG_ARG:
                switch current {
                case "\r":
                    self.drop = 1
                case "\n":
                    
                    if let argumentBuffer = argumentBuffer {
                        try process(argument: argumentBuffer)
                    } else {
                        guard let argumentIndex = argumentIndex else {
                            throw Error.unexpectedState
                        }
                        
                        try process(argument:
                            String(input[argumentIndex...input.index(currentIndex, offsetBy: self.drop)]))
                    }
                    
                    // Prepare parser for parsing the payload.
                    self.drop = 0
                    self.argumentIndex = input.index(after: currentIndex)
                    self.state = .MSG_PAYLOAD
                    
                    // Jump ahead.
                    // currentIndex = argumentIndex
                    
                default:
                    argumentBuffer?.append(current)
                }
                
                
            default:
                break
            }
            
            currentIndex = input.index(after: currentIndex)
        }
    }
    
    private func process(argument: String) throws {
        var arguments = [String]()
        var start: String.Index? = nil
        var currentIndex = argument.startIndex
        
        while (currentIndex < argument.endIndex) {
            let current = argument[currentIndex]
            
            switch current {
            case " ", "\t", "\r", "\n":
                if let startIndex = start {
                    arguments.append(String(argument[startIndex...currentIndex]))
                    start = nil
                }
                
            default:
                if start == nil {
                    start = currentIndex
                }
            }
            
            currentIndex = argument.index(after: currentIndex)
        }
        
        if let startIndex = start {
            arguments.append(String(argument[startIndex...]))
        }
        
        switch arguments.count {
        case 3:
            messageArguments.subject = arguments[0]
            messageArguments.sid = Int64(arguments[1]) ?? 0
            messageArguments.reply = ""
            messageArguments.size = Int(arguments[2]) ?? 0
        case 4:
            messageArguments.subject = arguments[0]
            messageArguments.sid = Int64(arguments[1]) ?? 0
            messageArguments.reply = arguments[2]
            messageArguments.size = Int(arguments[3]) ?? 0
        default:
            throw Error.unexpectedState
        }
    }
}
