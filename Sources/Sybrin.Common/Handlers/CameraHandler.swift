//
//  CameraHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit
import AVFoundation

public final class CameraHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    // MARK: Private Properties
    private final var Session: AVCaptureSession = AVCaptureSession()
    private final var PreviewView: UIView?
    private final lazy var VideoDataOutput = AVCaptureVideoDataOutput()
    private final lazy var StillImageOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private final var PreviewLayer: AVCaptureVideoPreviewLayer?
    private final var OutputType: CameraOutputType = .Unspecified
    private final var CameraPosition: AVCaptureDevice.Position = .back
    private final var CameraOptionsObj: CameraOptions = CameraOptions()
    
    // MARK: Internal Properties
    static weak var LastInstance: CameraHandler?
    
    // MARK: Public Properties
    public final weak var delegate: CameraDelegate?
    public final var cameraPosition: AVCaptureDevice.Position { get { return self.CameraPosition } set { self.CameraPosition = newValue } }
    public final var outputType: CameraOutputType { get { return self.OutputType } set { self.OutputType = newValue } }
    public final var isCameraBusy: Bool { get {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera , for: .video, position: self.cameraPosition) else {
            "Failed to get the camera capture device".log(.Critical)
            return false
        }
        return camera.isAdjustingFocus || camera.isAdjustingExposure || camera.isAdjustingWhiteBalance || camera.isRampingVideoZoom
    } }
    
    public final var capturedImage: UIImage?
    public final var captureBuffer: CVPixelBuffer?
    
    // MARK: Initializers
    public init?(_ view: UIView, cameraPosition: AVCaptureDevice.Position = .back, cameraOptions: CameraOptions = CameraOptions()) {
        super.init()
        
        PreviewView = view
        CameraPosition = cameraPosition
        CameraOptionsObj = cameraOptions
        
        if let maximumFramesPerSecond = CameraOptionsObj.maximumFramesPerSecond {
            guard CameraOptionsObj.minimumFramesPerSecond <= maximumFramesPerSecond else {
                "Minimum frames per second cannot be higher than maximum".log(.ProtectedError)
                return
            }
        }
        
        if let maximumResolution = CameraOptionsObj.maximumResolution {
            guard CameraOptionsObj.minimumResolution.width <= maximumResolution.width else {
                "Minimum resolution width cannot be higher than maximum".log(.ProtectedError)
                return
            }

            guard CameraOptionsObj.minimumResolution.height <= maximumResolution.height else {
                "Minimum resolution height cannot be higher than maximum".log(.ProtectedError)
                return
            }
        }
        
        "Initializing camera".log(.Debug)
        InitializeCamera()
        
        PreviewLayer?.connection?.videoOrientation = .portrait
        PreviewLayer?.videoGravity = .resizeAspectFill

        CameraHandler.LastInstance = self
    }
    
    override private init() {
        super.init()
    }
    
    deinit {
        if Session.isRunning {
            "Stopping Session".log(.Information)
            Session.stopRunning()
        }
        
        if CameraHandler.LastInstance == self {
            CameraHandler.LastInstance = nil
        }
    }
    
    // MARK: Public Methods
    public final func cameraTakePicture(_ flashMode: AVCaptureDevice.FlashMode = .auto) {
        
        var finalFlashMode: AVCaptureDevice.FlashMode = flashMode
        
        if let device = AVCaptureDevice.default(for: .video) {
            if !device.hasFlash || device.position == .front || device.position == .unspecified {
                finalFlashMode = .off
            }
        }
        
        let settings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        
        settings.flashMode = finalFlashMode
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = false
        
        self.StillImageOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
    
    public final func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        switch outputType {
            case .UIImage:
            CommonConstants.capturedImage = UIImage.imageFromSampleBuffer(sampleBuffer)
            capturedImage = UIImage.imageFromSampleBuffer(sampleBuffer)
                delegate?.processFrameUIImage(UIImage.imageFromSampleBuffer(sampleBuffer))
            
            let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
            guard let imagePixelBuffer = pixelBuffer else { return }
            CommonConstants.captureBuffer = imagePixelBuffer
            captureBuffer = imagePixelBuffer
            case .CVPixelBuffer:
                let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
                guard let imagePixelBuffer = pixelBuffer else { return }
            CommonConstants.captureBuffer = imagePixelBuffer
            captureBuffer = imagePixelBuffer
                delegate?.processFrameCVPixelBuffer(imagePixelBuffer)
            case .CMSampleBuffer:
                delegate?.processFrameCMSampleBuffer(sampleBuffer)
            case .Unspecified:
                delegate?.processFrameCMSampleBuffer(sampleBuffer)
                
                let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
                guard let imagePixelBuffer = pixelBuffer else { return }
                
                delegate?.processFrameCVPixelBuffer(imagePixelBuffer)
                
                delegate?.processFrameUIImage(UIImage.imageFromSampleBuffer(sampleBuffer))
        }
        
    }
    
    public final func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if (photo.fileDataRepresentation() != nil) {
            let dataProvider = CGDataProvider(data: photo.fileDataRepresentation()! as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            
            delegate?.capturePhoto(camera: self, image: image)
            CommonConstants.capturedImage = image
            capturedImage = image
        } else {
            "Photo fileDataRepresentation is nil".log(.ProtectedError)
        }
        
    }
    
    public static func toggleFlashLight() -> Bool {
        
        "Toggling torch".log(.Debug)
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            if (device.hasTorch && device.isTorchAvailable && device.position == .back && CameraHandler.LastInstance?.CameraPosition == .back) {
                do {
                    try device.lockForConfiguration()
                    if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                    } else {
                        do {
                            try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                            return true
                        } catch {
                            "Failed to turn torch on max".log(.Error)
                            "Error: \(error.localizedDescription)".log(.Verbose)
                        }
                    }
                    device.unlockForConfiguration()
                } catch {
                    "Failed to lock configuration for the torch".log(.ProtectedError)
                    "Error: \(error.localizedDescription)".log(.Verbose)
                }
            }
        }
        
        return false
        
    }

    // MARK: Private Methods
    private final func GetBestFormat(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, frameRate: Float64)? {
        var bestFormat: AVCaptureDevice.Format?
        var bestFrameRate: AVFrameRateRange?
        
        searchFormat: for format in device.formats {
            "Found format: \(format)".log(.Verbose)
            searchRange: for range in format.videoSupportedFrameRateRanges {
                // 875704422 = 420f
                // 875704438 = 420v
                guard CMFormatDescriptionGetMediaSubType(format.formatDescription) == 875704422 else { continue }
                
                let currentResolution = CGSize(width: Int(CMVideoFormatDescriptionGetDimensions(format.formatDescription).width), height: Int(CMVideoFormatDescriptionGetDimensions(format.formatDescription).height))
                
                // Apect Ratio
                var aspectRatioMatchFound = false
                var aspectRatioMatchAllowed = false
                
                if currentResolution.width / currentResolution.height == 16/9 {
                    aspectRatioMatchFound = true
                    aspectRatioMatchAllowed = CameraOptionsObj.include16by9AspectRatios
                }
                
                if currentResolution.width / currentResolution.height == 4/3 {
                    aspectRatioMatchFound = true
                    aspectRatioMatchAllowed = CameraOptionsObj.include4by3AspectRatios
                }
                
                if !aspectRatioMatchFound && CameraOptionsObj.includeOtherAspectRatios {
                    aspectRatioMatchFound = true
                    aspectRatioMatchAllowed = true
                }
                
                guard aspectRatioMatchAllowed else { continue }
                
                // Inverting resolution width & height because video frames are landscape left; not portrait
                // Resolution checks
                // Minimum
                guard currentResolution.width >= CameraOptionsObj.minimumResolution.height && currentResolution.height >= CameraOptionsObj.minimumResolution.width else { continue }
                
                // Maximum
                if let maximumResolution = CameraOptionsObj.maximumResolution {
                    guard currentResolution.width <= maximumResolution.height && currentResolution.height <= maximumResolution.width else { continue searchRange }
                }
                
                // Best
                if let bestFormat = bestFormat {
                    let bestResolution = CGSize(width: Int(CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription).width), height: Int(CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription).height))

                    guard currentResolution.width >= bestResolution.width && currentResolution.height >= bestResolution.height else { continue }
                }
                
                // Frames Per Second checks
                // Minimum
                if let maximumFramesPerSecond = CameraOptionsObj.maximumFramesPerSecond {
                    guard range.minFrameRate <= maximumFramesPerSecond else { continue searchRange }
                }
                
                
                // Maximum
                guard range.maxFrameRate >= CameraOptionsObj.minimumFramesPerSecond else { continue }
                
                // Best
                if let bestFrameRate = bestFrameRate, CameraOptionsObj.preference == .FPS {
                    if let maximumFramesPerSecond = CameraOptionsObj.maximumFramesPerSecond {
                        guard range.maxFrameRate >= bestFrameRate.maxFrameRate || range.maxFrameRate >= maximumFramesPerSecond else { continue }
                    } else {
                        guard range.maxFrameRate >= bestFrameRate.maxFrameRate else { continue }
                    }
                }
                
                //Check if needs are already met
                if let bestFormat = bestFormat, let bestFrameRate = bestFrameRate {
                    let bestResolution = CGSize(width: Int(CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription).width), height: Int(CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription).height))
                    
                    if let maximumResolution = CameraOptionsObj.maximumResolution, let maximumFramesPerSecond = CameraOptionsObj.maximumFramesPerSecond {
                        guard bestResolution.height < maximumResolution.width || bestResolution.width < maximumResolution.height || bestFrameRate.maxFrameRate < maximumFramesPerSecond else { break searchFormat }
                    } else if let maximumResolution = CameraOptionsObj.maximumResolution {
                        guard bestResolution.height < maximumResolution.width || bestResolution.width < maximumResolution.height else { break searchFormat }
                    }
                    
                }
                
                "This format is ideal for now: \(CMVideoFormatDescriptionGetDimensions(format.formatDescription).width)x\(CMVideoFormatDescriptionGetDimensions(format.formatDescription).height)@\(range.maxFrameRate)fps".log(.Verbose)
                bestFormat = format
                bestFrameRate = range
            }
        }
        
        if let bestFormat = bestFormat, let bestFrameRate = bestFrameRate {
            "Best format is: \(CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription).width)x\(CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription).height)@\(bestFrameRate.maxFrameRate)fps".log(.Debug)
            return (bestFormat, (CameraOptionsObj.maximumFramesPerSecond != nil && bestFrameRate.maxFrameRate > CameraOptionsObj.maximumFramesPerSecond!) ? CameraOptionsObj.maximumFramesPerSecond! : bestFrameRate.maxFrameRate)
        } else {
            "Failed to find best format within the given parameters".log(.ProtectedWarning)
            return nil
        }
    }
    
    private final func InitializeCamera() {
        
        "Starting session configuration".log(.Debug)
        Session.beginConfiguration()
        
        guard InitInputDevice() == true else {
            "Failed to add the camera input device".log(.Critical)
            return
        }
        
        guard AddVideoDataOutput() == true else {
            "Failed to add the video output".log(.Critical)
            return
        }
        
        guard AddStillPhotoOutput() == true else {
            "Failed to add the photo output".log(.Critical)
            return
        }
        
        "Committing session configuration".log(.Debug)
        Session.commitConfiguration()

        // Placed this call on the main thread to speed up start up speed.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            "Running session".log(.Information)
            self.Session.startRunning()
        }
        
        "Setting up the camera preview".log(.Debug)
        PreviewLayer = AVCaptureVideoPreviewLayer(session: Session)
        if let previewLayer = PreviewLayer, let view = PreviewView {
            view.layer.addSublayer(previewLayer)
            
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            StillImageOutput.connection(with: AVMediaType.video)
        } else {
            "Failed to set the preview layer".log(.Critical)
        }
        
    }
    
    private final func InitInputDevice() -> Bool {
        
        "Getting camera capture device".log(.Debug)
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera , for: .video, position: self.cameraPosition) else {
            "Failed to get the camera capture device".log(.Critical)
            return false
        }
        
        do {
            "Adding the camera capture device input".log(.Debug)
            let input = try AVCaptureDeviceInput(device: camera)
            if Session.canAddInput(input) {
                Session.addInput(input)
                
                if let bestFormat = GetBestFormat(for: camera) {
                    
                    "Getting the best format".log(.Debug)
                    try camera.lockForConfiguration()
                    camera.activeFormat = bestFormat.format
                    camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(bestFormat.frameRate))
                    camera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(bestFormat.frameRate))
                    camera.unlockForConfiguration()
                    "Done setting the best format".log(.Debug)
                    
                }
                
                return true
            }
        } catch {
            "Failed to add the camera capture device input".log(.Critical)
            "Error: \(error.localizedDescription)".log(.Verbose)
            return false
        }
        
        return false
        
    }
    
    private final func AddStillPhotoOutput() -> Bool {
        
        if Session.canAddOutput(StillImageOutput) {
            "Adding the capture photo output".log(.Debug)
            Session.addOutput(StillImageOutput)
            return true
        }
        
        return false
        
    }
    
    private final func AddVideoDataOutput() -> Bool {
        
        let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
        VideoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        VideoDataOutput.alwaysDiscardsLateVideoFrames = true
        VideoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCVPixelFormatType_32BGRA ] //kCMPixelFormat_32BGRA
        
        if Session.canAddOutput(VideoDataOutput) {
            "Adding the capture video data output".log(.Debug)
            Session.addOutput(VideoDataOutput)
        } else {
            "Failed to add the capture video data output".log(.Critical)
            return false
        }
        
        for connection in VideoDataOutput.connections {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .landscapeLeft
            }
        }
        
        return true
        
    }
    
}
