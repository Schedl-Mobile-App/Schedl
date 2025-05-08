//
//  AccountViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 1/14/25.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject, ProfileViewModelProtocol {
    @Published var currentUser: User
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var friends: [User]?
    @Published var posts: [Post]?
    @Published var schedules: Schedule?
    @Published var partitionedEvents: [Double : [Event]] = [:]
    @Published var taggedPosts: [Post]?
    @Published var likedPosts: [Post]?
    @Published var selectedTab: Tab = .schedules
    @State var triggerSaveChanges = false
    @Published var isEditingProfile: Bool = false
    var selectedImage: UIImage? = nil
    var profileUserId: String
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    // only needs to be read-only since we will be creating new instances of the view model whether the current user is on their profile
    // or visiting their friends profile
    var isCurrentUser: Bool {
        currentUser.id == profileUserId
    }
    
    init(userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared, currentUser: User, profileUserId: String){
        self.userService = userService
        self.scheduleService = scheduleService
        self.eventService = eventService
        self.notificationService = notificationService
        self.currentUser = currentUser
        self.profileUserId = profileUserId
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
    
//    func numOfFriends() -> Int {
//        return self.profileUser?.friendIds.count ?? 0
//    }
    
//    @MainActor
//    func loadViewModel() async {
//        self.isLoading = true
//        self.errorMessage = nil
//        
//        do {
//            try await userService.fetchUser(userid: currentUser.id)
//            await self.fetchTabInfo()
//            self.isLoading = false
//        } catch {
//            self.errorMessage = error.localizedDescription
//            self.isLoading = false
//        }
//    }
    
//    @MainActor
//    func fetchTabInfo() async {
//        self.isLoading = true
//        self.errorMessage = nil
//        
//        do {
//            switch self.selectedTab {
//            case .schedules:
//                let schedule = try await FirebaseManager.shared.fetchScheduleAsync(id: profileUser?.schedules.first ?? "")
//                self.schedules = schedule
//                self.isLoading = false
//                break
//            case .posts:
//                let posts = try await FirebaseManager.shared.fetchUserPosts(id: profileUser?.id ?? "")
//                self.posts = posts
//                self.isLoading = false
//                break
//            case .tagged:
//                let taggedPosts = try await FirebaseManager.shared.fetchUserPosts(id: profileUser?.id ?? "")
//                self.taggedPosts = taggedPosts
//                self.isLoading = false
//                break
//            case .likes:
//                let likedPosts = try await FirebaseManager.shared.fetchUserPosts(id: profileUser?.id ?? "")
//                self.likedPosts = likedPosts
//                self.isLoading = false
//                break
//            }
//        } catch {
//            self.errorMessage = error.localizedDescription
//            self.isLoading = false
//        }
//    }
    
    @MainActor
    func sendFriendRequest(toUserName: String) async -> Void {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await notificationService.sendFriendRequest(userId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUserName: toUserName)
            self.isLoading = false
        } catch {
            print("Friend request was not successfully sent")
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func partionEventsByDay(scheduleId: String) async -> Void {
        self.isLoading = true
        self.errorMessage = nil
        let currentDay = Date.convertCurrentDateToTimeInterval(date: Date())
        do {
            let currentEvents = try await eventService.fetchCurrentEvents(currentDay: currentDay, userId: currentUser.id)
            self.partitionedEvents = Dictionary(
                grouping: currentEvents,
                by: \.eventDate
            )
            print(self.partitionedEvents)
            self.isLoading = false
        } catch {
            print("Could not partion events by day successfully")
            self.errorMessage = "Failed to partion events by day successfully. The following error occured: \(error.localizedDescription)"
            self.isLoading = false
        }

    }
    
    @MainActor
    func updateUserProfile() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await userService.updateProfileInfo(userId: currentUser.id, username: currentUser.username, profileImage: selectedImage, email: currentUser.email)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to update user's profile iamge. The following error occured: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchFriends() {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let friends = try await userService.fetchUserFriends(userId: currentUser.id)
                self.friends = friends
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
}
