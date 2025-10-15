//
//  MockUserService.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation
import UIKit

class MockUserService: UserServiceProtocol {
    
    private var users: [User]
    
    init(user: User) {
        users = MockUserFactory.createUsers(count: 10)
        users.append(user)
    }
    
    func fetchUser(userId: String) async throws -> User {
        guard let user = users.first(where: {$0.id == userId }) else { throw UserServiceError.failedToFetchUser }
        
        return user
    }
    
    func fetchUsers(friendIds: [String]) async throws -> [User] {
        return users.filter( { friendIds.contains($0.id) } )
    }
    
    func setProfileInfo(userId: String, email: String, username: String, displayName: String) async throws -> User {
        guard let index = users.firstIndex(where: {$0.id == userId }) else { throw UserServiceError.failedToFetchUser }
        
        users[index].email = email
        users[index].username = username
        users[index].displayName = displayName
        
        return users[index]
    }
    
    func updateProfileImage(newImage: UIImage, userId: String) async throws -> URL {
        
        return URL(string: "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FUNbmCWPIRFM8c9tmNz2gBNlNHGz1%2FprofileImages%2Fprofile_81EDEAE0-5EA9-4195-ABE1-76D168C25222.jpg?alt=media&token=df052ad0-5a78-4c57-9120-fc05284914ea"
)!
    }
    
    func updateProfileInfo(userId: String, username: String?, profileImage: UIImage?, email: String?) async throws {
        return
    }
    
    func fetchUserIdByUsername(username: String) async throws -> String {
        guard let user = users.first(where: { $0.username == username }) else { throw UserServiceError.failedToFetchUser }
                
        return user.id
    }
    
    func fetchUserFriends(userId: String) async throws -> [User] {
        return []
    }
    
    func fetchNumberOfFriends(userId: String) async throws -> Int {
        return 0
    }
    
    func isFriend(userId: String, otherUserId: String) async throws -> Bool {
        return false
    }
    
    func fetchUserNameById(userId: String) async throws -> String {
        guard let user = users.first(where: { $0.id == userId }) else { throw UserServiceError.failedToFetchUser }
        
        return user.username
    }
    
    func fetchDisplayNameById(userId: String) async throws -> String {
        guard let user = users.first(where: { $0.id == userId }) else { throw UserServiceError.failedToFetchUser }
        
        return user.displayName
    }
    
    func friendRequestPending(fromUserId: String, toUserId: String) async throws -> Bool {
        return false
    }
    
    
}
