//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-05.
//

import Foundation

internal final class Parser {
    internal enum State {
        case initial
        case invalid
        
        // INFO {["option_name":option_value],...}
        case i
        case `in`
        case inf
        case info
        case info_payload
        
        // MSG <subject> <sid> [reply-to] <#bytes>\r\n[payload]\r\n
        case m
        case ms
        case msg
        
        case msg_subject
        case msg_sid
        case msg_replyTo
        case msg_Bytes
        case msg_Payload
        
        // PING\r\n
        case p
        case pi
        case pin
        case ping
        
        // PONG\r\n
        case po
        case pon
        case pong
        
        // +OK
        case plus
        case plus_o
        case plus_ok
        
        // -ERR <error message>
        case minus
        case minus_e
        case minus_er
        case minus_err
        
        case minus_err_message
    }
}
