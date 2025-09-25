//
//  UserServiceProtcol.swift
//  Schedoolr
//
//  Created by David Medina on 5/4/25.
//

import Foundation
import UIKit

protocol UserServiceProtocol {
    func fetchUser(userId: String) async throws -> User
    func fetchUsers(friendIds: [String]) async throws -> [User]
    func setProfileInfo(userId: String, email: String, username: String, displayName: String) async throws -> User
    func updateProfileImage(newImage: UIImage, userId: String) async throws -> URL
    func updateProfileInfo(userId: String, username: String?, profileImage: UIImage?, email: String?) async throws -> Void
    func fetchUserIdByUsername(username: String) async throws -> String
    func fetchUserFriends(userId: String) async throws -> [User]
    func fetchNumberOfFriends(userId: String) async throws -> Int
    func isFriend(userId: String, otherUserId: String) async throws -> Bool
    func fetchUserNameById(userId: String) async throws -> String
    func fetchDisplayNameById(userId: String) async throws -> String
    func friendRequestPending(fromUserId: String, toUserId: String) async throws -> Bool
}
