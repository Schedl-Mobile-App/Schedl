//
//  NotificationService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import FirebaseDatabase

class NotificationService: NotificationServiceProtocol {
    
    static let shared = NotificationService()
    let ref: DatabaseReference
    
    private init() {
        ref = Database.database().reference()
    }
    
    func fetchFriendRequest(requestId: String) async throws -> FriendRequest {
        let requestRef = ref.child("friendRequests").child(requestId)
        
        let snapshot = try await requestRef.getData()
        
        guard let requestData = snapshot.value as? [String: Any] else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        guard
            let fromUserId = requestData["fromUserId"] as? String,
            let toUserId = requestData["toUserId"] as? String,
            let status = requestData["status"] as? String,
            let timestamp = requestData["timestamp"] as? Double,
            let senderName = requestData["senderName"] as? String,
            let senderProfileImage = requestData["senderProfileImage"] as? String
        else {
            throw FirebaseError.failedToFetchFriendsPostsIds
        }
        
        return await MainActor.run {
            FriendRequest(
                id: requestId,
                fromUserId: fromUserId,
                toUserId: toUserId,
                status: status,
                timestamp: timestamp,
                senderName: senderName,
                sendProfileImage: senderProfileImage
            )
        }
    }
    
    func fetchFriendRequests(userId: String) async throws -> [FriendRequest] {
        
        let userRef = ref.child("users").child("requestIds")
        let snapshot = try await userRef.getData()
        
        guard let requestNode = snapshot.value as? [String : Any] else {
            throw NotificationServiceError.failedToFetchUserRequests
        }
        
        let requestIds = Array(requestNode.keys)
        
        var requests: [FriendRequest] = []
        
        if requestIds.isEmpty {
            return requests
        } else {
            try await withThrowingTaskGroup(of: FriendRequest.self) { group in
                for id in requestIds {
                    group.addTask {
                        try await self.fetchFriendRequest(requestId: id)
                    }
                }
                
                for try await request in group {
                    requests.append(request)
                }
            }
            
            return requests
        }
    }
    
    func sendFriendRequest(userId: String, username: String, profileImage: String, toUserName: String) async throws -> Void {
        
        let usernameRef = ref.child("usernames").child(username)
        let snapshot = try await usernameRef.getData()
        
        guard let toUserId = snapshot.value as? String else {
            throw NotificationServiceError.failedToFetchUserId
        }
        
        let requestId = "\(userId)_\(toUserId)"
        
        let friendRequest = FriendRequest(id: requestId, fromUserId: userId, toUserId: toUserId, status: "pending", timestamp: Date().timeIntervalSince1970, senderName: toUserName, sendProfileImage: profileImage)
        
        do {
            let encodedData = try JSONEncoder().encode(friendRequest)
            
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any] else {
                throw NotificationServiceError.failedToSerializeFriendRequest
            }
            
            let updates: [String : Any] = [
                "friendRequests/\(requestId)" : jsonDictionary,
                "users/\(toUserId)/incomingRequests/\(requestId)" : true,
                "users/\(userId)/outgoingRequests/\(requestId)" : true
            ]
            
            try await ref.updateChildValues(updates)
        } catch {
            throw NotificationServiceError.failedToSendFriendRequest
        }
    }
    
    func handleFriendRequestResponse(requestId: String, accepted: Bool) async throws -> Void {
        let requestInfo = requestId.split(separator: "_")
        
        if requestInfo.count == 2 {
            let fromUserId = String(requestInfo[0])
            let toUserId = String(requestInfo[1])
                    
            if accepted {
                
                let queryRequest: [String: Any] = [
                    "/friendRequests/\(requestId)/status": "accepted",
                    "/users/\(toUserId)/friends/\(fromUserId)": true,
                    "/users/\(fromUserId)/friends/\(toUserId)": true,
                    "/users/\(toUserId)/incomingRequests/\(requestId)": NSNull(),
                    "/users/\(fromUserId)/outgoingRequests/\(requestId)": NSNull()
                ]
                
                do {
                    try await ref.updateChildValues(queryRequest)
                } catch {
                    throw FirebaseError.failedToUpdateFriendRequest
                }
            } else {
                
                let queryRequest: [String: Any] = [
                    "/friendRequests/\(requestId)/status": "declined",
                    "/users/\(toUserId)/incomingRequests/\(requestId)": NSNull(),
                    "/users/\(fromUserId)/outgoingRequests/\(requestId)": NSNull()
                ]
                
                do {
                    try await ref.updateChildValues(queryRequest)
                } catch {
                    throw FirebaseError.failedToUpdateFriendRequest
                }
            }
            
        } else {
            throw FirebaseError.incorrectFriendRequestId
        }
    }
}
