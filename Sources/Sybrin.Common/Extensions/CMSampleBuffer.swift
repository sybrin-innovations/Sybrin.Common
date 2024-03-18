//
//  CMSampleBuffer.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/01.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import AVFoundation
import UIKit

extension CMSampleBuffer {
    
    public var width: Int {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return 0 }
        
        return CVPixelBufferGetWidth(imageBuffer)
    }
    
    public var height: Int {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return 0 }
        
        return CVPixelBufferGetHeight(imageBuffer)
    }
    
    public var size: CGSize {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return CGSize() }
        
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        return CGSize(width: width, height: height)
    }
    
    public func toUIImage(fixOrientation: Bool = false) -> UIImage {
        return UIUtilities.imageFromSampleBuffer(self, fixOrientation: fixOrientation)
    }
    
}
