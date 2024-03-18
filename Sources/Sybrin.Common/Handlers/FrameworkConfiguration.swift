//
//  FrameworkConfiguration.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/18.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

public struct FrameworkConfiguration {
    
    // MARK: Internal Properties
    static var Configuration: SybrinCommonConfiguration?
    static var EnvironmentObj: Environment?
    
    // MARK: Public Properties
    public static var configuration: SybrinCommonConfiguration? {
        get { return Configuration }
        set {
            guard DeveloperSettings.developerAccessGranted else {
                "Developer access is required to set configuration".log(.Error)
                return
            }
            "Configuration set".log(.Information)
            Configuration = newValue
            EnvironmentObj = DecryptEnvironment(key: newValue?.environmentKey ?? "")
        }
    }
    
    // MARK: Private Methods
    private static func DecryptEnvironment(key: String) -> Environment? {
        
        "Decrypting Environment key".log(.Debug)
        let aes = AES(appID: "Environment")
        let jsonString = aes.Decrypt(message: key)
        
        guard jsonString != nil, let jsonData = jsonString?.data(using: .utf8) else {
            "Invalid Environment key".log(.Error)
            return nil
        }

        "Environment key decrypted".log(.Debug)

        do {
            return try JSONDecoder().decode(Environment.self, from: jsonData)
        } catch {
            "Failed to decode JSON to environment model".log(.ProtectedError)
            "Error: \(error.localizedDescription)".log(.Verbose)
            return nil
        }
        
    }
    
}
