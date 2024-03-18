//
//  UIFont.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/10/23.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    static func RegisterFont(withFilenameString filenameString: String, bundle: Bundle) {

        guard let pathForResourceString = bundle.path(forResource: "\(filenameString).ttf", ofType: nil) else {
            "Failed to register font - path for resource not found.".log(.ProtectedError)
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            "Failed to register font - font data could not be loaded.".log(.ProtectedError)
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            "Failed to register font - data provider could not be loaded.".log(.ProtectedError)
            return
        }

        guard let font = CGFont(dataProvider) else {
            "Failed to register font - font could not be loaded.".log(.ProtectedError)
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            "Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.".log(.ProtectedError)
            "Error: \((errorRef!.takeUnretainedValue()).localizedDescription)".log(.Verbose)
        }
        
    }
    
}
