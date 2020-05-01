//
//  NATSTests.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-05-01.
//

import Foundation

import XCTest
import Foundation
@testable import nats_swift

final class NATSTests: XCTestCase {
    func testSetup() {
        class MockDelegate: IODelegate {
            func send(_ buffer: String) {
                // print(buffer)
            }
        }
        
        let nats = NATS(delegate: MockDelegate())
        
        nats.subscribe(subject: "hej") { message in
            print("Received: \(message)")
        }
        
        nats.receive(buffer: "MSG hej 123 10\r\nhej på dig\r\n")
    }
    
    static var allTests = [
        ("testSetup", testSetup)
    ]
}


