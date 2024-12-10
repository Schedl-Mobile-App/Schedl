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
}
