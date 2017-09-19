//
//  Mailbox
//
//  Created by Aaron Liberatore on 9/14/17.
//

import Foundation

internal class Mailbox<T>: Actor<T> {
    
    internal var future: Future<T>?

    func forward(future: Future<T>, actor: Actor<T>, message: T) {
        self.future = future
        context.tell(sender: self, receiver: actor, message: message)
    }
    
    override func receive(sender: Actor<T>?, message: T) {
        future?.notify(.success(message))
    }
}
