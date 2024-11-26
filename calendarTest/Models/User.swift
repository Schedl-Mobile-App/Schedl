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
    var schedules: [String]? = []
    var creationDate: TimeInterval
    
    init(id: String, username: String, email: String, schedules: [String], creationDate: Double) {
        self.id = id
        self.username = username
        self.email = email
        self.schedules = schedules
        self.creationDate = creationDate
    }
}
