//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-07-12.
//

import Foundation

extension NATS {
    public enum UnsubscribeReason {
        case `default`
        case timeout
    }
    
    public func unsubscribe(ssid: String, maxMessages: Int? = nil, reason: UnsubscribeReason = .default) {
        guard let subscription = subscriptions[ssid]?.subscription else {
            os_log("A subscription with ssid \(ssid, privacy: .sensitive) does not exist.")
            return
        }
        
        if let maxMessages = maxMessages {
            connection?.send("UNSUB \(ssid) \(maxMessages)\r\n")
            subscription.maxMessages = maxMessages
        } else {
            connection?.send("UNSUB \(ssid)\r\n")
            subscriptions.removeValue(forKey: ssid)
        }
        
        if reason == .timeout {
            print("Unsubscribe [timestamp]: \(Date())")
        }
    }
}
