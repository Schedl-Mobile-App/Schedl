//
//  FriendRequests.swift
//  calendarTest
//
//  Created by David Medina on 12/13/24.
//

struct FriendRequest: Codable {
    var fromUserId: String
    var toUserId: String
    var senderName: String
    var senderProfileImage: String
}
