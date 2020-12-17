//
//  MainView.swift
//  nats-gui
//
//  Created by Hugo Lundin on 2020-12-17.
//

import SwiftUI
import nats_swift

struct MainView: View {
    let nats: NATS
    @State var received = [Message]()
    
    var body: some View {
        ForEach(received) { message in
            Text(message.payload)
        }.onAppear(perform: load)
    }
    
    private func load() {
        nats.subscribe(subject: "FOO") { message in
            received.append(message)
        }
    }
}
