//
//  NATSDelegate.swift
//  nats.swift
//
//  Created by Hugo Lundin on 2020-04-26.
//

import Foundation

/**
 # IO Delegate
 
 The plan is to replicate what `wslay` does:
 - `nats.swift` isn't responsible at all for IO. Instead we give it something implementing the `IODelegate`
 which it then will use for sending messages.
 
 Examples:
 1. `publish` is called. This will call `send` on the delegate with a buffer of data that should be sent.
 2. A message is received. This is indicated from the users side by calling `receive` on something.
 3. `request` is called. This will also call `send` on the delegate, with a buffer prepared for a request.
 */


