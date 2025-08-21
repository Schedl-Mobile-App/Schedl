//
//  NotificationPayload.swift
//  Schedl
//
//  Created by David Medina on 6/13/25.
//

enum NotificationPayload: Codable {
    case friendRequest(FriendRequest)
    case eventInvite(EventInvite)
    case blend(BlendInvite)
}
