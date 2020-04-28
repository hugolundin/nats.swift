//
//  Character+isAlphanumeric.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-28.
//

import Foundation

extension Character {
    var isAlphanumeric: Bool {
        return isalnum(value) != 0 || self == "_"
    }
}
