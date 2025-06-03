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
    @Published var friendsInfoDict: [String : SearchInfo] = [:]
    @Published var selectedTab: Tab = .schedules
    @Published var showSaveChangesModal = false
    @Published var showAddFriendModal = false
    @Published var isEditingProfile: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var numberOfFriends: Int = 0
    private var currentDay = Date.convertCurrentDateToTimeInterval(date: Date())
    var profileUser: User
    var isViewingFriend: Bool = false
    @Published var isShowingFriendRequest: Bool = false
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
    func loadViewData() async {
        self.isLoading = true
        self.errorMessage = nil
        await fetchTabInfo()
        await fetchEvents()
        await fetchFriends()
        self.isLoading = false
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
    func sendFriendRequest() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await notificationService.sendFriendRequest(userId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUserName: profileUser.username)
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
        do {
            let scheduleId = try await scheduleService.fetchScheduleId(userId: profileUser.id)
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            self.userEvents = allEvents.sorted { $0.eventDate > $1.eventDate }
            self.pastEvents = allEvents.filter { $0.eventDate < currentDay }.sorted { $0.eventDate > $1.eventDate }
            self.invitedEvents = allEvents
            self.currentEvents = allEvents.filter{ $0.eventDate >= currentDay }.sorted { $0.eventDate < $1.eventDate }
            let rawGroups = Dictionary(
                grouping: currentEvents,
                by: \.eventDate,
            )
            self.partitionedEvents = rawGroups.mapValues { eventsInDay in
                eventsInDay.sorted { $0.startTime < $1.startTime }
            }
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
    func fetchNumberOfFriends() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.numberOfFriends = try await userService.fetchNumberOfFriends(userId: profileUser.id)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchFriends() async {
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
    
    @MainActor
    func checkFriendStatus() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.isViewingFriend = try await userService.isFriend(userId: currentUser.id, otherUserId: profileUser.id)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchUserPosts() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.userPosts = try await postService.fetchPostsByUserId(userId: profileUser.id)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch posts"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchFriendsInfo(userId: String) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let friendsIds = try await userService.fetchFriendIds(userId: userId)
            let friendsData = try await userService.fetchUsers(userIds: friendsIds)
            for user in friendsData {
                let numOfFriends = try await userService.fetchNumberOfFriends(userId: user.id)
                let numOfPosts: Int
                do {
                    numOfPosts = try await postService.fetchNumOfPosts(userId: user.id)
                } catch PostServiceError.failedToReturnNumberOfPosts {
                    numOfPosts = 0
                }
                self.friendsInfoDict[user.id] = SearchInfo(
                    numOfFriends: numOfFriends,
                    numOfPosts: numOfPosts,
                    isFriend: true
                )
            }
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            print("Failed to find any matching users: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
}
