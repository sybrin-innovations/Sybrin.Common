//
//  GestureHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/20.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit

public final class GestureHandler {
    
    // MARK: Public Properties
    public static weak var delegate: SwipeGestureDelegate?
    
    // MARK: Public Methods
    public static func addSwipeGesture(on view: UIView, for direction: UISwipeGestureRecognizer.Direction) {
        "Adding swipe gesture".log(.Debug)
        "Direction: \(direction.rawValue)".log(.Verbose)
        guard view.gestureRecognizers?.first(where: { (gestureInView) -> Bool in gestureInView.name == "SybrinGesture_\(direction.rawValue)" }) == nil else {
            "Gesture already exists".log(.Error)
            return
        }
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipes(_:)))
        gesture.name = "SybrinGesture_\(direction.rawValue)"
        gesture.direction = direction
        view.addGestureRecognizer(gesture)
        "Swipe gesture added".log(.Information)
    }
    
    public static func removeSwipeGesture(from view: UIView, for direction: UISwipeGestureRecognizer.Direction) {
        "Removing swipe gesture".log(.Debug)
        "Direction: \(direction.rawValue)".log(.Verbose)
        guard let gesture = view.gestureRecognizers?.first(where: { (gestureInView) -> Bool in gestureInView.name == "SybrinGesture_\(direction.rawValue)" }) else {
            "Could not find gesture".log(.Error)
            return
        }
        
        view.removeGestureRecognizer(gesture)
        "Swipe gesture removed".log(.Information)
    }
    
    // MARK: Private Methods
    @objc private static func HandleSwipes(_ sender: UISwipeGestureRecognizer) {
        switch (sender.direction) {
            case .up: delegate?.handleSwipeUp()
            case .down: delegate?.handleSwipeDown()
            case .left: delegate?.handleSwipeLeft()
            case .right: delegate?.handleSwipeRight()
            default: "Undetermined swipe gesture direction".log(.Warning)
        }
    }
    
}
