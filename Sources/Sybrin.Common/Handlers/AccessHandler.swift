//
//  AccessHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit
import Photos

public struct AccessHandler {
    
    // MARK: Public Methods
    public static func checkPhotoLibraryAccess(_ permissionGranted: (Bool) -> Void) {
        "Checking photo library access".log(.Debug)
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        
        "Photo library access: \(currentStatus.rawValue)".log(.Verbose)
        if currentStatus != .authorized {
            "Photo library access is not authorized, requesting permission".log(.Warning)
            let semaphore = DispatchSemaphore(value: 0)
            var returnResult: Bool!
            
            DispatchQueue.global(qos: .userInteractive).async {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status != .authorized {
                        "Photo library permissions denied".log(.Error)
                    }
                    returnResult = (status == .authorized)
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            "Response: \(returnResult!)".log(.Verbose)
            permissionGranted(returnResult)
        } else {
            "Photo library access authorized".log(.Information)
            permissionGranted(true)
        }
        
    }
    
    public static func checkCameraAccess(_ permissionGranted: (Bool) -> Void) {
        "Checking camera access".log(.Debug)
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        "Camera access: \(currentStatus.rawValue)".log(.Verbose)
        if currentStatus != .authorized {
            "Camera access is not authorized, requesting permission".log(.Warning)
            let semaphore = DispatchSemaphore(value: 0)
            var returnResult: Bool!
            
            DispatchQueue.global(qos: .userInteractive).async {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if !granted {
                        "Camera permissions denied".log(.Error)
                    }
                    returnResult = granted
                    semaphore.signal()
                })
            }
            
            semaphore.wait()
            "Response: \(returnResult!)".log(.Verbose)
            permissionGranted(returnResult)
        } else {
            "Camera access authorized".log(.Information)
            permissionGranted(true)
        }
        
    }
    
    public static func showUIAlertForPhotoLibraryPermission(_ viewController: UIViewController, completion: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error",
                                                    message: "Photo library access is denied",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
                "User cancelled the photo library permission denied alert".log(.Debug)
                completion()
            })
            alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
                "Sending user to settings to fix permissions".log(.Debug)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:])
                    completion()
                }
            })
            
            "Presenting photo library permission denied alert".log(.Debug)
            viewController.present(alertController, animated: true)
        }
        
    }
    
    public static func showUIAlertForCameraPermission(_ viewController: UIViewController, completion: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error",
                                                    message: "Camera access is denied",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
                "User cancelled the camera permission denied alert".log(.Debug)
                completion()
            })
            alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
                "Sending user to settings to fix permissions".log(.Debug)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:])
                    completion()
                }
            })
            
            "Presenting camera permission denied alert".log(.Debug)
            viewController.present(alertController, animated: true)
        }
        
    }
    
}
