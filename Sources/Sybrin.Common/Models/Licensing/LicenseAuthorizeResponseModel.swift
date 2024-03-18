//
//  LicenseAuthorizeResponseModel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/06/14.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

struct LicenseAuthorizeResponseModel: Codable {
    
    // MARK: Internal Properties
    var HasError: Bool
    var Message: String?
    var AuthToken: String?
    
}
