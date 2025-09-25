//
//  NotificationService.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

import Firebase
import FirebaseFirestore
import FirebaseFunctions

class NotificationService: NotificationServiceProtocol {
    
    static let shared = NotificationService()
    let db: Firestore
    let functions: Functions
    
    private init() {
        db = Firestore.firestore()
        functions = Functions.functions()
    }
    
    func fetchAllNotifications(userId: String) async throws -> [Notification] {
        do {
            let notificationRef = db.collection("notifications").document(userId).collection("userNotifications")
            let snapshot = try await notificationRef.getDocuments()
            
            let notifications: [Notification] = try snapshot.documents.compactMap { document in
                let notification = try document.data(as: Notification.self)
                return notification
            }
            
            return notifications
        } catch {
            throw NotificationServiceError.failedToFetchAllNotifications
        }
    }
    
    func fetchNotificationById(notificationId: String, userId: String) async throws -> Notification? {
        do {
            let notificationRef = db.collection("notifications").document(userId).collection("userNotifications").document(notificationId)
            let snapshot = try await notificationRef.getDocument()
            
            return try snapshot.data(as: Notification.self)
        } catch {
            throw NotificationServiceError.failedToFetchNotification
        }
    }
    
    func fetchNotificationsByIds(notificationIds: [String], userId: String) async throws -> [Notification] {
        
        var userNotifications: [Notification] = []
        
        try await withThrowingTaskGroup(of: Notification?.self) { group in
            for id in notificationIds {
                group.addTask {
                    try await self.fetchNotificationById(notificationId: id, userId: userId)
                }
            }
            
            for try await notification in group {
                guard let notif = notification else { continue }
                userNotifications.append(notif)
            }
        }
        
        return userNotifications
    }
    
    func createFriendRequest(fromUserId: String, senderName: String, senderProfileImage: String, toUserId: String) async throws -> Void {
        let friendRequestRef = db.collection("friend_requests").document()
        let friendRequest = FriendRequest(fromUserId: fromUserId, toUserId: toUserId, senderName: senderName, senderProfileImage: senderProfileImage)
        
        do {
            try friendRequestRef.setData(from: friendRequest)
        } catch {
            throw NotificationServiceError.failedToCreateFriendRequest
        }
    }
        
    func handleEventInviteResponse(notificationId: String, senderId: String, eventId: String, userId: String, scheduleId: String, responseStatus: Bool) async throws -> Void {
        
        do {
            if responseStatus {
                let payload: [String: Any] = [
                    "notificationId": notificationId,
                    "eventId": eventId,
                    "fromUserId": senderId,
                    "toUserId": userId,
                    "scheduleId": scheduleId,
                    "responseStatus": true,
                ]
                
                let _ = try await functions.httpsCallable("handleEventInvite").call(payload)
            } else {
                let payload: [String: Any] = [
                    "notificationId": notificationId,
                    "eventId": eventId,
                    "fromUserId": senderId,
                    "toUserId": userId,
                    "scheduleId": scheduleId,
                    "responseStatus": false,
                ]
                
                let _ = try await functions.httpsCallable("handleEventInvite").call(payload)
            }
        } catch {
            throw FirebaseError.failedToUpdateFriendRequest
        }
    }
    
    func handleFriendRequestResponse(notificationId: String, senderId: String, toUserId: String, responseStatus: Bool) async throws -> Void {
        
        do {
            let batch = db.batch()
            
            let snapshot = try await db.collection("friend_requests").whereField("toUserId", isEqualTo: toUserId).whereField("fromUserId", isEqualTo: senderId).limit(to: 1).getDocuments()
            
            let notificationRef = db.collection("notifications").document(toUserId)
                .collection("userNotifications").document(notificationId)
            
            if responseStatus {
                
                let userFriendRef = db.collection("users").document(toUserId).collection("friends").document(senderId)
                
                let userFriendData = [
                    "friendsSince": FieldValue.serverTimestamp()
                ]
                
                try batch.setData(from: userFriendData, forDocument: userFriendRef)
                
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                
                batch.deleteDocument(notificationRef)
                
            } else {
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                batch.deleteDocument(notificationRef)
            }
            
            try await batch.commit()
            print("Friend request handled successfully.")
        } catch {
            // You can create your own custom error types
            throw FirebaseError.failedToUpdateFriendRequest
        }
    }
        
    func handleBlendInviteResponse(notificationId: String, senderId: String, blendId: String, userId: String, scheduleId: String, responseStatus: Bool) async throws -> Void {
        
        do {
            if responseStatus {
                let payload: [String: Any] = [
                    "notificationId": notificationId,
                    "fromUserId": senderId,
                    "blendId": blendId,
                    "toUserId": userId,
                    "scheduleId": scheduleId,
                    "responseStatus": true,
                ]
                
                let _ = try await functions.httpsCallable("handleBlendInvite").call(payload)
            } else {
                let payload: [String: Any] = [
                    "notificationId": notificationId,
                    "fromUserId": senderId,
                    "blendId": blendId,
                    "toUserId": userId,
                    "scheduleId": scheduleId,
                    "responseStatus": false,
                ]
                
                let _ = try await functions.httpsCallable("handleBlendInvite").call(payload)
            }
        } catch {
            throw FirebaseError.failedToUpdateFriendRequest
        }
    }
}

