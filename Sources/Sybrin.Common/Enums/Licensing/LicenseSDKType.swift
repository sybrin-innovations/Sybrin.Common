//
//  LicenseSDKType.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/12.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

public enum LicenseSDKType: Int, Encodable {
    case Identity = 0
    case Biometrics = 1
    case WebAPI = 2
}
