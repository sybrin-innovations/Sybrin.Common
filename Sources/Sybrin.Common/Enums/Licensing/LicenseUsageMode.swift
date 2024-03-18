//
//  LicenseUsageMode.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/12.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

enum LicenseUsageMode: Int, Encodable {
    case Client = 0
    case Sybrin = 1
    
    var stringValue: String {
        switch self {
            case .Client: return "Client"
            case .Sybrin: return "Sybrin"
        }
    }
    
}
