//
//  Token.swift
//  
//
//  Created by Hugo Lundin on 2020-04-06.
//

import Foundation

internal enum Token: String {
    case string
    case linebreak
    
    // MARK: Message operators
    case ok
    case msg
    case ping
    case pong
    case info
    case error
}
