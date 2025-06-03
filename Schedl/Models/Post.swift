//
//  Post.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import Foundation

struct Post: Codable, Identifiable {
    var id: String
    var title: String
    var description: String
    var eventPhotos: [String]
    var comments: [String]
    var likes: Double
    var taggedUsers: [String]
    var eventLocation: String
    var creationDate: TimeInterval
    
    init(id: String, title: String, description: String, eventPhotos: [String], comments: [String], likes: Double, taggedUsers: [String], eventLocation: String, creationDate: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.eventPhotos = eventPhotos
        self.comments = comments
        self.likes = likes
        self.taggedUsers = taggedUsers
        self.eventLocation = eventLocation
        self.creationDate = creationDate
    }
}
