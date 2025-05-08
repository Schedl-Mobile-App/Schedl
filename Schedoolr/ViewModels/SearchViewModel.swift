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
    @Published var searchResults: [User] = []
    private var searchService: SearchServiceProtocol
    private var userService: UserServiceProtocol
    
    var searchTask: Task<Void, Never>?
        
    @ObservationIgnored var searchTextSubject = CurrentValueSubject<String, Never>("")
    @ObservationIgnored var cancellables: Set<AnyCancellable> = []
    
    @MainActor
    init(searchService: SearchServiceProtocol = SearchService.shared, userService: UserServiceProtocol = UserService.shared, currentUser: User) {
        self.searchService = searchService
        self.userService = userService
        self.currentUser = currentUser
        
        searchTextSubject
            .filter { $0.isEmpty }
            .sink { [weak self] _ in
                guard let self else { return }
                self.searchTask?.cancel()
                self.searchResults.removeAll()
                self.errorMessage = nil
                self.isLoading = false
            }.store(in: &cancellables)
            
        
        searchTextSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sink { [weak self] text in
                guard let self else { return }
                self.searchTask?.cancel()
                self.searchTask = createSearchTask(text)
            }
            .store(in: &cancellables)
    }
    
    var searchText = "" {
        didSet {
            searchTextSubject.send(searchText)
        }
    }
    
    var isSearchNotFound: Bool {
        let isDataEmpty = self.searchResults.isEmpty
        return isDataEmpty && searchText.count > 0
    }
    
    @MainActor
    func createSearchTask(_ text: String) -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            self.errorMessage = nil
            do {
                let matchedUserIds = try await searchService.fetchUserSearchInfo(username: text)
                let searchData = try await self.userService.fetchUsers(userIds: matchedUserIds)
                try Task.checkCancellation()
                self.searchResults = searchData
                self.isLoading = false
            } catch {
                if error is CancellationError {
                    print("Search is cancelled")
                    searchResults.removeAll()
                    self.isLoading = false
                } else {
                    self.errorMessage = "Oops, there are no users with that username."
                    self.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func fetchSearchResults(userName: String) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let matchedUserIds = try await searchService.fetchUserSearchInfo(username: userName)
                self.searchResults = try await userService.fetchUsers(userIds: matchedUserIds)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                print("Failed to find any matching users: \(error.localizedDescription)")
            }
        }
    }
}
