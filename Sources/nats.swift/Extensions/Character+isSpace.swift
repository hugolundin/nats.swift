//
//  Character+isSpace.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-28.
//

import Foundation

extension Character {
    var isSpace: Bool {
        return isspace(value) != 0
    }
}
