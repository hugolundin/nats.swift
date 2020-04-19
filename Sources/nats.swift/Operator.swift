//
//  Operator.swift
//  
//
//  Created by Hugo Lundin on 2020-04-18.
//

import Foundation

public enum Operator: String, Equatable {
    case info = "INFO"
    case msg = "MSG"
    case ok = "+OK"
    case connect = "CONNECT"
    case error = "-ERR"
    case ping = "PING"
    case pong = "PONG"
}
