//
//  System.swift
//
//  Created by Aaron Liberatore on 9/14/17.
//

import Foundation

open class System<T> {
    
    /// Current Unique Actor Reference
    ///
    private var ref = 0
    
    /// Map of Actor references to instances
    ///
    private var actors = Set<Actor<T>>()
    
    /// Init
    ///
    public init() {}

    ///
    /// Send an Tell Request
    ///
    internal func tell(sender: Actor<T>?, receiver: Actor<T>, message: T) {
        receiver.put(sender: sender, message: message)
    }
    
    ///
    /// Convienence Tell
    ///
    /// TODO: Figure out how to implicitly have access to sender
    internal func tell(receiver: Actor<T>, message: T) {
        self.tell(sender: nil, receiver: receiver, message: message)
    }
    
    ///
    /// Send an Ask Request
    ///
    internal func ask(sender: Actor<T>?, receiver: Actor<T>, message: T, timeout: Int = 5) -> T? {
        return receiver.put(sender: sender, message: message, timeout: timeout)
    }
    
    ///
    /// Convienence Ask
    ///
    /// TODO: Figure out how to implicitly have access to sender
    internal func ask(receiver: Actor<T>, message: T) -> T? {
        return self.ask(sender: nil, receiver: receiver, message: message)
    }
    
    ///
    /// Creates a new ActorRef
    ///
    private func createRef() -> ActorRef {
        self.ref += 1
        return ActorRef(value: self.ref)
    }
    
    ///
    /// Factory for new Actors
    ///
    public func create(constructor: Actor<T>.Type) -> Actor<T> {
        let actor = constructor.init(ref: createRef(), context: self)
        actors.insert(actor)
        return actor
    }
    
    ///
    /// Send a message to all actors in system
    ///
    public func blast(message: T) {
        actors.forEach {tell(receiver: $0, message: message) }
    }
}
