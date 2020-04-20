# nats.swift

![Swift](https://github.com/hugolundin/nats.swift/workflows/Swift/badge.svg)

A Swift library for using the NATS protocol.

## Planned features

`nats.swift` is still in an early development stage, but some of the planned features are:
- [ ] A robust NATS client protocol parser.
    - [ ] Support for partial reads
- [ ] An I/O-free client library.
    * The user provides callbacks for I/O interactions while this library is simply responsible for handling NATS (inspired by wslay).
    * The user can provide an optional context that is passed with all callbacks. 
    * Great support for Request/Reply.
- [ ] A convenience wrapper that also handles I/O.
- [ ] Great support for using it together with either UIKit or SwiftUI. 
    * Combine support
- [ ] Linux (and Windows) compability.
