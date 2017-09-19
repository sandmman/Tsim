//
//  Future.swift
//
//  Adapted from https://github.com/rfdickerson/HeliumFutures
//  Modified by Aaron Liberatore on 9/14/17.
//

import Foundation
import Dispatch

let futureQueue = DispatchQueue(label: "future", qos: .userInitiated, attributes: .concurrent)

public class Future<T> {
    
    private var value: Result<T>?
    
    private let lock = DispatchSemaphore(value: 1)
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private let timoutSemaphore = DispatchSemaphore(value: 3)

    // let group = DispatchGroup()
    
    public init() { }
    
    public func notify(_ value: Result<T>) {
        
        lock.wait()
        self.value = value
        lock.signal()
        
        semaphore.signal()
        
    }
    
    /**
     Set up a routine for when the Future has a successful value.
     
     - parameter qos:                Quality service level of the returned completionHandler
     - parameter completionHandler:  Callback with a successful value
     
     - returns: new Future
     */
    @discardableResult
    public func onSuccess<S>( completionHander: @escaping (T) throws ->S ) -> Future<S> {
        
        let nextFuture = Future<S>()
        
        futureQueue.sync() {
            
            semaphore.wait()
            
            self.lock.wait()
            let value = self.value!
            self.lock.signal()
            
            switch value {
            case .success(let a):
                
                do {
                    let returnedValue = try completionHander(a)
                    nextFuture.notify(.success(returnedValue))
                } catch {
                    // nextFuture.notify(.error())
                }
                
            case .error(let error):
                
                nextFuture.notify(.error(error))
                
            }
            
        }
        
        return nextFuture
    }
    
    /**
     Set up a routine if there is an error.
     
     - parameter completionHandler:  Callback with an error
     
     - returns: new Future
     */
    @discardableResult
    public func onFailure(completionHander: @escaping (Error)->Void) -> Future<T> {
        
        semaphore.wait()
        
        self.lock.wait()
        let value = self.value!
        self.lock.signal()
        
        switch value {
        case .error(let error):
            completionHander(error)
        default:
            break
        }
        
        
        
        return self
    }
    
    @discardableResult
    public func then(completionHandler: @escaping (T)->Void) -> Future<T> {
        // TODO: Unimplemented
        return Future()
    }
    
    public func await(timeout: Int = 5) -> Result<T> {
        onSuccess { [unowned self] _ in self.semaphore.signal() }
        .onFailure { [unowned self] _ in self.semaphore.signal() }

        _ = timoutSemaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout))
        
        return value ?? .error(.timeout(timeout))
    }
}
