//
//  Event.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

enum EventFrequency: Codable, Equatable {
    case weekly
}

struct RecurrenceRule: Codable, Hashable, Equatable {
    // How the event repeats
    // For you, this will always be "weekly"
    var frequency: EventFrequency?
    
    // The weekdays it repeats on (1=Sun, 2=Mon, etc.)
    var repeatingDays: Set<Int>?
    
    // An optional date for when the series ends
    var endDate: Date?
    
    init(frequency: EventFrequency? = nil, repeatingDays: Set<Int>? = nil, endDate: Date? = nil) {
        self.frequency = frequency
        self.repeatingDays = repeatingDays
        self.endDate = endDate
    }
}

struct Event: Codable, Identifiable, Hashable {
    
    let id: String
    let ownerId: String
    
    var title: String
    var startDate: Date
    var startTime: Int
    var endTime: Int
    var location: MTPlacemark
    var color: String
    
    var invitedUsers: [InvitedUser]?
    let recurrence: RecurrenceRule?
    var notes: String?
    
    init(id: String, ownerId: String, title: String, startDate: Date, startTime: Int, endTime: Int, location: MTPlacemark, color: String, invitedUsers: [InvitedUser]? = nil, recurrence: RecurrenceRule? = nil, notes: String? = nil) {
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.startDate = startDate
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.color = color
        
        self.invitedUsers = invitedUsers
        self.notes = notes
        self.recurrence = recurrence
    }
    
    enum CodingKeys: String, CodingKey {
        case id, ownerId, title, startDate, startTime, endTime, location, invitedUsers, color, notes, recurrence
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(title, forKey: .title)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(location, forKey: .location)
        try container.encode(color, forKey: .color)
        
        try container.encodeIfPresent(recurrence, forKey: .recurrence)
        try container.encodeIfPresent(invitedUsers, forKey: .invitedUsers)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.title = try container.decode(String.self, forKey: .title)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.startTime = try container.decode(Int.self, forKey: .startTime)
        self.endTime = try container.decode(Int.self, forKey: .endTime)
        self.location = try container.decode(MTPlacemark.self, forKey: .location)
        self.color = try container.decode(String.self, forKey: .color)
        
        self.invitedUsers = try container.decodeIfPresent([InvitedUser].self, forKey: .invitedUsers)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.recurrence = try container.decodeIfPresent(RecurrenceRule.self, forKey: .recurrence)
    }
}


