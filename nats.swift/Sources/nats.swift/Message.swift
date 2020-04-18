//
//  Message.swift
//  
//
//  Created by Hugo Lundin on 2020-04-06.
//

import Foundation

enum Message {
    case ping
    case pong
    case msg(message: (subject: String, bytes: Int, payload: Data, sid: String, replyTo: String?))
    case info(String)
    case error(String)
}
