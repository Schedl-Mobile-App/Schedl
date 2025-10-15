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
    
    static func convertHourAndMinuteToDate(time: Int) -> Date {
        let hours = time / 60
        let minutes = time - (hours * 60)

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
    
    func datesInSameMonth(using calendar: Calendar = .current) -> [Date] {
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        return calendar.range(of: .day, in: .month, for: self)?.compactMap {
            DateComponents(calendar: calendar, year: year, month: month, day: $0, hour: 0).date
        } ?? []
    }
    
    var relativeDayString: String {
        let calendar = Calendar.current
        
        // Check if the date is today
        if calendar.isDateInToday(self) {
            return "Today"
        }
        
        // Check if the date is tomorrow
        if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        }
        
        // Check if the date was yesterday (often useful)
        if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        // For any other date, return a formatted string
        return self.formatted(date: .abbreviated, time: .omitted)
    }
}
