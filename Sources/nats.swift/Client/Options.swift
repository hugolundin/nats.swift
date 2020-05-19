//
//  NATS+ConnectOptions.swift
//  
//
//  Created by Hugo Lundin on 2020-05-19.
//

import Foundation

internal struct Options {
    internal struct Connect: Codable {
        let verbose: Bool = false
        let pedantic: Bool = false
        let tlsRequired: Bool? = nil
        let authToken: String? = nil
        let user: String? = nil
        let pass: String? = nil
        let name = "swift.nats"
        let lang = "swift"
        let version = "0.1"
        let `protocol` = 0
        let echo: Bool = false
    }
    
    internal struct Info: Codable {
        let serverId: String? = nil
        let version: String? = nil
        let go: String? = nil
        let host: String? = nil
        let port: Int? = nil
        let maxPayload: Int? = nil
        let proto: Int? = nil
        let clientId: Int? = nil
        let authRequired: Bool? = nil
        let tlsRequired: Bool? = nil
        let tlsVerify: Bool? = nil
        let connectUrls: [String]? = nil
    }
}
