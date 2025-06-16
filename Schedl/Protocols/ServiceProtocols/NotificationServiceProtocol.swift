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
    func sendEventInvites(senderId: String, username: String, profileImage: String, toUserIds: [String], eventId: String) async throws -> Void
    func sendFriendRequest(userId: String, username: String, profileImage: String, toUsername: String) async throws -> Void
    func handleFriendRequestResponse(notificationId: String, senderId: String, toUserId: String, responseStatus: Bool) async throws -> Void
    func handleEventInviteResponse(notificationId: String, senderScheduleId: String, eventId: String, senderId: String, toUserId: String, userScheduleId: String, responseStatus: Bool) async throws -> Void
    func observeUserNotifications(userId: String, completion: @escaping ([String]) -> Void) -> DatabaseHandle
    func removeUserNotificationObserver(handle: DatabaseHandle, userId: String)
}
