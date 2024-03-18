//
//  ToastHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/20.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit

public final class ToastHandler {
    
    // MARK: Private Methods
    private static func ShowToast(message: String, on view: UIView, with options: ToastOptions) {
        
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = options.backgroundColor
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = options.cornerRadius;
        toastContainer.clipsToBounds = true
        toastContainer.tag = CommonUITags.TOAST_MESSAGE_TAG.rawValue
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = options.textColor
        toastLabel.textAlignment = .center
        toastLabel.font.withSize(12)
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let toastLabelLeadingConstraint = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let toastLabelTrailingConstraint = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let toastLabelBottomConstraint = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let toastLabelTopConstraint = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([toastLabelLeadingConstraint, toastLabelTrailingConstraint, toastLabelBottomConstraint, toastLabelTopConstraint])
        
        let toastContainerLeadingConstraint = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 65)
        let toastContainerTrailingConstraint = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -65)
        let toastContainerBottomConstraint = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -75)
        view.addConstraints([toastContainerLeadingConstraint, toastContainerTrailingConstraint, toastContainerBottomConstraint])
        
        UIView.animate(withDuration: options.animation, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: options.animation, delay: options.duration, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
        
    }
    
    // MARK: Public Methods
    public static func show(message: String, view: UIView, with options: ToastOptions = ToastOptions()) {
        
        DispatchQueue.main.async {
            // Removing the toast container
            if let viewToRemove = view.viewWithTag(CommonUITags.TOAST_MESSAGE_TAG.rawValue) {
                viewToRemove.removeFromSuperview()
            }
            
            ShowToast(message: message, on: view, with: options)
        }
        
    }
    
}
