//
//  Event.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Event: Codable, Identifiable {
    var id: String
    var userId: String
    var scheduleId: String
    var title: String
    let startDate: TimeInterval
    let endDate: TimeInterval?
    let repeatingDays: Set<Int>?
    var startTime: TimeInterval
    var endTime: TimeInterval
    var creationDate: TimeInterval
    var locationName: String
    var locationAddress: String
    var latitude: Double
    var longitude: Double
    var taggedUsers: [String]
    var color: String
    var notes: String
    
    // on the database, we'll only ever a single exception for any given date where if an exception ever occurs, we'll simply update the modified value(s)
    var exceptions: [EventException]
    
    init(id: String,userId: String, scheduleId: String, title: String, startDate: TimeInterval, startTime: TimeInterval, endTime: TimeInterval, creationDate: Double, locationName: String, locationAddress: String, latitude: Double, longitude: Double, taggedUsers: [String], color: String, notes: String, endDate: TimeInterval? = nil, repeatingDays: Set<Int>? = nil, exceptions: [EventException] = []) {
        self.id = id
        self.userId = userId
        self.scheduleId = scheduleId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.repeatingDays = repeatingDays
        self.startTime = startTime
        self.endTime = endTime
        self.creationDate = creationDate
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.taggedUsers = taggedUsers
        self.color = color
        self.notes = notes
        self.exceptions = exceptions
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
//    var taggedUsers: [String]?
    var repeatedDays: Set<Int>?
    var color: String?
    var notes: String?
    
    init(futureEventsIncluded: Bool, date: TimeInterval, title: String? = nil, startTime: TimeInterval? = nil, endTime: TimeInterval? = nil, locationName: String? = nil, locationAddress: String? = nil, latitude: Double? = nil, longitude: Double? = nil, /*taggedUsers: [String]? = nil,*/ repeatedDays: Set<Int>? = nil, color: String? = nil, notes: String? = nil) {
        self.futureEventsIncluded = futureEventsIncluded
        self.date = date
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
//        self.taggedUsers = taggedUsers
        self.repeatedDays = repeatedDays
        self.color = color
        self.notes = notes
    }
}
