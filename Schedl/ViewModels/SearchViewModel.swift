//
//  FriendViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 1/10/25.
//

import SwiftUI
import Firebase
import Combine
import Foundation
import Observation

class SearchViewModel: ObservableObject {
    
    var currentUser: User
    @Published var showPopUp = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchResults: [SearchInfo]? = nil
    
    @Published var matchedUsers: [String] = []
    
    private var searchService: SearchServiceProtocol
    private var userService: UserServiceProtocol
    private var postService: PostServiceProtocol
    
    @Published var searchText: String = ""
    
    @Published var selectedUser: User?
    
    var searchTask: Task<Void, Never>?
        
    @ObservationIgnored var cancellables: Set<AnyCancellable> = []
    
    @MainActor
    init(searchService: SearchServiceProtocol = SearchService.shared, userService: UserServiceProtocol = UserService.shared, postService: PostServiceProtocol = PostService.shared, currentUser: User) {
        self.searchService = searchService
        self.userService = userService
        self.postService = postService
        self.currentUser = currentUser
    }
    
    func debounceSearch() {
        // Cancel any ongoing search task
        searchTask?.cancel()
        // Start a new debounced task
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // clear results
            searchResults = nil
            return
        }
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000) // 300ms
            await self?.performSearch()
        }
    }

    @MainActor
    private func performSearch() async {
        // perform your search logic here
        isLoading = true
        errorMessage = nil
        do {
            searchResults = try await searchService.fetchUserSearchInfo(currentUserId: currentUser.id, username: searchText)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func debounceEventSearch() {
        // Cancel any ongoing search task
        searchTask?.cancel()
        // Start a new debounced task
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // clear results
            searchResults = nil
            return
        }
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000) // 300ms
            await self?.performEventSearch()
        }
    }

    @MainActor
    private func performEventSearch() async {
        // perform your search logic here
        isLoading = true
        errorMessage = nil
        do {
            matchedUsers = try await searchService.fetchMatchingUsers(username: searchText)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    
}
