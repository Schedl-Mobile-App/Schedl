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
    @Published var friendRequests: [FriendRequest] = []
    @Published var showPopUp = false
    @Published var isLoading: Bool = false      // indicates loading state
    @Published var errorMessage: String?        // holds error messages if any
    private var userService: UserServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    init(userService: UserServiceProtocol = UserService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared, currentUser: User) {
        self.userService = userService
        self.notificationService = notificationService
        self.currentUser = currentUser
    }
    
    @MainActor
    func handleFriendRequestResponse(requestId: String, accepted: Bool) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await notificationService.handleFriendRequestResponse(requestId: requestId, accepted: accepted)
            
            if let index = self.friendRequests.firstIndex(where: { $0.id == requestId }) {
                friendRequests.remove(at: index)
            }
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to handle friend request response: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchFriendRequests() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let requests = try await notificationService.fetchFriendRequests(userId: currentUser.id)
            self.friendRequests = requests
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch incoming friend requests: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
