//
//  NotificationServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

import FirebaseDatabase

protocol NotificationServiceProtocol {
    func fetchAllNotifications(userId: String) async throws -> [Notification]
    func fetchNotificationById(notificationId: String, userId: String) async throws -> Notification?
    func fetchNotificationsByIds(notificationIds: [String], userId: String) async throws -> [Notification]
    func handleFriendRequestResponse(notificationId: String, senderId: String, toUserId: String, responseStatus: Bool) async throws -> Void
    func createFriendRequest(fromUserId: String, senderName: String, senderProfileImage: String, toUserId: String) async throws -> Void
    func handleEventInviteResponse(notificationId: String, senderId: String, eventId: String, userId: String, scheduleId: String, responseStatus: Bool) async throws -> Void
    func handleBlendInviteResponse(notificationId: String, senderId: String, blendId: String, userId: String, scheduleId: String, responseStatus: Bool) async throws -> Void
}
