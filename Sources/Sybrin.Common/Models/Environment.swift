//
//  Environment.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/06/11.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import Foundation

public struct Environment: Codable {
    
    // MARK: Public Properties
    public var licenseLegacyURL: String?
    public var licenseAuthorizeUsername: String?
    public var licenseAuthorizeAPIKey: String?
    public var licenseAuthorizeURL: String?
    public var licenseValidateURL: String?
    public var licenseUpdateCountURL: String?
    
    // MARK: Initializers
    public init() { }
    
}
