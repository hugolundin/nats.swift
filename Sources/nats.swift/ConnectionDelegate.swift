//
//  ConnectionDelegate.swift
//  
//
//  Created by Hugo Lundin on 2020-05-13.
//

import Foundation

/// A user of `swift.nats` can replace the default connection implementation with
/// its own by implementing this protocol. `nats.swift` will call its functions while
/// running.
///
/// This protocol allows for mocking during development, testing and debugging.
/// It also makes it possible to use it on platforms where the default implementation
/// isn't supported (Linux/Windows) or not suitable for the particular situation.
public protocol ConnectionDelegate {
    
    /// Receive is passed to the delegate when `NATS` is instantiated.
    /// It should be called by the `ConnectionDelegate` when it receives
    /// data that should go to NATS.
    var receive: ((String) -> Void)? { get set }
    
    /// `NATS` will call this function when it wants to send data.
    ///
    /// - Parameters:
    ///     - buffer: What should be sent over the connection.
    func send(_ buffer: String)
    
    /// `NATS` will call this function when it wants to connect.
    ///
    /// - Parameters:
    ///    - host: Host to establish a connection with.
    ///    - port: What port to use.
    ///    - connected: Closure that should be called when connected.
    func connect(host: String, port: Int, _ connected: @escaping () -> Void)
}
