//
//  Generator.swift
//  
//
//  Created by Hugo Lundin on 2020-07-11.
//

import Foundation

internal final class Generator {
    private var ssid: Int = 3
}

extension Generator {
    
    /// Generate a new subscription ID.
    internal func subscriptionID() -> String {
        self.ssid += 1
        return String(self.ssid.hex)
    }
}

// TODO: Actually generate something random.
// The thing below is simply for being able
// to test request/reply using a known set of
// "unique" id:s.

extension Generator {
    private static let INBOX_PREFIX = "_INBOX"
    
    private static let STRINGS = [
        "2007314fe0fcb2cdc2a2914c1",
        "2007314fe0fcb2cdcc17a81fc1",
        "2007314fccafcb2cdc2a2914c1",
        "2007314fe0fcb2cdc2a2914c1",
        "2007314f7f9afb2cdc2a2914c1",
        "b2cdc2a2914c12cdc2a2914c1",
        "2007314fe0fcb2cdc2a2914c1",
        "2007314b2cdc2a2914c1914c1",
        "4fe0fcb2cb2cdc2a2914c14c1",
        "b2cdc2a2914c1b2cdc21a2ccc",
    ]
    
    /// Generate a new subject to be used as an inbox
    /// for request-reply.
    internal func inboxSubject() -> String {
        "\(Generator.INBOX_PREFIX).\(Generator.STRINGS.randomElement() ?? "")"
    }
}
