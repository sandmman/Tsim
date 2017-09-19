//
//  Promise
//
//  Adapted from https://github.com/rfdickerson/HeliumFutures
//  Modified by Aaron Liberatore on 9/14/17.
//

import Foundation
import Dispatch

public class Promise<T> {
    
    let dispatchQueue: DispatchQueue
    
    let future: Future<T>
    
    init() {
        
        future = Future<T>()
        
        dispatchQueue = DispatchQueue(label: "promise",
                                      qos: .userInitiated,
                                      attributes: .concurrent)
    }
    
    func completeWithSuccess(value: T) {
        future.notify(.success(value))
    }
    
    func completeWithFail(error: AkkaError) {
        future.notify(.error(error))
    }
    
    func await(timeout: Int = 5) -> Result<T> {
        return future.await(timeout: timeout)
    }
}
