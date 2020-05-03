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
    public enum Error: Swift.Error {
        
    }
  
    public struct Message {
        let subject: String
        let sid: String
        let request: String?
        let bytes: Int
        let payload: String
    }
    
    private struct Subscription {
        var maxMessages: Int?
        let closure: (Message) -> Void
    }
    
    private var sid: Int
    private let parser: Parser
    public var delegate: IODelegate?
    private var subscribers = [String : Subscription]()
    
    public init(delegate: IODelegate? = nil) {
        self.sid = 0
        self.delegate = delegate
        self.parser = Parser()
        self.parser.closure = self.closure
    }
    
    private func closure(_ message: Parser.Message) {
        switch message {
        case .ping:
            delegate?.send("PONG\r\n")
        case .pong:
            print("closure: pong!")
        case .msg(let subject, let sid, let request, let bytes, let payload):
            let message = Message(subject: subject, sid: sid, request: request, bytes: bytes, payload: payload)
            
            if let subscription = self.subscribers[message.sid] {
                if let count = subscription.maxMessages {
                    if count - 1 == 0 {
                        self.subscribers.removeValue(forKey: message.sid)
                    } else {
                        self.subscribers[message.sid]?.maxMessages = count - 1
                    }
                }
                
                subscription.closure(message)
            }
            
        case .info(let payload):
            print("closure info: \(payload)")
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
    
    @discardableResult
    public func subscribe(subject: String, _ closure: @escaping (Message) -> Void) -> String {
        let sid = generateSID()
        subscribers[sid] = Subscription(maxMessages: nil, closure: closure)
        delegate?.send("SUB \(subject) \(sid)\r\n")
        
        return sid
    }
    
    public func unsubscribe(sid: String, maxMessages: Int?) {
        subscribers[sid]?.maxMessages = maxMessages
    
        if let maxMessages = maxMessages {
            delegate?.send("UNSUB \(sid) \(maxMessages)\r\n")
        } else {
            delegate?.send("UNSUB \(sid)\r\n")
        }
    }
    
    private func generateSID() -> String {
        let sid = String(self.sid)
        self.sid += 1
        return sid
    }
    
    public func request() {
        
    }
    
    public func ping() {
        
    }
    
    public func pong() {
        
    }
}
