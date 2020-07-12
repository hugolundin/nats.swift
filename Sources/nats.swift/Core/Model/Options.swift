//
//  NATS+ConnectOptions.swift
//  
//
//  Created by Hugo Lundin on 2020-05-19.
//

import Foundation

internal struct Options {
    internal struct Connect: Codable {
        var verbose: Bool = false
        var pedantic: Bool = false
        var tlsRequired: Bool? = nil
        var authToken: String? = nil
        var user: String? = nil
        var pass: String? = nil
        var name = "swift.nats"
        var lang = "swift"
        var version = "0.1"
        var `protocol` = 0
        var echo: Bool = false
    }
    
    internal struct Info: Codable {
        var serverId: String? = nil
        var version: String? = nil
        var go: String? = nil
        var host: String? = nil
        var port: Int? = nil
        var maxPayload: Int? = nil
        var proto: Int? = nil
        var clientId: Int? = nil
        var authRequired: Bool? = nil
        var tlsRequired: Bool? = nil
        var tlsVerify: Bool? = nil
        var connectUrls: [String]? = nil
    }
}
