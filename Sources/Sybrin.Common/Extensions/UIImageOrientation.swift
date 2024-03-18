//
//  UIImageOrientation.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/09.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import UIKit

extension UIImage.Orientation {
    
    public var stringValue: String {
        switch self {
            case .up: return "up"
            case .down: return "down"
            case .left: return "left"
            case .right: return "right"
            case .upMirrored: return "upMirrored"
            case .downMirrored: return "downMirrored"
            case .leftMirrored: return "leftMirrored"
            case .rightMirrored: return "rightMirrored"
            @unknown default: return "default"
        }
    }
    
}
