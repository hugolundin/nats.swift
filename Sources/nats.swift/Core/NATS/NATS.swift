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
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        
        guard let infoData = info.data(using: .utf8) else {
            return
        }
        
        guard let infoOptions = try? decoder.decode(Options.Info.self, from: infoData) else {
            return
        }

        // print(infoOptions)
        
        guard let connectData = try? encoder.encode(Options.Connect()) else {
            return
        }
        
        guard let connect = String(data: connectData, encoding: .utf8) else {
            return
        }

        // os_log("\(connect, privacy: .public)")
        
        // delegate?.send("CONNECT \(connect)")
    }
    
    public func connect(_ closure: @escaping (Result<Void, Error>) -> Void) {
        connection?.connect(host: "localhost", port: 4222) {
            closure(.success(()))
        }
    }
    
    public func ping() {
        connection?.send("PING\r\n")
    }
    
    public func pong() {
        connection?.send("PONG\r\n")
    }
}
