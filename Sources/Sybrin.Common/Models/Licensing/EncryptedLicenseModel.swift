//
//  EncryptedLicenseModel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/17.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

struct EncryptedLicenseModel: Codable {
    
    // MARK: Private Properties
    private enum CodingKeys: String, CodingKey { case AppID = "AppID", OrganisationID = "OrganisationID", StartDate = "StartDate", ExpiryDate = "ExpiryDate", MaxUsageLimit = "MaxUsageLimit", UsageMode = "UsageMode", SDKType = "SDKType", LicenseURL = "LicenseURL" }
    
    // MARK: Internal Properties
    var AppID: String
    var OrganisationID: String
    var StartDate: Date
    var ExpiryDate: Date
    var SDKType: LicenseSDKType
    var MaxUsageLimit: Int
    var UsageMode: LicenseUsageMode
    var LicenseURL: String?
    
    // MARK: Initializers
    init(from decoder: Decoder) throws {
        
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.AppID = (try? keyedContainer.decode(String.self, forKey: CodingKeys.AppID)) ?? ""
        self.OrganisationID = (try? keyedContainer.decode(String.self, forKey: CodingKeys.OrganisationID)) ?? ""
        self.StartDate = (try? keyedContainer.decode(String.self, forKey: CodingKeys.StartDate).stringToDate(withFormat: "yyyy-MM-dd'T'HH:mm:ss")) ?? Date()
        self.ExpiryDate = (try? keyedContainer.decode(String.self, forKey: CodingKeys.ExpiryDate).stringToDate(withFormat: "yyyy-MM-dd'T'HH:mm:ss")) ?? Date()
        self.MaxUsageLimit = (try? keyedContainer.decode(Int.self, forKey: CodingKeys.MaxUsageLimit)) ?? 0
        self.UsageMode = (try? LicenseUsageMode(rawValue: keyedContainer.decode(Int.self, forKey: CodingKeys.UsageMode))) ?? LicenseUsageMode.Client
        self.SDKType = (try? LicenseSDKType(rawValue: Int(keyedContainer.decode(String.self, forKey: CodingKeys.SDKType)) ?? 0)) ?? LicenseSDKType.Identity
        self.LicenseURL = (try? keyedContainer.decode(String.self, forKey: CodingKeys.LicenseURL))
        
    }
    
}
