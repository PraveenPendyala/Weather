//
//  Date+Extension.swift
//  Weather
//
//  Created by Praveen on 4/16/23.
//

import Foundation

extension DateFormatter {
    fileprivate static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
}

extension Date {
    func dateStringWithFormat(_ format: String = "h:mm a", toTimeZone: TimeZone = TimeZone.current) -> String {
        DateFormatter.formatter.dateFormat = format
        DateFormatter.formatter.timeZone   = toTimeZone
        return DateFormatter.formatter.string(from: self)
    }
}
