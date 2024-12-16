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
    var eventPhotos: [String] = []
    var comments: [String] = []
    var likes: Double = 0
    var taggedUsers: [String] = []
    var eventLocation: String = ""
    var creationDate: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, eventPhotos, comments, likes, taggedUsers, eventLocation, creationDate
    }
    
    init(id: String, title: String, description: String, creationDate: TimeInterval) {
        self.id = id
        self.title = title
        self.description = description
        self.creationDate = creationDate
    }
    
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
