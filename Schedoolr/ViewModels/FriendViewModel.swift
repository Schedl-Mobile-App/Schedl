//
//  FriendViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 1/10/25.
//

import SwiftUI
import Firebase

class FriendViewModel: ObservableObject {
    
    @Published var showPopUp = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var friends: [String]?
    
    @MainActor
    func sendFriendRequest(toUserName: String, fromUserObj: User) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                try await FirebaseManager.shared.handleFriendRequest(fromUserObj: fromUserObj, toUserName: toUserName)
                self.isLoading = false
            } catch {
                print("Friend request was not successfully sent")
                self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func fetchFriends(friendIds: [String]) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let friends = try await FirebaseManager.shared.fetchUserFriends(friendIds: friendIds)
                self.friends = friends
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
