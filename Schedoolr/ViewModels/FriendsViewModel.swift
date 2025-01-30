//
//  FriendsViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 1/17/25.
//

import Foundation
import Firebase

class FriendsViewModel: ObservableObject {
    
    @Published var friends: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
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
