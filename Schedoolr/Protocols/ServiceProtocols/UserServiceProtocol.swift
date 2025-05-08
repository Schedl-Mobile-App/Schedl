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
    func fetchUsers(userIds: [String]) async throws -> [User]
    func saveNewUser(userId: String, username: String, email: String, displayName: String) async throws -> User
    func updateProfileImage(newImage: UIImage, userId: String) async throws -> URL
    func updateProfileInfo(userId: String, username: String?, profileImage: UIImage?, email: String?) async throws -> Void
    func fetchUserIdByUsername(username: String) async throws -> String
    func fetchUserFriends(userId: String) async throws -> [User]
    func fetchUserNameById(userId: String) async throws -> String
}
