//
//  Event.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Event: Codable, Identifiable, Hashable {
    var id: String
    var ownerId: String
    var title: String
    let startDate: Double
    let endDate: TimeInterval?
    let repeatingDays: Set<Int>?
    var startTime: Double
    var endTime: Double
    var location: MTPlacemark
    var invitedUsers: [InvitedUser]
    var color: String
    var notes: String
    
    // on the database, we'll only ever a single exception for any given date where if an exception ever occurs, we'll simply update the modified value(s)
//    var exceptions: [EventException]
    
    init(id: String, ownerId: String, title: String, startDate: TimeInterval, startTime: TimeInterval, endTime: TimeInterval, locationName: String, locationAddress: String, latitude: Double, longitude: Double, invitedUsers: [InvitedUser], color: String, notes: String, endDate: TimeInterval? = nil, repeatingDays: Set<Int>? = nil, exceptions: [EventException] = []) {
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.repeatingDays = repeatingDays
        self.startTime = startTime
        self.endTime = endTime
        self.location = MTPlacemark(name: locationName, address: locationAddress, latitude: latitude, longitude: longitude)
        self.invitedUsers = invitedUsers
        self.color = color
        self.notes = notes
//        self.exceptions = exceptions
    }
    
    enum CodingKeys: String, CodingKey {
        case id, ownerId, title, startDate, endDate, repeatingDays, startTime, endTime, location, invitedUsers, color, notes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(title, forKey: .title)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encodeIfPresent(repeatingDays, forKey: .repeatingDays)
        try container.encodeIfPresent(invitedUsers, forKey: .invitedUsers)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(location, forKey: .location)
        try container.encode(color, forKey: .color)
        try container.encode(notes, forKey: .notes)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.title = try container.decode(String.self, forKey: .title)
        self.startDate = try container.decode(Double.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Double.self, forKey: .endDate)
        self.startTime = try container.decode(Double.self, forKey: .startTime)
        self.endTime = try container.decode(Double.self, forKey: .endTime)
        self.repeatingDays = try container.decodeIfPresent(Set<Int>.self, forKey: .repeatingDays)
        self.location = try container.decode(MTPlacemark.self, forKey: .location)
        self.color = try container.decode(String.self, forKey: .color)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.invitedUsers = try container.decode([InvitedUser].self, forKey: .invitedUsers)
    }
}

struct EventException: Codable, Equatable {
    var futureEventsIncluded: Bool
    var date: TimeInterval
    var title: String?
    var startTime: TimeInterval?
    var endTime: TimeInterval?
    var locationName: String?
    var locationAddress: String?
    var latitude: Double?
    var longitude: Double?
    var repeatedDays: Set<Int>?
    var color: String?
    var notes: String?
    
    init(futureEventsIncluded: Bool, date: TimeInterval, title: String? = nil, startTime: TimeInterval? = nil, endTime: TimeInterval? = nil, locationName: String? = nil, locationAddress: String? = nil, latitude: Double? = nil, longitude: Double? = nil, repeatedDays: Set<Int>? = nil, color: String? = nil, notes: String? = nil) {
        self.futureEventsIncluded = futureEventsIncluded
        self.date = date
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.repeatedDays = repeatedDays
        self.color = color
        self.notes = notes
    }
}
