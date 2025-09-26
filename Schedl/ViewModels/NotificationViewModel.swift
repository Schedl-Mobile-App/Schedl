//
//  NotificationViewModel.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI
import Firebase

class NotificationViewModel: ObservableObject {
    
    var currentUser: User
    @Published var notifications: [Notification] = []
//    @Published var parsedNotifications: [Date: [Notification]] = [:]
    @Published var friendRequests: [FriendRequest] = []
    @Published var showPopUp = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var userService: UserServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var notificationObserver: DatabaseHandle?
    
    init(userService: UserServiceProtocol = UserService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, currentUser: User) {
        self.userService = userService
        self.eventService = eventService
        self.notificationService = notificationService
        self.scheduleService = scheduleService
        self.currentUser = currentUser
    }
    
    @MainActor
    func handleNotificationResponse(id: String, responseStatus: Bool) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
//            guard let notifications = parsedNotifications[date] else { return }
//            guard let notificationObj = notifications.first(where: { $0.id == id }) else { return }
            
            guard let notification = notifications.first(where: {$0.id == id }) else { return }
            
            switch notification.notificationPayload {
            case .friendRequest(let friendRequest):
                try await notificationService.handleFriendRequestResponse(notificationId: id, senderId: friendRequest.fromUserId, toUserId: currentUser.id, responseStatus: responseStatus)
                break
            case .eventInvite(let eventInvite):
                let scheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
                try await notificationService.handleEventInviteResponse(notificationId: id, senderId: eventInvite.fromUserId, eventId: eventInvite.eventId, userId: currentUser.id, scheduleId: scheduleId, responseStatus: responseStatus)
                break
            case .blendInvite(let blendInvite):
                let scheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
                try await notificationService.handleBlendInviteResponse(notificationId: id, senderId: blendInvite.fromUserId, blendId: blendInvite.blendId, userId: blendInvite.toUserId, scheduleId: scheduleId, responseStatus: responseStatus)
            case .unknown:
                return
            }
                        
//            notifications.removeAll(where: { $0.id == id })
            deleteNotification(id: id)
            
            self.isLoading = false
        } catch {
            print("Failed to handle notification: \(error.localizedDescription)")
            self.errorMessage = "Failed to handle notification: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchNotifications() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let notificationData = try await notificationService.fetchAllNotifications(userId: currentUser.id)
            self.notifications = notificationData.sorted(by: { $0.createdAt > $1.createdAt })
//            self.parsedNotifications = Dictionary(grouping: notificationData) { notification in
//                return Calendar.current.startOfDay(for: notification.createdAt)
//            }
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch user notifications. Received Server Error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func deleteNotification(id: String) {
//        if let dateKey = self.parsedNotifications.first(where: { (_, value) in
//            value.contains(where: { $0.id == id })
//        })?.key {
//            if let index = self.parsedNotifications[dateKey]?.firstIndex(where: { $0.id == id }) {
//                self.parsedNotifications[dateKey]?.remove(at: index)
//                if self.parsedNotifications[dateKey]?.isEmpty == true {
//                    self.parsedNotifications.removeValue(forKey: dateKey)
//                }
//            }
//        }
        notifications.removeAll(where: {$0.id == id })
    }
}

