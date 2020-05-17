//
//  NATS.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-05-01.
//

import Foundation

extension NATS {
    internal class Subscription {
        var maxMessages: Int?
        var receivedMessages = 0
        let receive: (Message) -> Void
        
        internal init(receive: @escaping (Message) -> Void) {
            self.receive = receive
        }
    }
}

public class NATS {
    private let parser: Parser
    private var subscriptions = [String : Subscription]()
    
    
    /// Delegate.
    public var delegate: ConnectionDelegate?
    
    public init(delegate: ConnectionDelegate.Type = DefaultConnectionDelegate.self) {
        self.parser = Parser()
        self.parser.closure = self.closure
        self.delegate = delegate.init(receive: receive)
    }
    
    private func closure(_ message: Parser.Incoming) {
        switch message {
        case .ping:
            self.pong()
        case .pong:
            self.ping()
        case .msg(let message):
            self.msg(message)
        case .info(let payload):
            self.info(payload)
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
    public func subscribe(subject: String, _ receive: @escaping (Message) -> Void) -> String {
        let sid = generateSubscriptionId()
        delegate?.send("SUB \(subject) \(sid)\r\n")
        subscriptions[sid] = Subscription(receive: receive)
        return sid
    }
    
    public func unsubscribe(sid: String, maxMessages: Int? = nil) {
        guard let subscription = subscriptions[sid] else {
            // TODO: Log error.
            return
        }
        
        if let maxMessages = maxMessages {
            delegate?.send("UNSUB \(sid) \(maxMessages)\r\n")
            subscription.maxMessages = maxMessages
        } else {
            delegate?.send("UNSUB \(sid)\r\n")
            subscriptions.removeValue(forKey: sid)
        }
    }
    
    private func msg(_ message: Message) {
        guard let subscription = subscriptions[message.sid] else {
            // TODO: Log error.
            return
        }
        
        subscription.receive(message)
        
        if let maxMessages = subscription.maxMessages {
            if maxMessages == 1 {
                self.unsubscribe(sid: message.sid)
            } else {
                subscription.maxMessages = maxMessages - 1
            }
        }
    }
    
    private func info(_ info: String) {
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
    
    public func request(subject: String, payload: String = "", _ receive: @escaping (Message) -> Void) {
        let inbox = generateInboxSubject()
        let sid = subscribe(subject: inbox, receive)
        
        unsubscribe(sid: sid, maxMessages: 1)
        publish(subject: subject, payload: payload, replyTo: inbox)
    }
    
    public func ping() {
        delegate?.send("PONG\r\n")
    }
    
    public func pong() {
        delegate?.send("PONG\r\n")
    }
    
    private var subscriptionIdCounter = 0
    
    private func generateSubscriptionId() -> String {
        let sid = String(subscriptionIdCounter.hex)
        subscriptionIdCounter += 1
        return sid
    }
    
    private func generateInboxSubject() -> String {
        return "INBOX.123123123123.123"
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
