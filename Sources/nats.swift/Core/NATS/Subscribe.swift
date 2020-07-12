//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-07-12.
//

import Foundation

extension NATS {
    @discardableResult
    public func subscribe(
        subject: String,
        timeout: TimeInterval? = nil,
        _ receive: @escaping (Message) -> Void) -> String
    {
        let ssid = generator.subscriptionID()
        
        connection?.send("SUB \(subject) \(ssid)\r\n")
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
        
        self.unsubscribe(ssid: ssid, reason: .timeout)
    }
}
