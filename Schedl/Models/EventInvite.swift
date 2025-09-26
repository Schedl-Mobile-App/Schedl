//
//  EventInvite.swift
//  Schedl
//
//  Created by David Medina on 6/13/25.
//

struct EventInvite: Codable {
    var fromUserId: String
    var toUserId: String
    var eventId: String
    var senderName: String
    var senderProfileImage: String
}
