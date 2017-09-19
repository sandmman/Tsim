//
//  Actor.swift
//
//  Created by Aaron Liberatore on 9/14/17.
//

import Foundation
import Dispatch

infix operator !
infix operator |>

open class Actor<T>: CustomStringConvertible, Hashable {
    
    /// Unique Identifier
    ///
    public let ref: ActorRef
    
    // CustomStringConvertible
    //
    public var description: String {
        return "<Actor: \(ref)>"
    }
    
    /// Hashable
    ///
    public var hashValue: Int {
        return ref.hashValue
    }
    
    /// Initializer
    ///
    required public init(ref: ActorRef, context: System<T>) {
        self.ref = ref
        self.context = context
        self.queue = DispatchQueue(label: "\(ref)")
    }
    
    ///
    /// Overrideable Message handler
    ///
    open func receive(sender: Actor<T>?, message: T) {
        
    }
    
    ///
    /// Sends message to Actor by Fire and Forget
    ///
    public func tell(actor: Actor<T>, message: T) {
        actor.context.tell(sender: self, receiver: actor, message: message)
    }
    
    ///
    /// Sends Message and awaits response
    ///
    public func ask(actor: Actor<T>, message: T, timeout: Int = 5) -> T? {
        return actor.context.ask(sender: self, receiver: actor, message: message, timeout: timeout)
    }
    
    ///
    /// Sends message to Actor by Fire and Forget
    ///
    public static func !(actor: Actor<T>, message: T) -> Void {
        return actor.context.tell(receiver: actor, message: message)
    }
    
    ///
    /// Sends Message and awaits response
    ///
    public static func |>(actor: Actor<T>, message: T) -> T? {
        return actor.context.ask(sender: actor, receiver: actor, message: message, timeout: 5)
    }
    
    ///
    /// Equatable Protocol
    ///
    public static func ==(lhs: Actor<T>, rhs: Actor<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    ///
    /// Actor Context
    ///
    internal let context: System<T>
    
    ///
    /// Message processing Queue
    ///
    private var queue: DispatchQueue?
    
    ///
    /// Asynchronous message handler for tell requests ( ! )
    ///
    internal func put(sender: Actor<T>?, message: T) {
        guard let q = self.queue else { return }
        q.async {
            self.receive(sender: sender, message: message)
        }
    }
    
    ///
    /// Synchronous message handler for ask requests ( ? )
    ///
    internal func put(sender: Actor<T>?, message: T, timeout: Int = 5) -> T? {
        // guard let q = self.queue else { return nil }
        let promise = Promise<T>()
        
        // Create Intermediary Mailbox Actor
        let mailbox = self.context.createActor(of: Mailbox<T>.self) as! Mailbox<T>
        mailbox.forward(future: promise.future, actor: self, message: message)
        
        // Await Response Synchronously
        switch promise.await() {
        case .success(let t) : return t
        case .error(_) : return nil
        }
    }
}
