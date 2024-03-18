//
//  LicenseNetworkError.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/06/22.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

enum LicenseNetworkError: Error {
    
    case NetworkError(error: NetworkError)
    
    case CouldNotFindLicense
    case Error(message: String, details: String?)
    
    var stringValue: String {
        switch self {
            case .NetworkError(let error): return "NetworkError: \(error)"
                
            case .CouldNotFindLicense: return "Could not find the license on the server"
            case .Error(let message, let details): return "Error Message: \(message)\((details != nil) ? ", Error Details: \(details!)" : "")"
        }
    }
    
}
