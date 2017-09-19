//
//  Result.swift
//
//  Adapted from https://github.com/rfdickerson/HeliumFutures
//  Modified by Aaron Liberatore on 9/14/17.
//

public enum Result<T> {
    case error(AkkaError)
    case success(T)
}
