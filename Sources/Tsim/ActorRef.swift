//
//  ActorRef.swift
//
//  Created by Aaron Liberatore on 9/14/17.
//

import Foundation

public struct ActorRef: CustomStringConvertible, Hashable {
    let value: Int
    
    public var description: String {
        return "\(value)"
    }
    
    public var hashValue: Int {
        return value
    }
    
    public static func ==(lhs: ActorRef, rhs:ActorRef) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
