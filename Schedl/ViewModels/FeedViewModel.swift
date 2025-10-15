//
//  FeedViewModel.swift
//  calendarTest
//
//  Created by David Medina on 12/9/24.
//

import SwiftUI

class FeedViewModel: ObservableObject {
    
    var currentUser: User
    
    @Published var posts: [Post]?               // holds the fetched post
    
    @Published var isLoading: Bool = false      // indicates loading state
    @Published var errorMessage: String?        // holds error messages if any
    
    private var postsService: PostService
    
    init(postsService: PostService = PostService.shared, currentUser: User) {
        self.postsService = postsService
        self.currentUser = currentUser
    }
}
