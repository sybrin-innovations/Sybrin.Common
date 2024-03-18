//
//  StringProtocol.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2021/05/03.
//  Copyright © 2021 Sybrin Systems. All rights reserved.
//

import UIKit

extension StringProtocol {
    
    public func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    public func substring(from: Int) -> String {
        let fromIndex = index(from: from)

        return String(self[fromIndex...])
    }

    public func substring(to: Int) -> String {
        let toIndex = index(from: to)

        return String(self[..<toIndex])
    }
    
    public func substring(from: Int, to: Int) -> String {
        let fromIndex = index(from: from)
        let toIndex = index(from: to)

        return String(self[fromIndex..<toIndex])
    }
    
    public func substring(from: Int, length: Int) -> String {
        let fromIndex = index(from: from)
        let endIndex = index(from: from + length)

        return String(self[fromIndex..<endIndex])
    }
    
    public func substring(from: Index, to: Index) -> String {
        return String(self[from..<to])
    }

    public func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)

        return String(self[startIndex..<endIndex])
    }
    
    public func indexOf(str: String) -> Int? {
        if let range = self.range(of: str) {
            return self.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }
    
    public func indexOf(char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
    
    public func indexLower<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    public func indexUpper<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    
}
