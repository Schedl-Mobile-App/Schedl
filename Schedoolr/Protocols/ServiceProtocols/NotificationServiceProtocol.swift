//
//  NotificationServiceProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/7/25.
//

protocol NotificationServiceProtocol {
    func fetchFriendRequest(requestId: String) async throws -> FriendRequest
    func fetchFriendRequests(userId: String) async throws -> [FriendRequest]
    func sendFriendRequest(userId: String, username: String, profileImage: String, toUserName: String) async throws -> Void
    func handleFriendRequestResponse(requestId: String, accepted: Bool) async throws -> Void
}
