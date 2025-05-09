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
    @Published var userSchedule: Schedule?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var friends: [User] = []
    @Published var userPosts: [Post] = []
    @Published var userEvents: [Event] = []
    @Published var pastEvents: [Event] = []
    @Published var invitedEvents: [Event] = []
    @Published var currentEvents: [Event] = []
    @Published var partitionedEvents: [Double : [Event]] = [:]
    @Published var selectedTab: Tab = .schedules
    @Published var triggerSaveChanges = false
    @Published var isEditingProfile: Bool = false
    @Published var selectedImage: UIImage? = nil
    var profileUser: User
    var tabOptions: [Tab] = [.schedules, .events, .activity]
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    private var postService: PostServiceProtocol
    
    // only needs to be read-only since we will be creating new instances of the view model whether the current user is on their profile
    // or visiting their friends profile
    var isCurrentUser: Bool {
        currentUser.id == profileUser.id
    }
    
    init(userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared, postService: PostServiceProtocol = PostService.shared, currentUser: User, profileUser: User){
        self.userService = userService
        self.scheduleService = scheduleService
        self.eventService = eventService
        self.notificationService = notificationService
        self.postService = postService
        self.currentUser = currentUser
        self.profileUser = profileUser
    }
    
    func returnSelectedOptionIndex() -> Int {
        if let index = tabOptions.firstIndex(of: selectedTab) {
            return index
        }
        return 0
    }
    
    @MainActor
    func fetchTabInfo() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            switch self.selectedTab {
            case .schedules:
                await fetchEvents()
                self.isLoading = false
                break
            case .events:
                await fetchEvents()
                self.isLoading = false
                break
            case .activity:
                let fetchedPosts = try await postService.fetchPostsByUserId(userId: profileUser.id)
                userPosts = fetchedPosts
                self.isLoading = false
                break
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    @MainActor
    func sendFriendRequest(toUserName: String) async {
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
    func fetchEvents() async {
        self.isLoading = true
        self.errorMessage = nil
        let currentDay = Date.convertCurrentDateToTimeInterval(date: Date())
        do {
            let scheduleId = try await scheduleService.fetchScheduleId(userId: profileUser.id)
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            userEvents = allEvents
            pastEvents = allEvents.filter { $0.eventDate < currentDay }
            invitedEvents = allEvents
            let currentEvents = allEvents.filter { $0.eventDate >= currentDay }
            self.currentEvents = currentEvents
            self.partitionedEvents = Dictionary(
                grouping: currentEvents,
                by: \.eventDate
            )
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
    func fetchFriends() async {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let friends = try await userService.fetchUserFriends(userId: profileUser.id)
                self.friends = friends
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func fetchUserPosts() {
        
    }
    
}
