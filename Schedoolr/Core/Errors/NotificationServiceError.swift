//
//  NotificationServiceError.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

enum NotificationServiceError: Error {
    case failedToFetchUserId
    case failedToFetchUserRequests
    case failedToSerializeFriendRequest
    case failedToSendFriendRequest
}
