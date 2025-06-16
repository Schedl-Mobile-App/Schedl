//
//  User.swift
//  calendarTest
//
//  Created by David Medina on 9/25/24.
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    var id: String
    var username: String
    var email: String
    var displayName: String
    var profileImage: String
    var creationDate: TimeInterval
    
    init(id: String, username: String, email: String, displayName: String, profileImage: String, creationDate: Double) {
        self.id = id
        self.username = username
        self.email = email
        self.displayName = displayName
        self.profileImage = profileImage
        self.creationDate = creationDate
    }
}

//let mockUser: User = User(id: "1", username: "djay0628", email: "djay0628@gmail.com", displayName: "David Medina", profileImage: "pic1", creationDate: 123.0)
