//
//  Notification.swift
//  Schedl
//
//  Created by David Medina on 6/13/25.
//

import Foundation

enum NotificationPayload {
    case friendRequest(FriendRequest)
    case eventInvite(EventInvite)
    case blendInvite(BlendInvite)
    case unknown
}

struct Notification: Identifiable, Equatable {
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    var type: String
    var notificationPayload: NotificationPayload
    var createdAt: Date
}

extension Notification: Decodable {
    
    // Define the keys that match your data source (e.g., Firestore document fields)
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case notificationPayload // We'll handle this key manually
        case createdAt
    }
    
    // Custom decoder initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the simple properties first
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        // Now, dynamically decode the payload based on the 'type' string
        switch type {
        case "friend_request":
            let payload = try container.decode(FriendRequest.self, forKey: .notificationPayload)
            notificationPayload = .friendRequest(payload)
            
        case "event_invite":
            let payload = try container.decode(EventInvite.self, forKey: .notificationPayload)
            notificationPayload = .eventInvite(payload)
            
        case "blend_invite":
            let payload = try container.decode(BlendInvite.self, forKey: .notificationPayload)
            notificationPayload = .blendInvite(payload)
            
        default:
            notificationPayload = .unknown
        }
    }
}
