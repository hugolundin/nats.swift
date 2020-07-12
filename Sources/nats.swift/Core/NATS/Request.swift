//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-07-12.
//

import Foundation

extension NATS {
    public func request(
        subject: String,
        payload: String = "",
        timeout: TimeInterval = 0.05,
        _ receive: @escaping (Message) -> Void)
    {
        let inbox = generator.inboxSubject()
        let ssid = subscribe(subject: inbox, timeout: timeout, receive)
        print("Subscribe [timestamp]: \(Date())")

        unsubscribe(ssid: ssid, maxMessages: 1)
        publish(subject: subject, payload: payload, replyTo: inbox)
    }
}
