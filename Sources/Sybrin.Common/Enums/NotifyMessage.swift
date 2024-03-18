//
//  NotifyMessage.swift
//  Sybrin.iOS.Common
//
//  Created by Rhulani Ndhlovu on 2022/09/22.
//  Copyright © 2022 Sybrin Systems. All rights reserved.
//

import Foundation

enum NotifyMessage {
    
    case verifying
    var stringValue: String {
        
        switch self {
        case .verifying: return ""
        }
        
    }
}
