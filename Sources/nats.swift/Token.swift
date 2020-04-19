//
//  Token.swift
//  
//
//  Created by Hugo Lundin on 2020-04-19.
//

import Foundation

internal enum Token: Equatable {
    case op(Operator)
    case string(String)
    case payload(String)
    case newline
}
