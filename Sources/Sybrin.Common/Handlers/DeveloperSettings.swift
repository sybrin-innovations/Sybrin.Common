//
//  DeveloperSettings.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

public struct DeveloperSettings {
    
    // MARK: Private Properties
    private static let DeveloperToken: String = "zSssBA3k3B7o7aNUSYDnz9BTFmeuVTqVl5KXK6yIbBS3eD3zdyCMMgZ3ozaW4D06fMc4HjOpUew9IV96OxijqyslFtVJI2J7NInG3YySbb9Zao5U3BO597kFlXxMem8hW1CdNJ3tiOYI8E4eXkmhIjREnt1xWAJ7SO5aQwHRTRAV8MEqLjMPvk1J7Cc2wlTQPO78QUNE"
    private static var DeveloperAccessGranted: Bool = false {
        didSet {
            guard DeveloperAccessGranted != oldValue else { return }
            
            if DeveloperAccessGranted {
                "Developer access enabled".log(.Debug)
            } else {
                "Developer access disabled".log(.Debug)
            }
        }
    }
    
    // MARK: Public Properties
    public static var developerAccessGranted: Bool { get { return DeveloperAccessGranted } }

    // MARK: Public Methods
    public static func enableDeveloperAccess(token: String) {
        DeveloperAccessGranted = (token == DeveloperToken)
    }
    
    public static func disableDeveloperAccess() {
        DeveloperAccessGranted = false
    }
    
}
