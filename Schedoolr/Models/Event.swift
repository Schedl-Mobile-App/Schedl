//
//  Event.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Event: Codable, Identifiable, Equatable {
    var id: String
    var scheduleId: String
    var title: String
    var eventDate: TimeInterval
    var startTime: TimeInterval
    var endTime: TimeInterval
    var creationDate: TimeInterval
    
    init(id: String, scheduleId: String, title: String, eventDate: TimeInterval, startTime: TimeInterval, endTime: TimeInterval, creationDate: Double) {
        self.id = id
        self.scheduleId = scheduleId
        self.title = title
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
        self.creationDate = creationDate
    }
}
