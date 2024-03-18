//
//  LicenseError.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/10/12.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

public enum LicenseError: Error {
    case NotStarted
    case Expired
    case Suspended
    case IncorrectSDK
    case IncorrectPlatform
    case MaxUsageCountReached
    
    case NoInternet
    case FailedInternet(reason: String?)
    
    case NotInitialized
    case AlreadyInitialized
    case DecodingKeyFailed
    
    case InternalError
    case Undetermined
    
    public var message: String {
        switch self {
            case .NotStarted:
                return "The license key start date has not been exceeded yet"
            case .Expired:
                return "The license key has expired"
            case .Suspended:
                return "The license key has been suspended"
            case .IncorrectSDK:
                return "The license key is not meant for this SDK"
            case .IncorrectPlatform:
                return "The license key is not meant for this platform"
            case .MaxUsageCountReached:
                return "The license key has exceeded its maximum allowed transactions"
                
            case .NoInternet:
                return "An internet connection is unavailable and we were unable to validate the license key"
            case .FailedInternet(let reason):
                return "The request to Sybrin has failed and we were unable to validate the license key\((reason != nil) ? ". Reason: \(reason!)" : "")"
                
            case .NotInitialized:
                return "The license key has not been initialized yet"
            case .AlreadyInitialized:
                return "The license key is already initialized"
            case .DecodingKeyFailed:
                return "We were unable to decode the license key"
                
            case .InternalError:
                return "An internal error has occured while trying to validate the license key"
            case .Undetermined:
                return "We were unable to validate the license key"
        }
    }
}
