//
//  CameraDelegate.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import AVFoundation
import UIKit

public protocol CameraDelegate: AnyObject {
    /// This process image is called when the camera feed handler has taken a photo (Called the 'photoOutput') function
    func capturePhoto(camera: CameraHandler, image: UIImage)
    
    /// This process image is called when the camera feed handler is outputting frames or images (Calling the 'captureOutput') function
    func processFrameUIImage(_ image: UIImage)
    func processFrameCVPixelBuffer(_ cvbuffer: CVPixelBuffer)
    func processFrameCMSampleBuffer(_ cmbuffer: CMSampleBuffer)
}

public extension CameraDelegate {
    func capturePhoto(camera: CameraHandler, image: UIImage) { }
    
    func processFrameUIImage(_ image: UIImage) { }
    func processFrameCVPixelBuffer(_ cvbuffer: CVPixelBuffer) { }
    func processFrameCMSampleBuffer(_ cmbuffer: CMSampleBuffer) { }
}
