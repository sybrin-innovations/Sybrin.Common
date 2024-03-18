//
//  Base64.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/15.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

public struct Base64 {
    
    // MARK: Public Methods
    public static func encodeBase64String(_ stringToEncode: String) -> Data? {
        guard let encodedString = stringToEncode.data(using: .utf8)?.base64EncodedData(options: .lineLength76Characters) else {
            return nil
        }
        
        return encodedString
    }
    
    public static func decodeBase64Data(_ data: Data) -> String? {
        if let stringData = Data(base64Encoded: data, options: [.ignoreUnknownCharacters]), let result = String(data: stringData, encoding: .utf8) {
            return result
        } else if let result = String(bytes: data, encoding: .utf8) {
            return result
        } else {
            return nil
        }
    }
    
}
