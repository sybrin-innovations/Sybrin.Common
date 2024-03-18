//
//  Date.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

extension Date {
    
    public func dateToString(withFormat format: String = "yyyy-MM-dd", timezone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        if let timezone = timezone {
            formatter.timeZone = timezone
        }
        
        return formatter.string(from: self)
    }
    
}
