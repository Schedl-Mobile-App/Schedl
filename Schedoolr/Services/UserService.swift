//
//  UserService.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

import FirebaseDatabase
import FirebaseStorage
import UIKit

class UserService: UserServiceProtocol {

    static let shared = UserService()
    let ref: DatabaseReference
    let storage: Storage
    
    private init() {
        ref = Database.database().reference()
        storage = Storage.storage()
    }
    
    func fetchUser(userId: String) async throws -> User {
        
        // Store a reference to the child node of the users node in the Firebase DB
        let userRef = ref.child("users").child(userId)
        
        // getData is a Firebase function that returns a DataSnapshot object
        let snapshot = try await userRef.getData()
        
        // The DataSnapshot object is returned as an object with key value pairs as Strings
        guard let userData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchUser
        }
        
        // only create a user object if we receive all parameters from the DB
        if
            let id = userData["id"] as? String,
            let username = userData["username"] as? String,
            let displayName = userData["displayName"] as? String,
            let email = userData["email"] as? String,
            let profileImage = userData["profileImage"] as? String,
            let createdAt = userData["creationDate"] as? Double {
            
            let user = User(id: id, username: username, email: email, displayName: displayName, profileImage: profileImage, creationDate: createdAt)
            return user
            
        } else {
            throw UserServiceError.invalidData
        }
    }
    
    func fetchUsers(userIds: [String]) async throws -> [User] {
        var users: [User] = []
        
        try await withThrowingTaskGroup(of: User.self) { group in
            for id in userIds {
                group.addTask {
                    return try await self.fetchUser(userId: id)
                }
            }
                        
            for try await user in group {
                users.append(user)
            }
        }
        
        return users
    }
    
    func saveNewUser(userId: String, username: String, email: String, displayName: String) async throws -> User {
        
        let userObj = User(id: userId, username: username, email: email, displayName: displayName, profileImage: "", creationDate: Date().timeIntervalSince1970)
        
        let encoder = JSONEncoder()
        do {
            // Encode the User object into JSON data
            let jsonData = try encoder.encode(userObj)
            
            // Convert JSON data to a dictionary
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                throw UserServiceError.serializationFailed
            }
            
            let updates: [String : Any] = [
                "/users/\(userId)" : jsonDictionary,
                "/usernames/\(username)" : userId
            ]
            
            // Given that we have valid JSON dictionary, let's write to the DB
            try await ref.updateChildValues(updates)
            return userObj
            
        } catch {
            throw FirebaseError.failedToCreateUser
        }
        
    }
    
    func updateProfileImage(newImage: UIImage, userId: String) async throws -> URL {
        let ref = storage.reference(withPath: userId)
        
        guard let imageData = newImage.jpegData(compressionQuality: 0.5) else {
            throw StorageServiceError.failedToCompressImage
        }
        
        ref.putData(imageData, metadata: nil)
        let imageUrl = try await ref.downloadURL()
        
        if let url = URL(string: imageUrl.absoluteString) {
            return url
        } else {
            throw FirebaseError.failedToDownloadImageURL
        }
    }
    
    func updateProfileInfo(userId: String, username: String? = nil, profileImage: UIImage? = nil, email: String? = nil) async throws -> Void {
        var updates: [String : Any] = [:]
        
        if let username = username {
            updates["/users/\(userId)/username"] = username
        }
        if let profileImage = profileImage {
            let url = try await updateProfileImage(newImage: profileImage, userId: userId)
            updates["/users/\(userId)/profileImage"] = url.absoluteString
        }
        if let email = email {
            updates["/users/\(userId)/email"] = email
        }
        
        do {
            try await ref.updateChildValues(updates)
        } catch {
            throw FirebaseError.failedToUpdateUserInfo
        }
    }
    
    func fetchUserIdByUsername(username: String) async throws -> String {
        let userRef = ref.child("usernames").child(username)
        let snapshot = try await userRef.getData()
        
        guard let userId = snapshot.value as? String else {
            throw FirebaseError.failedToFetchUserByName
        }
        
        return userId
    }
    
    func fetchUserFriends(userId: String) async throws -> [User] {
        
        let userRef = ref.child("users").child(userId).child("friends")
        let snapshot = try await userRef.getData()
        
        guard let friendsNode = snapshot.value as? [String: Any] else {
            throw UserServiceError.failedToFetchFriends
        }
        
        let friendIds = Array(friendsNode.keys)
        
        var friends: [User] = []
        
        if friendIds.isEmpty {
            return friends
        } else {
            try await withThrowingTaskGroup(of: User.self) { group in
                for id in friendIds {
                    group.addTask {
                        try await self.fetchUser(userId: id)
                    }
                }
                
                for try await friend in group {
                    friends.append(friend)
                }
            }
            
            return friends
        }
    }
    
    func fetchUserNameById(userId: String) async throws -> String {
        let userRef = ref.child("users").child(userId)
        
        let snapshot = try await userRef.getData()
        
        guard let userData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchUserById
        }
        
        let username = userData["username"] as? String ?? ""
        
        return username
    }
}
