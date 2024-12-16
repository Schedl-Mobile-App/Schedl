//
//  FeedViewModel.swift
//  calendarTest
//
//  Created by David Medina on 12/9/24.
//

import SwiftUI
import Firebase

class FeedViewModel: ObservableObject {
    
    @Published var showPopUp = false
    @Published var posts: [Post]?              // holds the fetched post
    @Published var isLoading: Bool = false      // indicates loading state
    @Published var errorMessage: String?        // holds error messages if any
    
    @MainActor
    func fetchFeed(userId: String) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
<<<<<<< Updated upstream
                let fetchedPosts = try await FirebaseManager.shared.fetchFriendsPosts(id: userId)
                self.posts = fetchedPosts
                self.isLoading = false
                
            } catch {
                self.errorMessage = "Failed to fetch friends posts: \(error.localizedDescription)"
=======
                let posts = try await FirebaseManager.shared.fetchFriendsPosts(id: userId)
                self.posts = posts
                self.isLoading = false
                
            } catch {
                self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
>>>>>>> Stashed changes
                self.isLoading = false
            }
        }
    }
}
