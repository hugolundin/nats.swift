//
//  Int+hex.swift
//  
//
//  Created by Hugo Lundin on 2020-05-09.
//

import Foundation

extension Int {
    var hex: String {
        return String(format: "%X", self)
    }
}
