//
//  LicenseValidateResponseModel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/06/14.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

struct LicenseValidateResponseModel: Codable {
    
    // MARK: Internal Properties
    var Valid: Bool
    var Message: String
    var TransactionCount: Int
    
}
