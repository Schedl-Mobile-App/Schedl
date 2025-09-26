//
//  User.swift
//  Schedoolr
//
//  Created by David Medina on 5/16/25.
//

struct User: Identifiable, Codable, Hashable {
    var id: String
    var email: String
    var displayName: String
    var username: String
    var profileImage: String
    var numOfEvents: Int
    var numOfFriends: Int
    var numOfPosts: Int
    
    init(id: String, email: String?, displayName: String, username: String?, profileImage: String?, numOfEvents: Int?, numOfFriends: Int?, numOfPosts: Int?) {
        self.id = id
        self.email = email ?? ""
        self.displayName = displayName
        self.username = username ?? ""
        self.profileImage = profileImage ?? ""
        self.numOfEvents = numOfEvents ?? 0
        self.numOfFriends = numOfFriends ?? 0
        self.numOfPosts = numOfPosts ?? 0
    }
    
    // 1. Define the keys your document might have.
    enum CodingKeys: String, CodingKey {
        case id, email, displayName, username, profileImage, numOfEvents, numOfFriends, numOfPosts
    }
    
    // 2. Implement the custom decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // For fields that are guaranteed to exist
        self.id = try container.decode(String.self, forKey: .id)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.username = try container.decode(String.self, forKey: .username)
        
        // For fields that might be missing, use decodeIfPresent and provide a default value.
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
        self.numOfEvents = try container.decodeIfPresent(Int.self, forKey: .numOfEvents) ?? 0
        self.numOfFriends = try container.decodeIfPresent(Int.self, forKey: .numOfFriends) ?? 0
        self.numOfPosts = try container.decodeIfPresent(Int.self, forKey: .numOfPosts) ?? 0
    }
}
