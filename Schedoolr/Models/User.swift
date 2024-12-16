//
//  User.swift
//  calendarTest
//
//  Created by David Medina on 9/25/24.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var username: String
    var email: String
    var schedules: [String] = []
    var profileImage: String? = nil
    var requestIds: [String] = []
    var friendIds: [String] = []
    var creationDate: TimeInterval
    
    init(id: String, username: String, email: String, schedules: [String], profileImage: String, requestIds: [String], friendIds: [String], creationDate: Double) {
        self.id = id
        self.username = username
        self.email = email
        self.schedules = schedules
        self.profileImage = profileImage
        self.requestIds = requestIds
        self.friendIds = friendIds
        self.creationDate = creationDate
    }
}
