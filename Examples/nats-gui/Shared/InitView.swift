//
//  InitView.swift
//  nats-gui
//
//  Created by Hugo Lundin on 2020-12-17.
//

import SwiftUI
import nats_swift

struct InitView: View {
    @State var nats: NATS?
    
    var body: some View {
        Group {
            if let nats = nats {
                MainView(nats: nats)
            } else {
                ProgressView()
            }
        }
        .frame(minWidth: 500, minHeight: 300)
        .onAppear(perform: load)
    }
    
    private func load() {
        NATS.connect { result in
            switch result {
            case .success(let nats):
                self.nats = nats
            case .failure(let error):
                // TODO: Show an error.
                print(error.localizedDescription)
            }
        }
    }
}
