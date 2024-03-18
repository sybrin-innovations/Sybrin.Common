//
//  String.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/11.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit

extension String {
    
    public func log(_ level: LogLevel, fromClass className: String = #file, inFunction functionName: String = #function, onLine lineNumber: Int = #line) {
        LogHandler.log(self, level, fromClass: className, inFunction: functionName, onLine: lineNumber)
    }

    public func showToast(on view: UIView, with options: ToastOptions = ToastOptions()) {
        ToastHandler.show(message: self, view: view, with: options)
    }
    
    public func stringToDate(withFormat format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        guard let date = dateFormatter.date(from: self) else { return nil }

        return date
    }
    
}
