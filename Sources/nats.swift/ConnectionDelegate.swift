//
//  File.swift
//  
//
//  Created by Hugo Lundin on 2020-05-13.
//

import Foundation

public protocol ConnectionDelegate {
    init(receive: @escaping ((String) -> Void))
    func send(_ buffer: String)
    func connect(host: String, port: Int, _ closure: @escaping () -> Void)
}
