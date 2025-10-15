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
    
    @Published var allEvents: [EventOccurrence] = []
    @Published var pastEvents: [EventOccurrence] = []
    @Published var invitedEvents: [EventOccurrence] = []
    @Published var currentEvents: [EventOccurrence] = []
    
    @Published var partitionedEvents: [Date : [EventOccurrence]] = [:]
    @Published var profileViewType: ProfileTab = .events
    @Published var profileEventViewType: ProfileEventType = .upcoming
    
    @Published var selectedImage: UIImage? = nil
    
    @Published var showAddFriendAlert = false
    
    var tabOptions: [ProfileTab] = [.schedules, .events, .activity]
    var friendRequestPending = false
    
    @Published var shouldReloadData: Bool = true
    
    var showProfileDetails: Bool {
        isCurrentUser || isViewingFriend
    }
    
    var hasLoaded = false
    
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
        if let index = tabOptions.firstIndex(of: profileViewType) {
            return index
        }
        return 0
    }
    
    func getEventViewTypeIndex() -> Int {
        let index = ProfileEventType.allCases.firstIndex(of: profileEventViewType) ?? 0
        return index
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
        guard !hasLoaded else { return }
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
        
        hasLoaded = true
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
            switch self.profileViewType {
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
    
    func parseRecurringEvents(for event: Event) -> [EventOccurrence] {        
        guard let rule = event.recurrence, let endDate = rule.endDate else {
            return [EventOccurrence(recurringDate: event.startDate, event: event)]
        }
                
        var occurrences: [EventOccurrence] = []
        var cursorDate = event.startDate
        
        while cursorDate <= endDate {
            let weekday = Calendar.current.component(.weekday, from: cursorDate)
            
            if let repeatingDays = rule.repeatingDays, repeatingDays.contains(weekday) {
                occurrences.append(EventOccurrence(recurringDate: cursorDate, event: event))
            }
            
            // Safely advance to the next day.
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: cursorDate) else { break }
            cursorDate = nextDay
        }
        
        return occurrences
    }
    
    @MainActor
    func fetchEvents() async {
        do {
            guard let schedule = self.currentSchedule else { return }
            
            let rawEvents = try await eventService.fetchEventsByScheduleId(scheduleId: schedule.id)
            
            var allOccurrences: [EventOccurrence] = []
            for event in rawEvents {
                allOccurrences.append(contentsOf: parseRecurringEvents(for: event))
            }
            
            let sorter: (EventOccurrence, EventOccurrence) -> Bool = { o1, o2 in
                let dayComparison = Calendar.current.compare(o1.recurringDate, to: o2.recurringDate, toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return o1.event.startTime < o2.event.startTime
            }
            
            allOccurrences.sort(by: sorter)
            
            let today = Calendar.current.startOfDay(for: Date())
            self.allEvents = allOccurrences
            self.currentEvents = allOccurrences.filter { $0.recurringDate >= today }
            self.pastEvents = allOccurrences.filter { $0.recurringDate < today }.reversed()
            self.invitedEvents = allOccurrences.filter { $0.event.ownerId != self.profileUser.id }
            
            let rawGroups = Dictionary(grouping: self.currentEvents) { event in
                return Calendar.current.startOfDay(for: event.recurringDate)
            }
            self.partitionedEvents = rawGroups
            
        } catch {
            self.errorMessage = "Failed to fetch events. Please try again."
        }
    }
    
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
    
    deinit {
        print("Being cleaned up")
    }
}

