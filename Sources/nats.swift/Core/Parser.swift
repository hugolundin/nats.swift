//
//  Parser.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-27.
//

import Foundation

internal final class Parser {
    internal enum State {
        case INITIAL
        
        case I
        case IN
        case INF
        case INFO
        case INFO_ARG
        
        case M
        case MS
        case MSG
        case MSG_ARG
        case MSG_PAYLOAD
        
        case P
        case PI
        case PIN
        case PING
        case PO
        case PON
        case PONG
        
        case PLUS
        case PLUS_O
        case PLUS_OK
        
        case MINUS
        case MINUS_E
        case MINUS_ER
        case MINUS_ERR
        case MINUS_ERR_ARG
    }
    
    internal enum Error: Swift.Error {
        case parseError
        case unexpectedToken(Character)
        case unexpectedEOF
        case unexpectedArgumentCount
        case missingArgument
    }
    
    internal enum Incoming: Equatable {
        case ping
        case pong
        case msg(Message)
        case info(String)
        case ok
        case error(String)
    }
    
    internal typealias Closure = (Incoming) -> Void
    
    private var state: State
    private var buffer: String
    internal var closure: Closure?
    private var argumentBuffer = [""]
    
    private var subject: String? = nil
    private var ssid: String? = nil
    private var replyTo: String? = nil
    private var bytes: Int? = nil
    
    internal init(state: State = .INITIAL, _ closure: Closure? = nil) {
        self.state = state
        self.buffer = ""
        self.closure = closure
    }
    
    internal func parse(input: String) throws {
        for current in input {
            switch state {
            case .INITIAL:
                switch current {
                case "I", "i":
                state = .I
                
                case "M", "m":
                    state = .M
                    
                case "P", "p":
                    state = .P
                    
                case "+":
                    state = .PLUS
                    
                case "-":
                    state = .MINUS
                    
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .I:
                switch current {
                case "N", "n":
                    state = .IN
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .IN:
                switch current {
                case "F", "f":
                    state = .INF
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .INF:
                switch current {
                case "O", "o":
                    state = .INFO
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .INFO:
                if current.isSpace {
                    state = .INFO_ARG
                } else {
                    throw Error.unexpectedToken(current)
                }
                
            case .INFO_ARG:
                if current.isNewline {
                    self.closure?(.info(buffer))
                    self.reset()
                } else {
                    self.buffer.append(current)
                }
                
            case .M:
                switch current {
                case "S", "s":
                    state = .MS
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .MS:
                switch current {
                case "G", "g":
                    state = .MSG
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .MSG:
                if current.isSpace {
                    state = .MSG_ARG
                } else {
                    throw Error.unexpectedToken(current)
                }
                
            case .MSG_ARG:
                if current.isNewline {
                    try self.argument(argumentBuffer)
                    state = .MSG_PAYLOAD
                } else if current.isSpace {
                    argumentBuffer.append("")
                } else {
                    argumentBuffer[argumentBuffer.count - 1].append(current)
                }
                
            case .MSG_PAYLOAD:
                if current.isNewline {
                    try self.message(buffer)
                    self.reset()
                } else {
                    self.buffer.append(current)
                }
                
            case .P:
                switch current {
                case "I", "i":
                    state = .PI
                    
                case "O", "o":
                    state = .PO
                    
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PI:
                switch current {
                case "N", "n":
                    state = .PIN
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PIN:
                switch current {
                case "G", "g":
                    state = .PING
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PING:
                if current.isNewline {
                    self.closure?(.ping)
                    self.reset()
                } else {
                    throw Error.unexpectedToken(current)
                }
                
            case .PO:
                switch current {
                case "N", "n":
                    state = .PON
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PON:
                switch current {
                case "G", "g":
                    state = .PONG
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PONG:
                if current.isNewline {
                    self.closure?(.pong)
                    self.reset()
                } else {
                    throw Error.unexpectedToken(current)
                }
                
            case .PLUS:
                switch current {
                case "O", "o":
                    state = .PLUS_O
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PLUS_O:
                switch current {
                case "K", "k":
                    state = .PLUS_OK
                    
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .PLUS_OK:
                if current.isNewline {
                    closure?(.ok)
                    self.reset()
                } else {
                    throw Error.unexpectedToken(current)
                }
                
            case .MINUS:
                switch current {
                case "E", "e":
                    state = .MINUS_E
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .MINUS_E:
                switch current {
                case "R", "r":
                    state = .MINUS_ER
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .MINUS_ER:
                switch current {
                case "R", "r":
                    state = .MINUS_ERR
                default:
                    throw Error.unexpectedToken(current)
                }
                
            case .MINUS_ERR:
                if current.isSpace {
                    state = .MINUS_ERR_ARG
                } else {
                    throw Error.unexpectedToken(current)
                }
                
            case .MINUS_ERR_ARG:
                if current.isNewline {
                    self.closure?(.error(buffer))
                } else {
                    self.buffer.append(current)
                }
            }
        }
    }
    
    public func reset() {
        self.state = .INITIAL
        self.buffer = ""
        self.argumentBuffer = [""]
    }
    
    private func argument(_ buffer: [String]) throws {
        if buffer.count == 3 {
            subject = buffer[safe: 0]
            ssid = buffer[safe: 1]
            bytes = Int(buffer[safe: 2] ?? "")
            
            return
        }
        
        if buffer.count == 4 {
            subject = buffer[safe: 0]
            ssid = buffer[safe: 1]
            replyTo = buffer[safe: 2]
            bytes = Int(buffer[safe: 3] ?? "")
            
            return
        }
        
        throw Error.unexpectedArgumentCount
    }
    
    private func message(_ buffer: String) throws {
        guard let subject = self.subject else {
            throw Error.missingArgument
        }
        
        guard let ssid = self.ssid else {
            throw Error.missingArgument
        }
        
        guard let bytes = self.bytes else {
            throw Error.missingArgument
        }
        
        guard bytes == buffer.count else {
            throw Error.parseError
        }
        
        self.closure?(.msg(Message(subject: subject, ssid: ssid, replyTo: replyTo, bytes: bytes, payload: buffer)))
    }
}
