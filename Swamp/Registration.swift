//
//  Registration.swift
//  SwampFramework
//
//  Created by Борис Кузнецов on 26.11.2019.
//  Copyright © 2019 iscriptology. All rights reserved.
//

import Foundation

open class Registration {
    fileprivate let session: SwampSession
    internal let registration: NSNumber
    internal let queue: DispatchQueue
    internal var onFire: SwampProc
    fileprivate var isActive: Bool = true
    public let proc: String

    internal init(session: SwampSession, registration: NSNumber, onFire: @escaping SwampProc, proc: String, queue: DispatchQueue) {
        self.session = session
        self.registration = registration
        self.onFire = onFire
        self.proc = proc
        self.queue = queue
    }

    internal func invalidate() {
        self.isActive = false
    }

//    open func cancel(_ onSuccess: @escaping UnregisterCallback, onError: @escaping ErrorUnregsiterCallback) {
//        if !self.isActive {
//            onError([:], "Registration already inactive.")
//        }
//        self.session.unregister(registration, onSuccess: onSuccess, onError: onError, queue: self.queue)
//    }

    open func changeOnFire(callback: @escaping SwampProc) {
        self.onFire = callback
    }
}
