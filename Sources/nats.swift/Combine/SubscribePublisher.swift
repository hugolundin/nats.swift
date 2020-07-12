//
//  SubscribePublisher.swift
//  
//
//  Created by Hugo Lundin on 2020-07-12.
//

//import Foundation
//import Combine
//import UIKit
//
//extension NATS {
//    var subscriptionPublisher: String {
//        ""
//    }
//}
//
//extension Publishers {
//    struct NATS_SubscriptionPublisher: Publisher {
//        typealias Output = Void
//        typealias Failure = Never
//
//        private let nats: NATS
//
//        init(nats: NATS) {
//            self.nats = nats
//        }
//
//        func receive<S>(subscriber: S)
//            where S :
//                    Subscriber,
//                    Publishers.NATS_SubscriptionPublisher.Failure == S.Failure,
//                    Publishers.NATS_SubscriptionPublisher.Output == S.Input
//        {
//            let subscription = NATS_SubscriptionSubscription(subscriber: subscriber, nats: nats)
//            subscriber.receive(subscription: subscription)
//        }
//    }
//
//    class NATS_SubscriptionSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
//        private var subscriber: S?
//        private weak var nats: NATS?
//
//        init(subscriber: S, nats: NATS) {
//            self.subscriber = subscriber
//            self.nats = nats
//            subscribe()
//        }
//
//        func request(_ demand: Subscribers.Demand) { }
//
//        func cancel() {
//            subscriber = nil
//            nats = nil
//        }
//
//        private func subscribe() {
//            nats?.subscribe(subject: "test") { [self] _ in
//                _ = subscriber?.receive(())
//            }
//        }
//    }
//}
//
//extension Publishers {
//    struct ButtonPublisher: Publisher {
//        typealias Output = Void
//        typealias Failure = Never
//
//        private let button: UIButton
//
//        init(button: UIButton) { self.button = button }
//
//        func receive<S>(subscriber: S) where S : Subscriber, Publishers.ButtonPublisher.Failure == S.Failure, Publishers.ButtonPublisher.Output == S.Input {
//            let subscription = ButtonSubscription(subscriber: subscriber, button: button)
//            subscriber.receive(subscription: subscription)
//        }
//    }
//
//    class ButtonSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
//
//        private var subscriber: S?
//        private weak var button: UIButton?
//
//        init(subscriber: S, button: UIButton) {
//            self.subscriber = subscriber
//            self.button = button
//            subscribe()
//        }
//
//        func request(_ demand: Subscribers.Demand) { }
//
//        func cancel() {
//            subscriber = nil
//            button = nil
//        }
//
//        private func subscribe() {
//            button?.addTarget(self,
//                              action: #selector(tap(_:)),
//                              for: .touchUpInside)
//        }
//
//        @objc private func tap(_ sender: UIButton) {
//            _ = subscriber?.receive(())
//        }
//    }
//}
