//
//  FriendRequests.swift
//  calendarTest
//
//  Created by David Medina on 12/13/24.
//

struct FriendRequest: Codable, Identifiable {
    var id: String
    var fromUserId: String
    var toUserId: String
    var status: String
    var timestamp: Double
    var senderName: String
    var sendProfileImage: String
    
    init(id: String, fromUserId: String, toUserId: String, status: String, timestamp: Double, senderName: String, sendProfileImage: String) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.timestamp = timestamp
        self.senderName = senderName
        self.sendProfileImage = sendProfileImage
    }
}
