//
//  UserService.swift
//  Schedoolr
//
//  Created by David Medina on 5/2/25.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFunctions
import UIKit

struct SetProfileResult: Codable {
    let status: String
    let data: User
}

class UserService: UserServiceProtocol {
    
    static let shared = UserService()
    let db: Firestore
    let storage: Storage
    let functions: Functions
    
    private init() {
        db = Firestore.firestore()
        storage = Storage.storage()
        functions = Functions.functions()
    }
    
    func fetchUser(userId: String) async throws -> User {
        let userRef = db.collection("users").document(userId)
        do {
            let user = try await userRef.getDocument(as: User.self)
            return user
        } catch {
            print("Invalid data in the fetch user service method: \(error.localizedDescription)")
            throw UserServiceError.invalidData
        }
    }
    
    func fetchUsers(friendIds: [String]) async throws -> [User] {
        
        if friendIds.isEmpty { return [] }
        
        do {
            let query = db.collection("public_profiles").whereField("id", in: friendIds)
            let snapshot = try await query.getDocuments()
            
            let friends = try snapshot.documents.compactMap { document in
                try document.data(as: User.self)
            }
            
            return friends
        } catch {
            throw UserServiceError.failedToFetchFriends
        }
    }
    
    // Bridges Cloud Function callback to async/await and decodes { status, data: User }.
    func setProfileInfo(userId: String, email: String, username: String, displayName: String) async throws -> User {
        let payload: [String: Any] = [
            "userId": userId,
            "email": email,
            "displayName": displayName,
            "username": username,
        ]
        
        do {
            let callableResult = try await functions.httpsCallable("setProfileInfo").call(payload)
            
            // callableResult.data is Foundation-bridged Any (NSDictionary/NSArray/etc.)
            // Expecting: { "status": String, "data": { ...User fields... } }
            guard let dict = callableResult.data as? [String: Any] else {
                throw UserServiceError.invalidData
            }
            
            // Serialize to JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            
            // Decode into your Codable wrapper
            let decoded = try JSONDecoder().decode(SetProfileResult.self, from: jsonData)
            
            // Optionally, you can check decoded.status if you need to validate success
            // e.g., guard decoded.status == "success" else { throw FirebaseError.failedToCreateUser }
            
            return decoded.data
        } catch {
            print("The following error occured while setting the profile info: \(error.localizedDescription)")
            throw FirebaseError.failedToCreateUser
        }
    }
    
    func updateProfileImage(newImage: UIImage, userId: String) async throws -> URL {
        do {
            let ref = storage.reference(withPath: "users/\(userId)/profileImages/profile_\(UUID().uuidString).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            guard let imageData = newImage.jpegData(compressionQuality: 0.5) else {
                throw StorageServiceError.failedToCompressImage
            }
                        
            _ = try await ref.putDataAsync(imageData, metadata: metadata)
            let imageUrl = try await ref.downloadURL()
            
            let batch = db.batch()
            let userRef = db.collection("users").document(userId)
            let profileRef = db.collection("public_profiles").document(userId)
            
            batch.updateData(["profileImage": imageUrl.absoluteString], forDocument: userRef)
            batch.updateData((["profileImage": imageUrl.absoluteString]), forDocument: profileRef)
            
            try await batch.commit()
            
            return imageUrl
        } catch {
            throw UserServiceError.failedToUpdateProfileImage
        }
    }
    
    func updateProfileInfo(userId: String, username: String? = nil, profileImage: UIImage? = nil, email: String? = nil) async throws -> Void {
        var updates: [String : Any] = [:]
        
        if let username = username {
            updates["username"] = username
        }
        if let profileImage = profileImage {
            let url = try await updateProfileImage(newImage: profileImage, userId: userId)
            updates["profileImage"] = url.absoluteString
        }
        if let email = email {
            updates["email"] = email
        }
        
        guard updates.isEmpty == false else { return }
        
        do {
            try await db.collection("users").document(userId).updateData(updates)
        } catch {
            throw FirebaseError.failedToUpdateUserInfo
        }
    }
    
    func fetchUserIdByUsername(username: String) async throws -> String {
        // Try a mapping collection first
        let mappingDoc = try await db.collection("usernames").document(username).getDocument()
        if let data = mappingDoc.data(), let userId = data["userId"] as? String {
            return userId
        }
        // Fallback: query users by username field
        let query = try await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
        if let doc = query.documents.first {
            return doc.documentID
        }
        throw FirebaseError.failedToFetchUserByName
    }
    
    func fetchNumberOfFriends(userId: String) async throws -> Int {
        let doc = try await db.collection("users").document(userId).getDocument()
        guard let data = doc.data() else {
            throw UserServiceError.failedToFetchFriends
        }
        let friends = data["friends"] as? [String: Any] ?? [:]
        return friends.count
    }
    
    func fetchUserFriends(userId: String) async throws -> [User] {
        let friendsRef = db.collection("users").document(userId).collection("friends")
        let snapshot = try await friendsRef.getDocuments()
        
        let friendIds = snapshot.documents.compactMap { $0.documentID }
        
        guard friendIds.isEmpty == false else { return [] }
        
        do {
            let query = db.collection("public_profiles").whereField("id", in: friendIds)
            let snapshot = try await query.getDocuments()
            
            let searchInfo = try snapshot.documents.compactMap { document in
                return try document.data(as: User.self)
            }
            
            return searchInfo
            
        } catch {
            throw UserServiceError.invalidData
        }
    }
    
    func isFriend(userId: String, otherUserId: String) async throws -> Bool {
        let friendsRef = db.collection("users").document(userId).collection("friends").document(otherUserId)
        let snapshot = try await friendsRef.getDocument()
        
        return snapshot.exists
    }
    
    func fetchUserNameById(userId: String) async throws -> String {
        do {
            let ref = db.collection("public_profileS").document(userId)
            let snapshot = try await ref.getDocument()
            
            if let data = snapshot.data() {
                guard let username = data["username"] as? String else {
                    throw FirebaseError.failedToFetchUserById
                }
                return username
            } else {
                // Document exists but no data
                throw FirebaseError.failedToFetchUserById
            }
        } catch {
            throw FirebaseError.failedToFetchUserById
        }
    }
    
    func fetchDisplayNameById(userId: String) async throws -> String {
        do {
            let ref = db.collection("public_profiles").document(userId)
            let snapshot = try await ref.getDocument()
            
            if let data = snapshot.data() {
                guard let displayName = data["displayName"] as? String else {
                    throw FirebaseError.failedToFetchUserById
                }
                return displayName
            } else {
                // Document exists but no data
                throw FirebaseError.failedToFetchUserById
            }
        } catch {
            throw FirebaseError.failedToFetchUserById
        }
    }
    
    func friendRequestPending(fromUserId: String, toUserId: String) async throws -> Bool {
        do {
            // Query A: fromUserId -> toUserId
            let query = db.collection("friend_requests")
                .whereField("fromUserId", in: [fromUserId, toUserId])
                .whereField("toUserId", in: [fromUserId, toUserId])
                .limit(to: 1)

            let snapshot = try await query.getDocuments()
            return !snapshot.isEmpty
        }
    }
}

// Async wrapper for Storage putData
private extension StorageReference {
    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: metadata ?? StorageMetadata())
                }
            }
        }
    }
}
