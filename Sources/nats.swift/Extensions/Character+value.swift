//
//  Character+value.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-28.
//

import Foundation

extension Character {
    var value: Int32 {
        guard let unicodeScalar = String(self).unicodeScalars.first else {
            return 0
        }
        
        return Int32(unicodeScalar.value)
    }
}
