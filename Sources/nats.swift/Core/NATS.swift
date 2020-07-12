//
//  NATS.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-05-01.
//

import Foundation
import os.log

public class NATS {
    public var connection: ConnectionDelegate?
    
    private let parser: Parser
    private let generator: Generator
    private var subscriptions = [String : (subscription: Subscription, timer: Timer?)]()
    
    public init(connection: ConnectionDelegate = DefaultConnectionDelegate()) {
        self.connection = connection
        self.parser = Parser()
        self.generator = Generator()
        
        self.parser.closure = self.dispatch
        self.connection?.receive = self.receive
    }
    
    private func dispatch(_ message: Parser.Incoming) {
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
    
    private func receive(buffer: String) {
        do {
            try parser.parse(input: buffer)
        } catch {
            parser.reset()
            print(error)
        }
    }
    
    private func msg(_ message: Message) {
        guard let subscription = subscriptions[message.ssid]?.subscription else {
            os_log("A subscription with ssid \(message.ssid, privacy: .sensitive) does not exist.")
            return
        }
        
        subscription.receive(message)
        
        if let maxMessages = subscription.maxMessages {
            if maxMessages == 1 {
                self.unsubscribe(ssid: message.ssid)
            } else {
                subscription.maxMessages = maxMessages - 1
            }
        }
    }
    
    private func info(_ info: String) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let infoData = info.data(using: .utf8) else {
            return
        }
        
        guard let infoOptions = try? decoder.decode(Options.Info.self, from: infoData) else {
            return
        }

        if let connect = generator.connect() {
            connection?.send(connect)
        }
    }
    
    public func connect(_ closure: @escaping (Result<Void, Error>) -> Void) {
        connection?.connect(host: "localhost", port: 4222) {
            closure(.success(()))
        }
    }
    
    public func ping() {
        connection?.send(generator.ping())
    }
    
    public func pong() {
        connection?.send(generator.pong())
    }
    
    public func publish(subject: String, payload: String = "", replyTo: String = "") {
        connection?.send(generator.publish(subject: subject, payload: payload, replyTo: replyTo))
    }
    
    public func request(
        subject: String,
        payload: String = "",
        timeout: TimeInterval = 0.05,
        _ receive: @escaping (Message) -> Void)
    {
        let inbox = generator.inboxSubject()
        let ssid = subscribe(subject: inbox, timeout: timeout, receive)

        unsubscribe(ssid: ssid, maxMessages: 1)
        publish(subject: subject, payload: payload, replyTo: inbox)
    }
    
    @discardableResult
    public func subscribe(
        subject: String,
        timeout: TimeInterval? = nil,
        _ receive: @escaping (Message) -> Void) -> String
    {
        let ssid = generator.subscriptionID()
        
        connection?.send(generator.subscribe(subject: subject, ssid: ssid))
        subscriptions[ssid] = (subscription: Subscription(receive: receive), nil)
        
        if let timeout = timeout {
            subscriptions[ssid]?.timer = Timer.scheduledTimer(
                timeInterval: timeout,
                target: self,
                selector: #selector(self.timeout),
                userInfo: ssid,
                repeats: false
            )
        }
        
        return ssid
    }
    
    @objc private func timeout(sender: Timer) {
        guard let ssid = sender.userInfo as? String else {
            os_log("Unable to cast sender.userInfo to String")
            return
        }
        
        self.unsubscribe(ssid: ssid, maxMessages: nil)
    }
    
    public func unsubscribe(ssid: String, maxMessages: Int? = nil) {
        guard let subscription = subscriptions[ssid]?.subscription else {
            os_log("A subscription with ssid \(ssid, privacy: .sensitive) does not exist.")
            return
        }
        
        if let maxMessages = maxMessages {
            subscription.maxMessages = maxMessages
        } else {
            subscriptions.removeValue(forKey: ssid)
        }
        
        connection?.send(generator.unsubscribe(ssid: ssid, maxMessages: maxMessages))
    }
}
