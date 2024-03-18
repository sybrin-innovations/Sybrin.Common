//
//  SwipeGestureDelegate.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/20.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

public protocol SwipeGestureDelegate: AnyObject {
    func handleSwipeUp()
    func handleSwipeDown()
    func handleSwipeLeft()
    func handleSwipeRight()
}

public extension SwipeGestureDelegate {
    func handleSwipeUp() { }
    func handleSwipeDown() { }
    func handleSwipeLeft() { }
    func handleSwipeRight() { }
}
