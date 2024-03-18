//
//  AVCaptureVideoOrientation.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/09.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import AVFoundation

extension AVCaptureVideoOrientation {
    
    public var stringValue: String {
        switch self {
            case .portrait: return "portrait"
            case .portraitUpsideDown: return "portraitUpsideDown"
            case .landscapeRight: return "landscapeRight"
            case .landscapeLeft: return "landscapeLeft"
            @unknown default: return "default"
        }
    }
    
}
