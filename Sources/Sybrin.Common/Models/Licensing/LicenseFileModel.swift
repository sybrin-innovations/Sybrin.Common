//
//  LicenseFileModel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/17.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

struct LicenseFileModel: Codable {
    
    // MARK: Internal Properties
    var Valid: Bool
    var Message: String
    
    // MARK: Initializers
    init() {
        
        Valid = false
        Message = "Initialized"
        
    }
    
}
