//
//  Extensions.swift
//  Schedoolr
//
//  Created by David Medina on 1/29/25.
//

import SwiftUI
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

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}
