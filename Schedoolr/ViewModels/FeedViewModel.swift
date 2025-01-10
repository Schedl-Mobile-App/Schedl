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
    private var feedListener: DatabaseHandle?
    
    @MainActor
    func fetchFeed(userId: String) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let fetchedPosts = try await FirebaseManager.shared.fetchFriendsPosts(id: userId)
                self.setupFeedListener(userId: userId)
                self.posts = fetchedPosts
                self.isLoading = false
                
            } catch {
                self.errorMessage = "Failed to fetch friends posts: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func setupFeedListener(userId: String) {
        removeFeedListener()
        feedListener = FirebaseManager.shared.observeFeedChanges(userId: userId) { [weak self] posts in
            DispatchQueue.main.async {
                self?.posts = posts
            }
        }
    }
    
    @MainActor
    func removeFeedListener() {
        if let handle = feedListener {
            FirebaseManager.shared.removeUserObserver(handle: handle)
            feedListener = nil
        }
    }
}
