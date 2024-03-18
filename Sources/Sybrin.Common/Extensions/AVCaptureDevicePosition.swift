//
//  AVCaptureDevicePosition.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/09.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice.Position {
    
    public var stringValue: String {
        switch self {
            case .unspecified: return "unspecified"
            case .back: return "back"
            case .front: return "front"
            @unknown default: return "default"
        }
    }
    
}
