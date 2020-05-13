//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-05-10.
//

import Foundation

internal struct Subscription {
    var maxMessages: Int?
    let closure: (Message) -> Void
}
