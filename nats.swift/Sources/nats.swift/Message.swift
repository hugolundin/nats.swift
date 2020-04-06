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
    case msg(subject: String, bytes: Int, payload: Data, sid: String, replyTo: String? = nil)
    case info(String)
}
