//
//  FeedViewModel.swift
//  calendarTest
//
//  Created by David Medina on 12/9/24.
//

import SwiftUI
import Firebase

class FeedViewModel: ObservableObject {
    
    @Published var currentUser: User
    @Published var showPopUp = false
    @Published var posts: [Post]?               // holds the fetched post
    @Published var isLoading: Bool = false      // indicates loading state
    @Published var errorMessage: String?        // holds error messages if any
    private var feedListener: DatabaseHandle?
    private var postsService: PostService
    
    init(postsService: PostService = PostService.shared, currentUser: User) {
        self.postsService = postsService
        self.currentUser = currentUser
    }
    
//    @MainActor
//    func fetchFeed() {
//        Task {
//            self.isLoading = true
//            self.errorMessage = nil
//            do {
//                let fetchedPosts = try await FirebaseManager.shared.fetchFriendsPosts(id: currentUser.id)
//                self.setupFeedListener()
//                self.posts = fetchedPosts
//                self.isLoading = false
//                
//            } catch {
//                self.errorMessage = "Failed to fetch friends posts: \(error.localizedDescription)"
//                self.isLoading = false
//            }
//        }
//    }
//    
//    @MainActor
//    func setupFeedListener() {
//        removeFeedListener()
//        feedListener = FirebaseManager.shared.observeFeedChanges(userId: currentUser.id) { [weak self] posts in
//            DispatchQueue.main.async {
//                self?.posts = posts
//            }
//        }
//    }
//    
//    @MainActor
//    func removeFeedListener() {
//        if let handle = feedListener {
//            FirebaseManager.shared.removeFeedObserver(handle: handle, userId: currentUser.id)
//            feedListener = nil
//        }
//    }
}
