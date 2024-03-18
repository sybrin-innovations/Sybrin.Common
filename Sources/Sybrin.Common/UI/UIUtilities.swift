//
//  UIUtilities.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/25.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit
import AVFoundation

public struct UIUtilities {
    
    // MARK: Public Methods
    public static func fixOrientation(_ image: UIImage, to orientation: UIImage.Orientation? = nil) -> UIImage {
        guard let cgImage = image.cgImage else {
            "CGImage was nil".log(.Error)
            return image
        }
        
        let orientation: UIImage.Orientation = (orientation != nil ? orientation! : (CameraHandler.LastInstance?.cameraPosition == .front ? .right : .left))
        
        //return UIImage(cgImage: cgImage, scale: self.scale, orientation: UIUtilities.imageOrientation())
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: orientation)
    }
    
    public static func rotateImagePortrait(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return image
        }
        
        guard let cgImage = image.cgImage else {
            //CGImage is not available
            return image
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        let size = image.size
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        @unknown default:
            "Unknown Image orientation".log(.Error)
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            "Unknown Image orientation".log(.Error)
        }
        
        ctx.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return image }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
    public static func imageOrientation(fromDeviceOrientation deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation, fromCameraPosition cameraPosition: AVCaptureDevice.Position = .back) -> UIImage.Orientation {
        switch deviceOrientation {
            case .portrait: return cameraPosition == .front ? .leftMirrored : .left
            case .landscapeLeft: return cameraPosition == .front ? .downMirrored : .down
            case .portraitUpsideDown: return cameraPosition == .front ? .rightMirrored : .right
            case .landscapeRight: return cameraPosition == .front ? .upMirrored : .up
            case .faceDown, .faceUp, .unknown: return .up
            @unknown default: "Unknown Device orientation, returning .left".log(.Error)
                return cameraPosition == .front ? .leftMirrored : .left
        }
    }
    
    public static func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer, fixOrientation: Bool = false) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, .readOnly)

        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)

        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)

        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Create a bitmap graphics context with the sample buffer data
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage()
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)

        // Create an image object from the Quartz image
        var image = UIImage.init(cgImage: quartzImage!)
        
        if fixOrientation {
            image = image.fixOrientation().rotateImagePortrait()
        }

        return (image)
    }
    
}
