//
//  UIDeviceOrientation.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/09.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import UIKit

extension UIDeviceOrientation {
    
    public var stringValue: String {
        switch self {
            case .unknown: return "unknown"
            case .portrait: return "portrait"
            case .portraitUpsideDown: return "portraitUpsideDown"
            case .landscapeLeft: return "landscapeLeft"
            case .landscapeRight: return "landscapeRight"
            case .faceUp: return "faceUp"
            case .faceDown: return "faceDown"
            @unknown default: return "default"
        }
    }
    
}
