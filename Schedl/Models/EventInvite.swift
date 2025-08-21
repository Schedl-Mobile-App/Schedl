//
//  EventInvite.swift
//  Schedl
//
//  Created by David Medina on 6/13/25.
//

struct EventInvite: Codable {
    var fromUserId: String
    var toUserId: String
    var invitedEventId: String
    var eventDate: Double
    var startTime: Double
    var endTime: Double
    var senderName: String
    var senderProfileImage: String
}
