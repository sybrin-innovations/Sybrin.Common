//
//  UIImage.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    
    public func fixOrientation(to orientation: UIImage.Orientation? = nil) -> UIImage {
        return UIUtilities.fixOrientation(self, to: orientation)
    }
    
    public func rotateImagePortrait() -> UIImage {
        return UIUtilities.rotateImagePortrait(self)
    }
    
    public static func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer, fixOrientation: Bool = false) -> UIImage {
        return UIUtilities.imageFromSampleBuffer(sampleBuffer, fixOrientation: fixOrientation)
    }
    
}
