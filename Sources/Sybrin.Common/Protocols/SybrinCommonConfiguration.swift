//
//  SybrinCommonConfiguration.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/12/09.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import AVFoundation
import UIKit

public protocol SybrinCommonConfiguration: AnyObject {
    
    // MARK: Public Properties
    var overlayColor: UIColor {get set}
    var overlayLabelTextColor: UIColor {get set}
    var overlaySubLabelTextColor: UIColor {get set}
    
    var overlayBorderColor: UIColor {get set}
    var overlayBorderThickness: CGFloat {get set}
    var overlayBorderLength: CGFloat {get set}
    
    var overlayBlurStyle: UIBlurEffect.Style {get set}
    var overlayBlurIntensity: CGFloat {get set}
    
    var cameraPosition: AVCaptureDevice.Position {get set}
    
    var environmentKey: String {get set}
}
