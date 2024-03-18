//
//  LogLevel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

@objc public enum LogLevel: Int {
    case Verbose = 80
    case Debug = 70
    case ProtectedWarning = 60
    case ProtectedError = 50
    case Information = 40
    case Warning = 30
    case Error = 20
    case Critical = 10
    case None = 0
    
    var stringValue: String {
        switch self {
            case .Verbose: return "Verbose"
            case .Debug: return "Debug"
            case .ProtectedWarning: return "Protected Warning"
            case .ProtectedError: return "Protected Error"
            case .Information: return "Information"
            case .Warning: return "Warning"
            case .Error: return "Error"
            case .Critical: return "Critical"
            case .None: return "None"
        }
    }
    
    var annotatedStringValue: String {
        switch self {
            case .Verbose: return "[🔬] \(self.stringValue)"
            case .Debug: return "[💬] \(self.stringValue)"
            case .ProtectedWarning: return "[⚠️] \(self.stringValue)"
            case .ProtectedError: return "[‼️] \(self.stringValue)"
            case .Information: return "[ℹ️] \(self.stringValue)"
            case .Warning: return "[⚠️] \(self.stringValue)"
            case .Error: return "[‼️] \(self.stringValue)"
            case .Critical: return "[🔥] \(self.stringValue)"
            case .None: return "\(self.stringValue)"
        }
    }
    
    public var description: String {
        switch self {
            case .Verbose: return "Additional information that is useful to the framework developer"
            case .Debug: return "Any information that is useful to the framework developer"
            case .ProtectedWarning: return "Same as warning but restricted to the developer consuming the framework"
            case .ProtectedError: return "Same as error but restricted to the developer consuming the framework"
            case .Information: return "Any information that is useful to the developer consuming the framework"
            case .Warning: return "Any instruction that encountered unexpected circumstances, but was able to successfully recover and complete the instruction"
            case .Error: return "Any instruction that encountered unexpected circumstances, and was unable to successfully complete the instruction, but the application is able to continue normal execution"
            case .Critical: return "Any instruction that encountered unexpected circumstances, and was unable to successfully complete the instruction, and the application is unable to continue normal execution"
            case .None: return "No instructions will be logged"
        }
    }
    
}
