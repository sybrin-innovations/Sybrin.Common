//
//  LicenseErrorResponseModel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/06/14.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

struct LicenseErrorResponseModel: Codable, Error {
    
    // MARK: Internal Properties
    var ErrorMessage: String
    var ErrorDetails: String?
    
}
