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
    
    func fetchAllNotifications(userId: String) async throws -> [Notification] {
        let notificationRef = ref.child("notifications").child(userId)
        let snapshot = try await notificationRef.getData()
        
        var userNotifications: [Notification] = []
        let data = snapshot.value as? [String: Any] ?? [:]
        
        for (notificationId, notificationData) in data {
            guard let notificationDict = notificationData as? [String: Any] else { continue }
            
            let creationDate = notificationDict["creationDate"] as? Double ?? 0
            
            if
                let payloadDict = notificationDict["notificationPayload"] as? [String: Any],
                let friendRequestDict = payloadDict["friendRequest"] as? [String: Any],
                let firstEntry = friendRequestDict.values.first as? [String: Any] {
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .secondsSince1970
                
                let friendRequestJsonData = try JSONSerialization.data(withJSONObject: firstEntry, options: [])
                
                do {
                    let friendRequestObj = try jsonDecoder.decode(FriendRequest.self, from: friendRequestJsonData)
                    let notif = Notification(id: notificationId, type: .friendRequest, notificationPayload: .friendRequest(friendRequestObj), creationDate: creationDate)
                    userNotifications.append(notif)
                } catch {
                    print("Failed to decode notification")
                    throw NotificationServiceError.failedToDecodeNotification
                }
                
            } else if
                let payloadDict = notificationDict["notificationPayload"] as? [String: Any],
                let eventInviteDict = payloadDict["eventInvite"] as? [String: Any],
                let firstEntry = eventInviteDict.values.first as? [String: Any] {
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .secondsSince1970
                
                let eventInviteJsonData = try JSONSerialization.data(withJSONObject: firstEntry, options: [])
                
                do {
                    let eventInviteObj = try jsonDecoder.decode(EventInvite.self, from: eventInviteJsonData)
                    let notif = Notification(id: notificationId, type: .eventInvite, notificationPayload: .eventInvite(eventInviteObj), creationDate: creationDate)
                    userNotifications.append(notif)
                } catch {
                    print("Failed to decode notification")
                    throw NotificationServiceError.failedToDecodeNotification
                }
            }
        }
        
        return userNotifications
    }
    
    func fetchNotificationById(notificationId: String, userId: String) async throws -> Notification? {
        let notificationRef = ref.child("notifications").child(userId).child(notificationId)
        let snapshot = try await notificationRef.getData()
        
        let notificationDict = snapshot.value as? [String: Any] ?? [:]
        
        print(notificationDict)
        
        let creationDate = notificationDict["creationDate"] as? Double ?? 0
        
        if
            let payloadDict = notificationDict["notificationPayload"] as? [String: Any],
            let friendRequestDict = payloadDict["friendRequest"] as? [String: Any],
            let firstEntry = friendRequestDict.values.first as? [String: Any] {
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            
            let friendRequestJsonData = try JSONSerialization.data(withJSONObject: firstEntry, options: [])
            
            do {
                let friendRequestObj = try jsonDecoder.decode(FriendRequest.self, from: friendRequestJsonData)
                let notif = Notification(id: notificationId, type: .friendRequest, notificationPayload: .friendRequest(friendRequestObj), creationDate: creationDate)
                return notif
            } catch {
                print("Failed to decode notification")
                throw NotificationServiceError.failedToDecodeNotification
            }
            
        } else if
            let payloadDict = notificationDict["notificationPayload"] as? [String: Any],
            let eventInviteDict = payloadDict["eventInvite"] as? [String: Any],
            let firstEntry = eventInviteDict.values.first as? [String: Any] {
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            
            let eventInviteJsonData = try JSONSerialization.data(withJSONObject: firstEntry, options: [])
            
            do {
                let eventInviteObj = try jsonDecoder.decode(EventInvite.self, from: eventInviteJsonData)
                let notif = Notification(id: notificationId, type: .eventInvite, notificationPayload: .eventInvite(eventInviteObj), creationDate: creationDate)
                return notif
            } catch {
                print("Failed to decode notification")
                throw NotificationServiceError.failedToDecodeNotification
            }
        }
        
        return nil
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
    
    func sendEventInvites(senderId: String, username: String, profileImage: String, toUserIds: [String], eventId: String) async throws -> Void {
        
        var updates: [String: Any] = [:]
        
        for id in toUserIds {
            guard let notificationId = ref.child("notifications").childByAutoId().key else { return }
            let notificationType: NotificationType = .eventInvite
            let eventInvite: EventInvite = EventInvite(fromUserId: senderId, toUserId: id, invitedEventId: eventId, senderName: username, senderProfileImage: profileImage)
            let payload: NotificationPayload = .eventInvite(eventInvite)
            let creationDate = Date().timeIntervalSince1970
            
            let notificationObj = Notification(id: notificationId, type: notificationType, notificationPayload: payload, creationDate: creationDate)
            
            let encodedData = try JSONEncoder().encode(notificationObj)
            
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any] else {
                throw NotificationServiceError.failedToSerializeFriendRequest
            }
            
            updates["/notifications/\(id)/\(notificationId)"] = jsonDictionary
            updates["eventInvites/\(senderId)/\(id)"] = "pending"
        }
        
        do {
            try await ref.updateChildValues(updates)
        } catch {
            throw NotificationServiceError.failedToSendEventInvites
        }
    }

    func sendFriendRequest(userId: String, username: String, profileImage: String, toUsername toUserName: String) async throws -> Void {
        
        guard let notificationId = ref.child("notifications").childByAutoId().key else {
            throw NotificationServiceError.dbFailedToGenerateId
        }
        
        let usernameRef = ref.child("usernames").child(toUserName)
        let snapshot = try await usernameRef.getData()
        
        guard let toUserId = snapshot.value as? String else {
            throw NotificationServiceError.failedToFetchUserId
        }
        
        let notificationType: NotificationType = .friendRequest
        let friendRequest: FriendRequest = FriendRequest(fromUserId: userId, toUserId: toUserId, status: "pending", senderName: username, senderProfileImage: profileImage)
        let payload: NotificationPayload = .friendRequest(friendRequest)
        let creationDate = Date().timeIntervalSince1970
        
        let notificationObj = Notification(id: notificationId, type: notificationType, notificationPayload: payload, creationDate: creationDate)
        
        do {
            let encodedData = try JSONEncoder().encode(notificationObj)
            
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any] else {
                throw NotificationServiceError.failedToSerializeFriendRequest
            }
            
            let updates: [String : Any] = [
                "notifications/\(toUserId)/\(notificationId)": jsonDictionary,
                "friendRequests/\(userId)/\(toUserId)": "pending",
            ]
            
            try await ref.updateChildValues(updates)
        } catch {
            throw NotificationServiceError.failedToSendFriendRequest
        }
    }
    
    func handleEventInviteResponse(notificationId: String, senderScheduleId: String, eventId: String, senderId: String, toUserId: String, userScheduleId: String, responseStatus: Bool) async throws -> Void {
        
        if responseStatus {
            
            let queryRequest: [String: Any] = [
                "/eventInvites/\(senderId)/\(toUserId)": NSNull(),
                "/notifications/\(toUserId)/\(notificationId)": NSNull(),
                "/schedules/\(userScheduleId)/eventIds/\(eventId)": true,
                "/scheduleEvents/\(userScheduleId)/\(eventId)": true,
                "/events/\(eventId)/taggedUsers/\(toUserId)": true,
            ]
            
            do {
                try await ref.updateChildValues(queryRequest)
            } catch {
                throw FirebaseError.failedToUpdateFriendRequest
            }
        } else {
            
            let queryRequest: [String: Any] = [
                "/eventInvites/\(senderId)/\(toUserId)": NSNull(),
                "/notifications/\(toUserId)/\(notificationId)": NSNull(),
            ]
            
            do {
                try await ref.updateChildValues(queryRequest)
            } catch {
                throw FirebaseError.failedToUpdateFriendRequest
            }
        }
    }
    
    func handleFriendRequestResponse(notificationId: String, senderId: String, toUserId: String, responseStatus: Bool) async throws -> Void {
                
        if responseStatus {
            
            let queryRequest: [String: Any] = [
                "/friendRequests/\(senderId)/\(toUserId)": NSNull(),
                "/notifications/\(toUserId)/\(notificationId)": NSNull(),
                "/users/\(toUserId)/friends/\(senderId)": true,
                "/users/\(senderId)/friends/\(toUserId)": true,
            ]
            
            do {
                try await ref.updateChildValues(queryRequest)
            } catch {
                throw FirebaseError.failedToUpdateFriendRequest
            }
        } else {
            
            let queryRequest: [String: Any] = [
                "/friendRequests/\(senderId)/\(toUserId)": NSNull(),
                "/notifications/\(toUserId)/\(notificationId)": NSNull(),
            ]
            
            do {
                try await ref.updateChildValues(queryRequest)
            } catch {
                throw FirebaseError.failedToUpdateFriendRequest
            }
        }
    }
    
    func observeUserNotifications(userId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        let notificationRef = ref.child("notifications").child(userId)
        
        let handle = notificationRef.observe(.childAdded) { snapshot in
            let dict = snapshot.value as? [String: Any] ?? [:]
            
            guard let notificationId = dict["id"] as? String else { return }
            
            print(notificationId)
            
            completion(notificationId)
        }
        
        return handle
    }
        
    func removeUserNotificationObserver(handle: DatabaseHandle, userId: String) {
        let notificationRef = ref.child("notifications").child(userId)
        notificationRef.removeObserver(withHandle: handle)
    }
}
