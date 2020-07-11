//
//  NATS+Subscription.swift
//  
//
//  Created by Hugo Lundin on 2020-05-19.
//

import Foundation

internal class Subscription {
    var maxMessages: Int?
    var receivedMessages = 0
    let receive: (Message) -> Void
    
    internal init(receive: @escaping (Message) -> Void) {
        self.receive = receive
    }
}
