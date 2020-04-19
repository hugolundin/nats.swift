//
//  Message.swift
//  
//
//  Created by Hugo Lundin on 2020-04-06.
//

import Foundation

public enum Message {
    case ok
    case ping
    case pong
    case msg(subject: String, sid: String, replyTo: String? = nil, bytes: Int, payload: Data)
    case info(String)
    case error(String)
}
