//
//  AccountViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 1/14/25.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var friends: [User]?
    @Published var isCurrentUser: Bool = true
    @Published var profileUser: User?
    @Published var profileUserId: String?
    @Published var posts: [Post]?
    @Published var schedules: Schedule?
    @Published var taggedPosts: [Post]?
    @Published var likedPosts: [Post]?
    @Published var selectedTab: Tab = .schedules
    
    init(userid: String) {
        self.profileUserId = userid
        Task {
            @MainActor in
            await loadViewModel(userid: userid)
        }
    }
    
//    func fetchSomeFriends() async {
//        self.isLoading = true
//        self.errorMessage = nil
//        
//        do {
//            self.friends = try await FirebaseManager.shared.fetchSomeFriends(id: self.profileUserId ?? "")
//            self.isLoading = false
//        } catch {
//            self.errorMessage = error.localizedDescription
//            self.isLoading = false
//        }
//    }
    
    func numOfFriends() -> Int {
        return self.profileUser?.friendIds.count ?? 0
    }
    
    @MainActor
    func loadViewModel(userid: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            self.profileUser = try await FirebaseManager.shared.fetchUserAsync(id: self.profileUserId ?? "")
            await self.fetchTabInfo()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchTabInfo() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            switch self.selectedTab {
            case .schedules:
                let schedule = try await FirebaseManager.shared.fetchScheduleAsync(id: profileUser?.schedules.first ?? "")
                self.schedules = schedule
                self.isLoading = false
                break
            case .posts:
                let posts = try await FirebaseManager.shared.fetchUserPosts(id: profileUser?.id ?? "")
                self.posts = posts
                self.isLoading = false
                break
            case .tagged:
                let taggedPosts = try await FirebaseManager.shared.fetchUserPosts(id: profileUser?.id ?? "")
                self.taggedPosts = taggedPosts
                self.isLoading = false
                break
            case .likes:
                let likedPosts = try await FirebaseManager.shared.fetchUserPosts(id: profileUser?.id ?? "")
                self.likedPosts = likedPosts
                self.isLoading = false
                break
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    func checkIfCurrentUser(user: User) {
        self.isCurrentUser = user.id == (profileUserId ?? "") ? true : false
    }
    
    @MainActor
    func sendFriendRequest(toUserName: String, fromUserObj: User) async {
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
