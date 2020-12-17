//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-05-10.
//

import Foundation

public struct Message: Hashable, Identifiable {
    public let id = UUID()
    public let subject: String
    public let ssid: String
    public let replyTo: String?
    public let bytes: Int
    public let payload: String
    
}
