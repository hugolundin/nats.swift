//
//  NATS.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-05-01.
//

import Foundation
import os.log

public class NATS {
    public enum Error: Swift.Error {
        case `internal`
        case emptySubject
        case unknownSubject
        case invalidTimeout
    }
    
    public var connection: ConnectionDelegate?
    
    private let parser: Parser
    private let generator: Generator
    private var subscriptions = [String : (subscription: Subscription, timer: Timer?)]()
    
    public static func connect(
        host: String = "localhost",
        port: Int = 4222,
        connection: ConnectionDelegate = DefaultConnectionDelegate(),
        _ closure: @escaping (Result<NATS, Error>) -> Void)
    {
        let nats = NATS(connection: connection)
        nats.connection?.connect(host: host, port: port) {
            closure(.success(nats))
        }
    }
    
    private init(connection: ConnectionDelegate) {
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
            os_log("A subscription with ssid %@ does not exist.", message.ssid)
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
        
        guard let data = info.data(using: .utf8) else {
            return
        }
        
        guard let options = try? decoder.decode(Options.Info.self, from: data) else {
            return
        }
        
        os_log("Connected to %@:%@", options.host ?? "0.0.0.0", String(describing: options.port ?? 4222))

        if let connect = generator.connect() {
            connection?.send(connect)
        }
    }
    
    public func ping() {
        connection?.send(generator.ping())
    }
    
    public func pong() {
        connection?.send(generator.pong())
    }
    
    @discardableResult
    public func publish(subject: String, payload: String = "", replyTo: String = "") -> Result<Void, Error> {
        guard subject.count > 0 else {
            return .failure(.emptySubject)
        }
        
        let result = generator.publish(subject: subject, payload: payload, replyTo: replyTo)
        
        switch result {
        case .success(let message):
            connection?.send(message)
        case .failure(let error):
            switch error {
            case .emptySSID:
                return .failure(.internal)
            case .emptySubject:
                return .failure(.emptySubject)
            }
        }
        
        return .success(())
    }
    
    @discardableResult
    public func request(
        subject: String,
        payload: String = "",
        timeout: TimeInterval = 0.05,
        _ receive: @escaping (Message) -> Void) -> Result<Void, Error>
    {
        guard subject.count > 0 else {
            return .failure(.emptySubject)
        }
        
        guard timeout > 0 else {
            return .failure(.invalidTimeout)
        }
        
        let inbox = generator.inboxSubject()
        let result = subscribe(subject: inbox, timeout: timeout, receive)
        
        switch result {
        case .success(let ssid):
            unsubscribe(ssid: ssid, maxMessages: 1)
            publish(subject: subject, payload: payload, replyTo: inbox)
            
        case .failure(let error):
            return .failure(error)
        }

        return .success(())
    }
    
    @discardableResult
    public func subscribe(
        subject: String,
        timeout: TimeInterval? = nil,
        _ receive: @escaping (Message) -> Void) -> Result<String, Error>
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
        
        return .success(ssid)
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
            os_log("A subscription with ssid %@) does not exist.", ssid)
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
