//
//  Generator.swift
//  
//
//  Created by Hugo Lundin on 2020-07-11.
//

import Foundation

internal final class Generator {
    private var ssid: Int = 0
    
    /// Generate a new subscription ID.
    internal func subscriptionID() -> String {
        self.ssid += 1
        return String(self.ssid.hex)
    }
    
    // TODO: Actually generate something random.
    // The thing below is simply for being able
    // to test request/reply using a known set of
    // "unique" id:s.
    private let INBOX_PREFIX = "_INBOX"
    
    private let STRINGS = [
        "2007314fe0fcb2cdc2a2914c1",
        "2007314fe0fcb2cdcc17a81fc1",
        "2007314fccafcb2cdc2a2914c1",
        "2007314fe0fcb2cdc2a2914c1",
        "2007314f7f9afb2cdc2a2914c1",
        "b2cdc2a2914c12cdc2a2914c1",
        "2007314fe0fcb2cdc2a2914c1",
        "2007314b2cdc2a2914c1914c1",
        "4fe0fcb2cb2cdc2a2914c14c1",
        "b2cdc2a2914c1b2cdc21a2ccc",
    ]
    
    /// Generate a new subject to be used as an inbox
    /// for request-reply.
    internal func inboxSubject() -> String {
        "\(INBOX_PREFIX).\(STRINGS.randomElement() ?? "")"
    }
    
    internal func connect() -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(Options.Connect()) else {
            return nil
        }
        
        guard let connect = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return "CONNECT \(connect)"
    }
    
    internal func ping() -> String {
        "PING\r\n"
    }
    
    internal func pong() -> String {
        "PONG\r\n"
    }
    
    internal func publish(subject: String, payload: String, replyTo: String) -> String {
        if replyTo.count > 0 {
            return "PUB \(subject) \(replyTo) \(payload.count)\r\n\(payload)\r\n"
        } else {
            return "PUB \(subject) \(payload.count)\r\n\(payload)\r\n"
        }
    }
    
    internal func subscribe(subject: String, ssid: String
    ) -> String {
        "SUB \(subject) \(ssid)\r\n"
    }
    
    internal func unsubscribe(ssid: String, maxMessages: Int?) -> String {
        
        if let maxMessages = maxMessages {
            return "UNSUB \(ssid) \(maxMessages)\r\n"
        } else {
            return "UNSUB \(ssid)\r\n"
        }
    }
}
