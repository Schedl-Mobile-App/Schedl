//
//  AccountViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 1/14/25.
//

import SwiftUI
import Firebase

class ProfileViewModel: ObservableObject, Hashable, Equatable {
    
    let id = UUID()
    static func == (lhs: ProfileViewModel, rhs: ProfileViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var currentUser: User
    var profileUser: User
    var isViewingFriend: Bool = false
    var isCurrentUser: Bool {
        currentUser.id == profileUser.id
    }
    
    var schedules: [Schedule] = []
    @Published var currentSchedule: Schedule?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var posts: [Post] = []
    
    @Published var allEvents: [RecurringEvents] = []
    @Published var pastEvents: [RecurringEvents] = []
    @Published var invitedEvents: [RecurringEvents] = []
    @Published var currentEvents: [RecurringEvents] = []
    
    @Published var partitionedEvents: [Double : [RecurringEvents]] = [:]
    @Published var selectedTab: ProfileTab = .schedules
    
    @Published var selectedImage: UIImage? = nil
    
    @Published var showAddFriendAlert = false
    
    var tabOptions: [ProfileTab] = [.schedules, .events, .activity]
    var friendRequestPending = false
    
    @Published var shouldReloadData: Bool = true
    
    var showProfileDetails: Bool {
        isCurrentUser || isViewingFriend
    }
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    private var postService: PostServiceProtocol
    private var searchService: SearchServiceProtocol
    
    
    init(userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared, postService: PostServiceProtocol = PostService.shared, searchService: SearchServiceProtocol = SearchService.shared, currentUser: User, profileUser: User){
        self.userService = userService
        self.scheduleService = scheduleService
        self.eventService = eventService
        self.notificationService = notificationService
        self.postService = postService
        self.searchService = searchService
        self.currentUser = currentUser
        self.profileUser = profileUser
    }
    
    func returnSelectedOptionIndex() -> Int {
        if let index = tabOptions.firstIndex(of: selectedTab) {
            return index
        }
        return 0
    }
    
    func getFirstName() -> String {
        guard profileUser.displayName.isEmpty == false else {
            return "Imposter"
        }
        let splitName = profileUser.displayName.split(separator: " ")
        if let firstName = splitName.first {
            return String(firstName)
        }
        
        return "Imposter"
    }
    
    @MainActor
    func updateProfileImage() async {
        guard isCurrentUser == true, let newImage = selectedImage else {
            return
        }
        
        self.errorMessage = nil
        
        do {
            let imageURL = try await userService.updateProfileImage(newImage: newImage, userId: currentUser.id)
            currentUser.profileImage = imageURL.absoluteString
            profileUser = currentUser
            selectedImage = nil
            
        } catch {
            self.errorMessage = "Something went wrong. Please try again."
        }
    }
    
    @MainActor
    func loadProfileData() async {
        self.isLoading = true
        
        self.errorMessage = nil
        
        // verify whether the current user is viewing a profile that is their friend or not
        await checkIfFriend()
        
        // we should only continue to fetch schedule data if the access is valid
        // data is protected by the server regardless, so only the owning user and friends can retrieve schedule data
        guard isCurrentUser || isViewingFriend else {
            do {
                self.friendRequestPending = try await userService.friendRequestPending(fromUserId: currentUser.id, toUserId: profileUser.id)
            } catch {
                self.errorMessage = "Something went wrong. Please try again"
            }
            return
        }
        
        await fetchSchedules()
        await fetchEvents()
        await fetchTabInfo()
        
        self.isLoading = false
    }
    
    @MainActor
    func fetchSchedules() async {
        do {
            self.schedules = try await scheduleService.fetchAllSchedules(userId: profileUser.id)
            guard schedules.isEmpty == false else { return }
            
            self.currentSchedule = schedules.first!
            
        } catch {
            self.errorMessage = "Failed to fetch schedule(s). Please try again."
        }
    }
    
    @MainActor
    func changeSchedule(id: String) async {
        if let schedule = schedules.first(where: { $0.id == id }),
           schedule.id != currentSchedule?.id {
            self.currentSchedule = schedule
        } else {
            self.errorMessage = "Something went wrong when changing schedules. Please try again."
        }
    }
        
    @MainActor
    func fetchTabInfo() async {
        
        let scheduleAlreadyFetched: Bool = partitionedEvents.isEmpty == false
        var eventsAlreadyFetched: Bool {
            allEvents.isEmpty == false &&
            pastEvents.isEmpty == false &&
            invitedEvents.isEmpty == false &&
            currentEvents.isEmpty == false
        }
        let postsAlreadyFetched: Bool = posts.isEmpty == false
        
        do {
            switch self.selectedTab {
            case .schedules:
                if !scheduleAlreadyFetched {
                    await fetchEvents()
                }
            case .events:
                if !eventsAlreadyFetched {
                    await fetchEvents()
                }
            case .activity:
                if !postsAlreadyFetched {
                    self.posts = try await postService.fetchPostsByUserId(userId: profileUser.id)
                }
            }
        } catch {
            self.errorMessage = "Something went wrong. Please try again."
        }
    }
    
    @MainActor
    func sendFriendRequest() async {
        self.errorMessage = nil
        do {
            guard currentUser.id != profileUser.id else { return }
            try await notificationService.createFriendRequest(fromUserId: currentUser.id, senderName: currentUser.displayName, senderProfileImage: currentUser.profileImage, toUserId: profileUser.id)
            friendRequestPending = true
        } catch {
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
        }
    }
    
    func parseRecurringEvents(event: Event) -> [RecurringEvents] {
        let calendar = Calendar.current
        guard let repeatedDays: Set<Int> = event.repeatingDays, !repeatedDays.isEmpty, let endDate = event.endDate else {
            return [RecurringEvents(date: event.startDate, event: event)]
        }
        var generatedEvents: [RecurringEvents] = []
        var cursor = Date(timeIntervalSince1970: event.startDate)
        let finalDate = Date(timeIntervalSince1970: endDate)
        while cursor <= finalDate {
            let weekIndex = calendar.component(.weekday, from: cursor) - 1
            if repeatedDays.contains(weekIndex) {
                let cursorTimeInterval = cursor.timeIntervalSince1970
                let eventForThisDay = event
                generatedEvents.append(RecurringEvents(date: cursorTimeInterval, event: eventForThisDay))
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = nextDay
        }
        return generatedEvents
    }

    private func createEventInstance(from baseEvent: Event, with exception: EventException) -> Event {
        return Event(
            id: baseEvent.id,
            ownerId: baseEvent.ownerId,
            title: exception.title ?? baseEvent.title,
            startDate: baseEvent.startDate,
            startTime: exception.startTime ?? baseEvent.startTime,
            endTime: exception.endTime ?? baseEvent.endTime,
            locationName: exception.locationName ?? baseEvent.location.name,
            locationAddress: exception.locationAddress ?? baseEvent.location.address,
            latitude: exception.latitude ?? baseEvent.location.latitude,
            longitude: exception.longitude ?? baseEvent.location.longitude,
            invitedUsers: baseEvent.invitedUsers,
            color: exception.color ?? baseEvent.color,
            notes: exception.notes ?? baseEvent.notes
        )
    }
    
    @MainActor
    func fetchEvents() async {
        do {
            guard let schedule = self.currentSchedule else { return }
            
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: schedule.id)
            
            var formattedEvents: [RecurringEvents] = []
            for event in allEvents {
                formattedEvents.append(contentsOf: parseRecurringEvents(event: event))
            }
            
            let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            
            self.allEvents = formattedEvents.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return $0.event.startTime < $1.event.startTime
            }
            
            self.pastEvents = formattedEvents.filter { $0.date < currentDay }.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedDescending
                }
                return $0.event.startTime < $1.event.startTime
            }
            self.invitedEvents = formattedEvents.filter { $0.event.ownerId != self.profileUser.id }.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return $0.event.startTime < $1.event.startTime
            }
            self.currentEvents = formattedEvents.filter{ $0.date >= currentDay }.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return $0.event.startTime < $1.event.startTime
            }
            let rawGroups = Dictionary(
                grouping: currentEvents,
                by: \.date
            )
            self.partitionedEvents = rawGroups.mapValues { recurringEvent in
                recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
            }
        } catch {
            self.errorMessage = "Failed to fetch events. Please try again."
        }
    }
    
    // used within the sheet view that can be presented from the profile view to edit profile info
    @MainActor
    func updateUserProfile() async {
        self.errorMessage = nil
        do {
            try await userService.updateProfileInfo(userId: currentUser.id, username: currentUser.username, profileImage: selectedImage, email: currentUser.email)
        } catch {
            self.errorMessage = "Failed to update profile. Please try again."
        }
    }
    
    @MainActor
    func checkIfFriend() async {
        
        guard isCurrentUser == false else { return }
        
        self.errorMessage = nil
        
        do {
            self.isViewingFriend = try await userService.isFriend(userId: currentUser.id, otherUserId: profileUser.id)
        } catch {
            self.errorMessage = "Something went wrong. Please try again later."
        }
    }
    
    @MainActor
    func fetchUserPosts() async {
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            self.posts = try await postService.fetchPostsByUserId(userId: profileUser.id)
            self.isLoading = false
        } catch {
            self.errorMessage = "Something went wrong while fetching posts. Please try again later."
            self.isLoading = false
        }
    }
}

