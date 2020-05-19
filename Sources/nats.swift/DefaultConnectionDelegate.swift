//
//  DefaultConnectionDelegate.swift
//  
//
//  Created by Hugo Lundin on 2020-05-13.
//

import Foundation
import Network

public final class DefaultConnectionDelegate: ConnectionDelegate {
    private var connection: Connection?
    public var receive: ((String) -> Void)?
    
    public init() {
        self.connection = nil
        self.receive = nil
    }
    
    public func send(_ buffer: String) {
        guard let data = buffer.data(using: .utf8) else {
            return
        }
        
        connection?.send(data: data)
    }
    
    private func receive(_ data: Data) {
        guard let payload = String(data: data, encoding: .utf8) else {
            return
        }
        
        self.receive?(payload)
    }
    
    public func connect(host: String, port: Int, _ closure: @escaping () -> Void) {
        let networkConnection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(String(describing: port))!, using: .tcp)
        self.connection = Connection(networkConnection)
        self.connection?.didReceiveCallback = receive
        self.connection?.start() {
            closure()
        }
    }
}

internal final class Connection {
    let id: Int
    let connection: NWConnection

    private static var nextID: Int = 0
    var didStopCallback: ((Error?) -> Void)? = nil
    var didConnectCallback: (() -> Void)? = nil
    var didReceiveCallback: ((Data) -> Void)? = nil

    internal init(_ connection: NWConnection) {
        self.connection = connection
        self.id = Connection.nextID
        Connection.nextID += 1
    }
    
    func start(_ closure: @escaping () -> Void) {
        print("connection \(self.id) will start")
        self.connection.stateUpdateHandler = self.stateDidChange(to:)
        self.setupReceive()
        self.connection.start(queue: .main)
        self.didConnectCallback = closure
    }
    
    func send(data: Data) {
        self.connection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }
    
    func stop() {
        
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .setup:
            break
        case .waiting(let error):
            self.connectionDidFail(error: error)
        case .preparing:
            break
        case .ready:
            print("connection \(self.id) ready")
            self.didConnectCallback?()
        case .failed(let error):
            self.connectionDidFail(error: error)
        case .cancelled:
            break
        default:
            break
        }
    }
    
    private func connectionDidFail(error: Error) {
        print("connection \(self.id) did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection \(self.id) did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.connection.stateUpdateHandler = nil
        self.connection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
    
    private func setupReceive() {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.didReceiveCallback?(data)
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }
}
