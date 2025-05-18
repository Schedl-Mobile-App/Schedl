//
//  Date+Extension.swift
//  Schedoolr
//
//  Created by David Medina on 5/17/25.
//

import Foundation

extension Date {
    static func convertToTimestamp(date: Date) -> Double {
        return date.timeIntervalSince1970
    }
    
    static func fromTimestamp(timestamp: Double) -> Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    static func convertHourAndMinuteToDate(time: TimeInterval) -> Date {
        let hours = Int(floor(time / 3600))
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)

        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes

        return Calendar.current.date(from: dateComponents)!
    }
    
    static func convertTimeSince1970ToDate(time: TimeInterval) -> Date {
        print(Date(timeIntervalSince1970: time))
        return Date(timeIntervalSince1970: time) - computeTimeSinceStartOfDay(date: Date())
    }
    
    static func convertCurrentDateToTimeInterval(date: Date) -> TimeInterval {
        return date.timeIntervalSince1970 - computeTimeSinceStartOfDay(date: date)
    }
    
    static func computeTimeSinceStartOfDay(date: Date) -> TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return date.timeIntervalSince(startOfDay)
    }
    
    static func computeTimeSince1970(date: Date) -> TimeInterval {
        return date.timeIntervalSince1970
    }
}
