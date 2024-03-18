//
//  CameraOptions.swift
//  Sybrin.iOS.Common
//
//  Created by Default on 2021/04/15.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import AVFoundation

public struct CameraOptions {
    
    // MARK: Public Properties
    public enum Preference { case Resolution, FPS }
    
    public var minimumResolution: CGSize = CGSize(width: 720, height: 1280)
    public var maximumResolution: CGSize? = CGSize(width: 1080, height: 1920)
    public var minimumFramesPerSecond: Float64 = 30
    public var maximumFramesPerSecond: Float64? = 60
    public var include16by9AspectRatios: Bool = true
    public var include4by3AspectRatios: Bool = true
    public var includeOtherAspectRatios: Bool = true
    public var preference: Preference = .FPS
    
    // MARK: Initializers
    public init() { }
    
}
