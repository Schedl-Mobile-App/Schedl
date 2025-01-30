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
    
    static func convertTimeToDate(time: Double) -> Date {
        let hours = Int(floor(time/3600))
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600))
        
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        
        let dateObj: Date = Calendar.current.date(from: dateComponents) ?? Date()
        return dateObj
    }
    
    static func convertDateToTime(date: Date) -> Int {
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        
        let timeInMinutes = hours * 60 + minutes
        
        return timeInMinutes
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
