//
//  Date+Extension.swift
//  Folders
//
//  Created by Cengizhan Tomak on 4.09.2023.
//

import Foundation

extension Date {
    public func CurrentDateTime(From Date: Date = Date()) -> String {
        let Formatter = DateFormatter()
        Formatter.dateFormat = StringConstants.DateTimeFormatFolder
        return Formatter.string(from: Date)
    }
    
    static func CurrentDate(From Date: Date = Date()) -> String {
        let Formatter = DateFormatter()
        Formatter.dateFormat = StringConstants.DateFormat
        return Formatter.string(from: Date)
    }
    
    static func CurrentTime(From Date: Date = Date()) -> String {
        let Formatter = DateFormatter()
        Formatter.dateFormat = StringConstants.TimeFormat
        return Formatter.string(from: Date)
    }
}
