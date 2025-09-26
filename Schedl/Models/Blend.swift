//
//  Blend.swift
//  Schedl
//
//  Created by David Medina on 8/5/25.
//

struct UserMappedBlendColor: Codable {
    let userId: String
    var color: String
}

struct Blend: Codable, Identifiable {
    let id: String
    let ownerId: String
    var title: String
    var invitedUsers: [InvitedUser]
    var scheduleIds: [String]
    var colors: [UserMappedBlendColor]
    
    enum CodingKeys: String, CodingKey {
        case id, ownerId, title, invitedUsers, scheduleIds, colors
    }
    
    // Explicit memberwise initializer for creating new Blend values in app code
    init(id: String, ownerId: String, title: String, invitedUsers: [InvitedUser], scheduleIds: [String], colors: [UserMappedBlendColor]) {
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.invitedUsers = invitedUsers
        self.scheduleIds = scheduleIds
        self.colors = colors
    }
    
    // Custom Decodable for reading from Firestore maps
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.title = try container.decode(String.self, forKey: .title)
        
        // --- Custom Decoding Logic ---
        
        // 1. Decode the Firestore map into a Swift dictionary.
        self.invitedUsers = try container.decode([InvitedUser].self, forKey: .invitedUsers)
        self.scheduleIds = try container.decode([String].self, forKey: .scheduleIds)
        self.colors = try container.decode([UserMappedBlendColor].self, forKey: .colors)
    }
}

