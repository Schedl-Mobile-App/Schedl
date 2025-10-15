//
//  MockScheduleFactory.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation

enum MockScheduleFactory {
    static func createSchedule(userId: String, name: String) -> Schedule {
        let title = "\(name)'s Schedule"
        
        return Schedule(id: UUID().uuidString, ownerId: userId, title: title, createdAt: Date.now)
    }
    
    static func createSchedules(_ count: Int, for userId: String, with name: String) -> [Schedule] {
        (0..<count).map { _ in createSchedule(userId: userId, name: name) }
    }
}
