//
//  ToastOptions.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/09.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import Foundation
import UIKit

public struct ToastOptions {
    
    // MARK: Public Properties
    public var duration: TimeInterval = 3
    public var animation: TimeInterval = 0.5
    public var cornerRadius: CGFloat = 25
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4)
    public var textColor: UIColor = UIColor.white
    
    // MARK: Initializers
    public init() { }
    
}
