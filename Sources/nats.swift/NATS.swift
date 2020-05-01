//
//  NATS.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-05-01.
//

import Foundation

public protocol IODelegate {
    func send(_ buffer: String)
}

public class NATS {
    private struct Subscriber {
        let subject: String
        let closure: (Message) -> Void
    }
    
    public enum Error: Swift.Error {
        
    }
    
    public struct Message {
        let subject: String
        let sid: String
        let request: String?
        let bytes: Int
        let payload: String
    }
    
    private let parser: Parser
    private let delegate: IODelegate?
    private var subscribers = [Subscriber]()
    
    public init(delegate: IODelegate? = nil) {
        self.delegate = delegate
        self.parser = Parser()
        self.parser.closure = self.closure
    }
    
    private func closure(_ message: Parser.Message) {
        switch message {
        case .ping:
            break
        case .pong:
            break
        case .msg(let subject, let sid, let request, let bytes, let payload):
            let message = Message(subject: subject, sid: sid, request: request, bytes: bytes, payload: payload)
            
            for subscriber in subscribers {
                guard subscriber.subject == subject else {
                    continue
                }
                
                subscriber.closure(message)
            }
            
        case .info(_):
            break
        case .ok:
            break
        case .error(_):
            break
        }
    }
    
    public func receive(buffer: String) {
        try? parser.parse(input: buffer)
    }
    
    public func publish(subject: String, payload: String = "", replyTo: String = "") {
        if replyTo.count > 0 {
            delegate?.send("PUB \(subject) \(replyTo) \(payload.count)\r\n\(payload)\r\n")
        } else {
            delegate?.send("PUB \(subject) \(payload.count)\r\n\(payload)\r\n")
        }
    }
    
    public func subscribe(subject: String, _ closure: @escaping (Message) -> Void) {
        subscribers.append(Subscriber(subject: subject, closure: closure))
    }
    
    public func request() {
        
    }
    
    public func ping() {
        
    }
    
    public func pong() {
        
    }
}
