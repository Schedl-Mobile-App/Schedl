//
//  Event.swift
//  calendarTest
//
//  Created by David Medina on 9/29/24.
//

import Foundation

struct Event: Codable, Identifiable {
    var id: String
    var scheduleId: String
    var title: String
    var eventDate: TimeInterval
    var startTime: TimeInterval
    var endTime: TimeInterval
    var creationDate: TimeInterval
    var locationName: String
    var locationAddress: String
    var latitude: Double
    var longitude: Double
    var taggedUsers: [String]
    var color: String
    
    init(id: String, scheduleId: String, title: String, eventDate: TimeInterval, startTime: TimeInterval, endTime: TimeInterval, creationDate: Double, locationName: String, locationAddress: String, latitude: Double, longitude: Double, taggedUsers: [String], color: String) {
        self.id = id
        self.scheduleId = scheduleId
        self.title = title
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
        self.creationDate = creationDate
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.taggedUsers = taggedUsers
        self.color = color
    }
    
    
}
