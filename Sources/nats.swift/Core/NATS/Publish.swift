//
//  NATS+publish.swift
//  
//
//  Created by Hugo Lundin on 2020-07-12.
//

import Foundation

extension NATS {
    public func publish(subject: String, payload: String = "", replyTo: String = "") {
        if replyTo.count > 0 {
            connection?.send("PUB \(subject) \(replyTo) \(payload.count)\r\n\(payload)\r\n")
        } else {
            connection?.send("PUB \(subject) \(payload.count)\r\n\(payload)\r\n")
        }
    }
}
