//
//  Schedule.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Schedule: Codable, Identifiable {
    var id: String
    var userId: String
    var events: [String]
    var title: String
    var creationDate: TimeInterval
    
    init(id: String, userId: String, events: [String], title: String, creationDate: Double) {
        self.id = id
        self.userId = userId
        self.events = events
        self.title = title
        self.creationDate = creationDate
    }
    
    static func defaultSchedule(userId: String, username: String) -> Schedule {
        let defaultSchedule = Schedule(
            id: UUID().uuidString,
            userId: userId,
            events: [],
            title: "\(username)'s Schedule",
            creationDate: Date().timeIntervalSince1970
        )
        return defaultSchedule
    }
}
