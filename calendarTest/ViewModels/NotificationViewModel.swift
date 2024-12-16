//
//  NotificationViewModel.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI
import Firebase

class NotificationViewModel: ObservableObject {
    
    @Published var showPopUp = false
<<<<<<< Updated upstream
    @Published var isLoading: Bool = false      // indicates loading state
    @Published var errorMessage: String?        // holds error messages if any
    @Published var incomingFriendRequests: [FriendRequests]?
=======
    @Published var posts: [Post]?              // holds the fetched post
    @Published var isLoading: Bool = false      // indicates loading state
    @Published var errorMessage: String?        // holds error messages if any
>>>>>>> Stashed changes
    
    @MainActor
    func sendFriendRequest(toUserName: String, fromUserObj: User) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                try await FirebaseManager.shared.handleFriendRequest(fromUserObj: fromUserObj, toUserName: toUserName)
                self.isLoading = false
<<<<<<< Updated upstream
            } catch {
                print("Friend request was not successfully sent")
=======
                
            } catch {
>>>>>>> Stashed changes
                self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
<<<<<<< Updated upstream
    
    @MainActor
    func handleFriendRequestResponse(requestId: String, response: Bool) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                try await FirebaseManager.shared.handleFriendRequestResponse(requestId: requestId, response: response)
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to handle friend request response: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func showFriendRequests(requestIds: [String]) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let requests = try await FirebaseManager.shared.fetchIncomingFriendRequests(requestIds: requestIds)
                self.incomingFriendRequests = requests
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch incoming friend requests: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
=======
>>>>>>> Stashed changes
}
