//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-05-10.
//

import Foundation

public struct Message: Hashable {
    let id = UUID()
    public let subject: String
    public let sid: String
    public let replyTo: String?
    public let bytes: Int
    public let payload: String
}
