//
//  Collection+safe.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-28.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
