//
//  NotificationViewModel.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI
import Firebase

class NotificationViewModel: NotificationViewModelProtocol, ObservableObject {
    
    var currentUser: User
    @Published var notifications: [Notification] = []
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
            guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
            let notificationObj = notifications[index]
            
            switch notificationObj.notificationPayload {
            case .friendRequest(let friendRequest):
                try await notificationService.handleFriendRequestResponse(notificationId: id, senderId: friendRequest.fromUserId, toUserId: currentUser.id, responseStatus: responseStatus)
            case .eventInvite(let eventInvite):
                let senderScheduleId = try await scheduleService.fetchScheduleId(userId: eventInvite.fromUserId)
                let toScheduleId = try await scheduleService.fetchScheduleId(userId: eventInvite.toUserId)
                
                try await notificationService.handleEventInviteResponse(notificationId: id, senderScheduleId: senderScheduleId, eventId: eventInvite.invitedEventId, senderId: eventInvite.fromUserId, toUserId: currentUser.id, userScheduleId: toScheduleId, responseStatus: responseStatus, startDate: eventInvite.eventDate, startTime: eventInvite.startTime, endTime: eventInvite.endTime)
            case .blend(let blendInvite):
                let toScheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
                try await notificationService.handleBlendInviteResponse(notificationId: id, blendId: blendInvite.blendId, senderId: blendInvite.fromUserId, userId: blendInvite.toUserId, scheduleId: toScheduleId, responseStatus: responseStatus)
            }
            
            if let index = self.notifications.firstIndex(where: { $0.id == id }) {
                notifications.remove(at: index)
            }
            
            self.isLoading = false
        } catch {
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
            self.notifications = notificationData.sorted { $0.creationDate > $1.creationDate }
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch user notifications. Received Server Error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func setupNotificationObserver() {
        removeNotificationObserver()
        notificationObserver = notificationService.observeUserNotifications(userId: currentUser.id) { [weak self] (notificationId: String) in
            guard let self = self else { return }
            
            Task { @MainActor in
                do {
                    guard let newNotification = try await self.notificationService.fetchNotificationById(notificationId: notificationId, userId: self.currentUser.id) else { return }
                    
                    self.notifications.append(newNotification)
                    
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to fetch user notifications."
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func removeNotificationObserver() {
        guard let handle = self.notificationObserver else { return }
        notificationService.removeUserNotificationObserver(handle: handle, userId: currentUser.id)
        
        notificationObserver = nil
    }
}
