//
//  UIViewController.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/04/09.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func showToast(message: String, with options: ToastOptions = ToastOptions()) {
        ToastHandler.show(message: message, view: self.view, with: options)
    }
    
}
