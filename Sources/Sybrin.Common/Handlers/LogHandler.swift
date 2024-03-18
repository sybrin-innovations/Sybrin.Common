//
//  LogHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/18.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

public struct LogHandler {
    
    // MARK: Private Properties
    private static var GlobalLogLevel: LogLevel = .Error
    private static var LogDebugInformation: Bool = false
    
    // MARK: Public Properties
    public static var globalLogLevel: LogLevel {
        get { return GlobalLogLevel }
        set {
            if !requiresDevAccess(for: newValue) || (requiresDevAccess(for: newValue) && DeveloperSettings.developerAccessGranted) {
                GlobalLogLevel = newValue
            } else if requiresDevAccess(for: newValue) && !DeveloperSettings.developerAccessGranted {
                "Developer access is required to set that log level".log(.Error)
            }
        }
    }
    public static var logDebugInformation: Bool {
        get { return LogDebugInformation }
        set {
            if DeveloperSettings.developerAccessGranted {
                LogDebugInformation = newValue
            }
            else if newValue {
                "Developer access is required to enable debug information".log(.Error)
            }
        }
    }
    
    // MARK: Public Methods
    public static func requiresDevAccess(for logLevel: LogLevel) -> Bool {
        
        switch logLevel {
            case .Verbose: return true
            case .Debug: return true
            case .ProtectedWarning: return true
            case .ProtectedError: return true
            case .Information: return false
            case .Warning: return false
            case .Error: return false
            case .Critical: return false
            case .None: return false
        }
        
    }
    
    public static func log(_ value: String, _ level: LogLevel, fromClass className: String = #file, inFunction functionName: String = #function, onLine lineNumber: Int = #line) {
        
        guard level != .None else { return }
        guard globalLogLevel != .None else { return }
        
        if level.rawValue <= globalLogLevel.rawValue {
            NSLog(GetLogMessageFor(value, level: level, className: className, functionName: functionName, lineNumber: lineNumber))
        } else if level == .ProtectedError {
            NSLog(GetLogMessageFor("An internal error occurred, Sybrin code: \(HideValue(for: GetClassName(from: className)))x\(lineNumber)", level: .Error, className: "", functionName: "", lineNumber: 0))
        }
        
    }
    
    public static func logTest() {
        
        "Verbose Test".log(.Verbose)
        "Debug Test".log(.Debug)
        "Protected Error Test".log(.ProtectedError)
        "Information Test".log(.Information)
        "Warning Test".log(.Warning)
        "Error Test".log(.Error)
        "Critical Test".log(.Critical)
        
    }
    
    // MARK: Private Methods
    private static func GetLogMessageFor(_ value: String, level: LogLevel, className: String, functionName: String, lineNumber: Int) -> String {
        var messageToLog: String = value
        
        if (lineNumber > 0 && logDebugInformation) {
            messageToLog = "line \(lineNumber) | \(messageToLog)"
        }
        
        if (functionName.count > 0 && logDebugInformation) {
            messageToLog = "\(functionName) | \(messageToLog)"
        }
        
        if (className.count > 0 && logDebugInformation) {
            messageToLog = "\(GetClassName(from: className)) | \(messageToLog)"
        }
        
        return "\(level.annotatedStringValue.uppercased()) | \(messageToLog)"
    }
    
    private static func GetClassName(from filePath: String) -> String {
        let filePathParts = filePath.split(separator: "/")
        
        if filePathParts.count > 0 {
            let classNameParts = filePathParts.last!.split(separator: ".")
            
            if classNameParts.count > 0 {
                return String(classNameParts.first!)
            } else {
                return String(filePathParts.last!)
            }
        } else {
            return filePath
        }
        
    }
    
    private static func HideValue(for value: String) -> String {
        var newValue: String = ""
        var runningValue: Int = 0
        
        for char in value {
            if char.isUppercase {
                if runningValue > 0 {
                    newValue.append("\(runningValue)")
                    runningValue = 0
                }
                newValue.append(char)
            } else {
                if let asciiValue = char.asciiValue {
                    runningValue += Int(asciiValue)
                }
            }
        }
        if runningValue > 0 {
            newValue.append("\(runningValue)")
            runningValue = 0
        }
        
        return newValue
    }
    
}
