//
//  Post.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import Foundation

<<<<<<< Updated upstream
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
=======
class Post: Codable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var title: String
    @Published var description: String
    @Published var eventPhotos: [String]
    @Published var comments: [Comment]
    @Published var likes: Int // Add a property for likes
    @Published var isLiked: Bool = false // Add a property to track if the current user liked the post
    var permission: Bool // whether a user has edit permission
    @Published var taggedUsers: [String] // store the IDs of tagged users
    @Published var eventLocation: String
    @Published var creationDate: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, eventPhotos, comments, likes, isLiked, permission, taggedUsers, eventLocation, creationDate
    }
    
    init(id: String, title: String, description: String, eventPhotos: [String], comments: [Comment], likes: Int, permission: Bool, taggedUsers: [String], eventLocation: String, creationDate: TimeInterval) {
>>>>>>> Stashed changes
        self.id = id
        self.title = title
        self.description = description
        self.eventPhotos = eventPhotos
        self.comments = comments
        self.likes = likes
<<<<<<< Updated upstream
=======
        self.permission = permission
>>>>>>> Stashed changes
        self.taggedUsers = taggedUsers
        self.eventLocation = eventLocation
        self.creationDate = creationDate
    }
<<<<<<< Updated upstream
=======
    
    // Implement the required methods for Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        eventPhotos = try container.decode([String].self, forKey: .eventPhotos)
        comments = try container.decode([Comment].self, forKey: .comments)
        likes = try container.decode(Int.self, forKey: .likes)
        permission = try container.decode(Bool.self, forKey: .permission)
        taggedUsers = try container.decode([String].self, forKey: .taggedUsers)
        eventLocation = try container.decode(String.self, forKey: .eventLocation)
        creationDate = try container.decode(TimeInterval.self, forKey: .creationDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(eventPhotos, forKey: .eventPhotos)
        try container.encode(comments, forKey: .comments)
        try container.encode(likes, forKey: .likes)
        try container.encode(permission, forKey: .permission)
        try container.encode(taggedUsers, forKey: .taggedUsers)
        try container.encode(eventLocation, forKey: .eventLocation)
        try container.encode(creationDate, forKey: .creationDate)
    }
>>>>>>> Stashed changes
}
