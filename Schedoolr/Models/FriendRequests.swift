//
//  FriendRequests.swift
//  calendarTest
//
//  Created by David Medina on 12/13/24.
//

struct FriendRequests: Codable, Identifiable {
    var id: String
    var fromUserId: String
    var toUserId: String
    var status: String
    var senderName: String
    var sendProfileImage: String
    
    init(id: String, fromUserId: String, toUserId: String, status: String, senderName: String, sendProfileImage: String) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.senderName = senderName
        self.sendProfileImage = sendProfileImage
    }
}
