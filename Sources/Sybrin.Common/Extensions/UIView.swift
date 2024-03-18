//
//  UIView.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/09/03.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit

extension UIView {
    
    public func showToast(message: String, with options: ToastOptions = ToastOptions()) {
        ToastHandler.show(message: message, view: self, with: options)
    }
    
    public func subview(where searchPredicate: (_ : UIView) -> Bool) -> UIView? {
        
        if searchPredicate(self) {
            return self
        } else if self.subviews.count > 0 {
            var result: UIView? = nil
            
            for subView in self.subviews {
                if result == nil {
                    result = subView.subview(where: searchPredicate)
                }
            }
            
            return result
        } else {
            return nil
        }
        
    }
    
}
