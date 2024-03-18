//
//  NSRegularExpression.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    
    public convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    public func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)

        return firstMatch(in: string, options: [], range: range) != nil
    }
    
}
