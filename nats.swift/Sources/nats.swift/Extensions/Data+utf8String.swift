//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-04-06.
//

import Foundation

extension Data {
    var utf8String: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
