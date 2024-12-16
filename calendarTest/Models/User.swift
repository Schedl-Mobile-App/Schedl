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
<<<<<<< Updated upstream
    var schedules: [String] = []
    var profileImage: String? = nil
    var requestIds: [String] = []
    var friendIds: [String] = []
    var creationDate: TimeInterval
    
    init(id: String, username: String, email: String, schedules: [String], profileImage: String, requestIds: [String], friendIds: [String], creationDate: Double) {
=======
    var schedules: [String]? = []
    var profileImage: String? = nil
    var creationDate: TimeInterval
    
    init(id: String, username: String, email: String, schedules: [String], profileImage: String, creationDate: Double) {
>>>>>>> Stashed changes
        self.id = id
        self.username = username
        self.email = email
        self.schedules = schedules
        self.profileImage = profileImage
<<<<<<< Updated upstream
        self.requestIds = requestIds
        self.friendIds = friendIds
=======
>>>>>>> Stashed changes
        self.creationDate = creationDate
    }
}
