//
//  NATS.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-05-01.
//

import Foundation

public class NATS {
    private var sid: Int
    private let parser: Parser
    
    public var delegate: ConnectionDelegate?
    private var subscribers = [String : Subscription]()
    
    public init(delegate: ConnectionDelegate.Type = DefaultConnectionDelegate.self) {
        self.sid = 0
        self.parser = Parser()
        self.parser.closure = self.closure
        self.delegate = delegate.init(receive: receive)
    }
    
    private func closure(_ message: Parser.Message) {
        switch message {
        case .ping:
            delegate?.send("PONG\r\n")
            print("sending pong")
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
            
        case .info(let data):
            self.handle(info: data)

        case .ok:
            break
        case .error(_):
            break
        }
    }
    
    public func receive(buffer: String) {
        do {
            try parser.parse(input: buffer)
        } catch {
            parser.reset()
            print(error)
        }
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
        let sid = String(self.sid.hex)
        self.sid += 1
        return sid
    }
    
    private func handle(info: String) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        
        guard let infoData = info.data(using: .utf8) else {
            return
        }
        
        guard let infoOptions = try? decoder.decode(InfoOptions.self, from: infoData) else {
            return
        }

        print(infoOptions)
        
        guard let connectData = try? encoder.encode(ConnectOptions()) else {
            return
        }
        
        guard let connect = String(data: connectData, encoding: .utf8) else {
            return
        }
        
        print(connect)
        
        // delegate?.send("CONNECT \(connect)")
    }
    
    public func connect(_ closure: @escaping (Result<Void, Error>) -> Void) {
        delegate?.connect(host: "localhost", port: 4222) {
            closure(.success(()))
        }
    }
    
    public func request() {
        
    }
    
    public func ping() {
        
    }
    
    public func pong() {
        
    }
}

internal struct ConnectOptions: Codable {
    let verbose: Bool = false
    let pedantic: Bool = false
    let tlsRequired: Bool? = nil
    let authToken: String? = nil
    let user: String? = nil
    let pass: String? = nil
    let name = "swift.nats"
    let lang = "swift"
    let version = "0.1"
    let `protocol` = 0
    let echo: Bool = false
}

internal struct InfoOptions: Codable {
    let serverId: String? = nil
    let version: String? = nil
    let go: String? = nil
    let host: String? = nil
    let port: Int? = nil
    let maxPayload: Int? = nil
    let proto: Int? = nil
    let clientId: Int? = nil
    let authRequired: Bool? = nil
    let tlsRequired: Bool? = nil
    let tlsVerify: Bool? = nil
    let connectUrls: [String]? = nil
}
