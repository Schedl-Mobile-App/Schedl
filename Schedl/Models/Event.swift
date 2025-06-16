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
    let repeatingDays: [String]?
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
    
    init(id: String,userId: String, scheduleId: String, title: String, startDate: TimeInterval, startTime: TimeInterval, endTime: TimeInterval, creationDate: Double, locationName: String, locationAddress: String, latitude: Double, longitude: Double, taggedUsers: [String], color: String, notes: String, endDate: TimeInterval? = nil, repeatingDays: [String]? = nil) {
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
    }
}
