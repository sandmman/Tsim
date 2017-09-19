//
//  AkkaError.swift
//
//  Created by Aaron Liberatore on 9/14/17.
//

import Foundation

public enum AkkaError: Error, CustomStringConvertible {
    case timeout(Int)
    
    public var description: String {
        switch self {
        case .timeout(let t): return "Time exceeded timeout of \(t)"
        }
    }
}
