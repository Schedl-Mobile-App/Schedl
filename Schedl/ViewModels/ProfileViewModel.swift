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
    @Published var isLoadingProfileView: Bool = false
    @Published var isLoadingFriendView = false
    @Published var errorMessage: String?
    @Published var friends: [User] = []
    @Published var userPosts: [Post] = []
    @Published var userEvents: [RecurringEvents] = []
    @Published var pastEvents: [RecurringEvents] = []
    @Published var invitedEvents: [RecurringEvents] = []
    @Published var currentEvents: [RecurringEvents] = []
    @Published var partitionedEvents: [Double : [RecurringEvents]] = [:]
    @Published var friendsInfoDict: [String : SearchInfo] = [:]
    @Published var selectedTab: Tab = .schedules
    @Published var showSaveChangesModal = false
    @Published var showAddFriendModal = false
    @Published var isEditingProfile: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var numberOfFriends: Int = 0
    @Published var cachedProfileImage: UIImage?
    @Published var showLogoutModal = false
    
    @Published var selectedEvent: RecurringEvents?
    
    var profileUser: User
    @Published var isViewingFriend: Bool = false
    @Published var isShowingFriendRequest: Bool = false
    var tabOptions: [Tab] = [.schedules, .events, .activity]
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    private var postService: PostServiceProtocol
    private var searchService: SearchServiceProtocol
    
    @Published var shouldReloadData: Bool = true
    @Published var path = NavigationPath()
    
//    private var url: URL {
//        return URL(string: currentUser.profileImage)!
//    }
    
//    private let url = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
//    private let session = URLSession(configuration: .default)
//    
//    func downloadImage(for pokemon: Pokemon) async throws {
//        guard let index = self.pokemon.firstIndex(where: { $0.id == pokemon.id }),
//              self.pokemon[index].imageDataURL == nil
//        else { return }
//        let (data, _) = try await session.data(from: pokemon.imageURL)
//        let dataURL = URL(string: "data:image/png;base64," + data.base64EncodedString())
//        self.pokemon[index].imageDataURL = dataURL
//    }
    
    // only needs to be read-only since we will be creating new instances of the view model whether the current user is on their profile
    // or visiting their friends profile
    var isCurrentUser: Bool
    init(userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared, postService: PostServiceProtocol = PostService.shared, searchService: SearchServiceProtocol = SearchService.shared, currentUser: User, profileUser: User){
        self.userService = userService
        self.scheduleService = scheduleService
        self.eventService = eventService
        self.notificationService = notificationService
        self.postService = postService
        self.searchService = searchService
        self.currentUser = currentUser
        self.profileUser = profileUser
        self.isCurrentUser = currentUser.id == profileUser.id
    }
    
    func resetPath() {
        path = NavigationPath()
    }
    
    func returnSelectedOptionIndex() -> Int {
        if let index = tabOptions.firstIndex(of: selectedTab) {
            return index
        }
        return 0
    }
    
    @MainActor
    func loadProfileData() async {
        self.isLoadingProfileView = true
        
        self.errorMessage = nil
        
        async let friends: () = fetchFriends()
        async let events: () = fetchEvents()
        async let profileImage: () = loadProfileImageIfNeeded()
        _ = await (friends, events, profileImage)
        
        await fetchTabInfo()
        
        self.isLoadingProfileView = false
    }
    
    @MainActor
    func loadFriendsData() async {
        self.isLoadingFriendView = true
        self.errorMessage = nil
        
        await fetchFriends()
        await fetchFriendsInfo()
        
        self.isLoadingFriendView = false
    }
    
    @MainActor
    func loadProfileImageIfNeeded() async {
        guard cachedProfileImage == nil else { return }
        let urlString = profileUser.profileImage
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                self.cachedProfileImage = image
            }
        } catch {
            // Optionally handle image download errors
        }
    }
    
    @MainActor
    func fetchTabInfo() async {
        self.errorMessage = nil
        
        let scheduleAlreadyFetched: Bool = partitionedEvents.isEmpty == false
        var eventsAlreadyFetched: Bool {
            userEvents.isEmpty == false &&
            pastEvents.isEmpty == false &&
            invitedEvents.isEmpty == false &&
            currentEvents.isEmpty == false
        }
        let postsAlreadyFetched: Bool = userPosts.isEmpty == false
        
        do {
            switch self.selectedTab {
            case .schedules:
                if !scheduleAlreadyFetched {
                    await fetchEvents()
                }
                break
            case .events:
                if !eventsAlreadyFetched {
                    await fetchEvents()
                }
                break
            case .activity:
                if !postsAlreadyFetched {
                    let fetchedPosts = try await postService.fetchPostsByUserId(userId: profileUser.id)
                    userPosts = fetchedPosts
                }
                break
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func sendFriendRequest() async {
        self.errorMessage = nil
        do {
            try await notificationService.sendFriendRequest(userId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUsername: profileUser.username)
        } catch {
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
        }
    }
    
    func parseRecurringEvents(event: Event) -> [RecurringEvents] {
        
        // 1. For clarity and efficiency, create a single Calendar instance.
        let calendar = Calendar.current
        
        // 2. Handle non-recurring events with an early exit.
        //    We also change repeatingDays to a Set<Int> for performance and type safety.
        guard let repeatedDays: Set<Int> = event.repeatingDays, !repeatedDays.isEmpty, let endDate = event.endDate else {
            return [RecurringEvents(date: event.startDate, event: event)]
        }

        // 3. (PERFORMANCE) Create a dictionary for exceptions for O(1) lookups.
        //    This is the most significant performance improvement.
        let exceptionsByDate = Dictionary(uniqueKeysWithValues: event.exceptions.map { ($0.date, $0) })
        
        // 4. Set up loop variables.
        var generatedEvents: [RecurringEvents] = []
        var cursor = Date(timeIntervalSince1970: event.startDate)
        let finalDate = Date(timeIntervalSince1970: endDate)

        // 5. Loop through each day in the range.
        while cursor <= finalDate {
            let weekIndex = calendar.component(.weekday, from: cursor) - 1 // Assumes Sunday = 1, so result is 0-6.
            
            // 6. (DRY) First, check if the current day is a day the event should occur on.
            if repeatedDays.contains(weekIndex) {
                let cursorTimeInterval = cursor.timeIntervalSince1970
                var eventForThisDay = event // Default to the original event.
                
                // 7. (OPTIMIZED) Now, check for an exception using our fast dictionary lookup.
                if let exception = exceptionsByDate[cursorTimeInterval] {
                    // If an exception exists, create a new modified event instance for this occurrence.
                    // A helper function makes this much cleaner.
                    eventForThisDay = createEventInstance(from: event, with: exception)
                }
                
                generatedEvents.append(RecurringEvents(date: cursorTimeInterval, event: eventForThisDay))
            }
            
            // 8. (DRY) Advance the cursor to the next day. This is now only written once.
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = nextDay
        }

        return generatedEvents
    }


    /// A helper function to create a modified event instance based on an exception.
    /// This makes the main parsing function cleaner and easier to read.
    private func createEventInstance(from baseEvent: Event, with exception: EventException) -> Event {
        return Event(
            id: baseEvent.id,
            userId: baseEvent.userId,
            scheduleId: baseEvent.scheduleId,
            title: exception.title ?? baseEvent.title,
            startDate: baseEvent.startDate, // The series start date remains the same
            startTime: exception.startTime ?? baseEvent.startTime,
            endTime: exception.endTime ?? baseEvent.endTime,
            creationDate: baseEvent.creationDate,
            locationName: exception.locationName ?? baseEvent.locationName,
            locationAddress: exception.locationAddress ?? baseEvent.locationAddress,
            latitude: exception.latitude ?? baseEvent.latitude,
            longitude: exception.longitude ?? baseEvent.longitude,
            taggedUsers: baseEvent.taggedUsers,
            color: exception.color ?? baseEvent.color,
            notes: exception.notes ?? baseEvent.notes,
            // The original exceptions list is carried over for context if needed
            exceptions: baseEvent.exceptions
        )
    }
    
//    func parseRecurringEvents(event: Event) -> [RecurringEvents] {
//        
//        let originalEventInstance: RecurringEvents = RecurringEvents(date: event.startDate, event: event)
//        
//        // if there are no repeatedDays or endDate for this event, we simply return the single instance
//        guard let repeatedDays = event.repeatingDays else { return [originalEventInstance] }
//        guard let endDate = event.endDate else { return [originalEventInstance] }
//
//        let iterationStart = Date(timeIntervalSince1970: event.startDate)
//        let iterationEnd = Date(timeIntervalSince1970: endDate)
//
//        var repeatedEvents: [RecurringEvents] = []
//        var cursor = iterationStart
//        
//        while cursor <= iterationEnd {
//            // find the iterator's current weekday index
//            let weekIndex = Calendar.current.component(.weekday, from: cursor) - 1
//            
//            // next, we need to find a way to check whether our event instance includes the same weekday index
//            if repeatedDays.contains(String(weekIndex)) {
//                repeatedEvents.append(RecurringEvents(date: cursor.timeIntervalSince1970, event: event))
//            }
//            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: cursor) else { break }
//                cursor = next
//        }
//
//        return repeatedEvents
//    }
    
    @MainActor
    func fetchEvents() async {
        self.errorMessage = nil
        do {
            let scheduleId = try await scheduleService.fetchScheduleId(userId: profileUser.id)
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            
            // now that we've fetched all events in DB, we need to check if any events are recurring meaning they'll have repeats in the future
            // note that even singular events will be stored in this array of type RecurringEvents since there isn't a need
            // to separate these from regular Event objects
            var formattedEvents: [RecurringEvents] = []
            for event in allEvents {
                formattedEvents.append(contentsOf: parseRecurringEvents(event: event))
            }
            
            let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            
            self.userEvents = formattedEvents.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                
                // if the event start dates are different, then we sort by their date
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                
                // if they occur on the same day, then we sort by their start time
                return $0.event.startTime < $1.event.startTime
            }
            
            self.pastEvents = formattedEvents.filter { $0.date < currentDay }.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                
                // if the event start dates are different, then we sort by their date
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedDescending
                }
                
                // if they occur on the same day, then we sort by their start time
                return $0.event.startTime < $1.event.startTime
            }
            self.invitedEvents = formattedEvents.filter { $0.event.userId != self.profileUser.id }.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                
                // if the event start dates are different, then we sort by their date
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                
                // if they occur on the same day, then we sort by their start time
                return $0.event.startTime < $1.event.startTime
            }
            self.currentEvents = formattedEvents.filter{ $0.date >= currentDay }.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                
                // if the event start dates are different, then we sort by their date
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                
                // if they occur on the same day, then we sort by their start time
                return $0.event.startTime < $1.event.startTime
            }
            let rawGroups = Dictionary(
                grouping: currentEvents,
                by: \.date,
            )
            self.partitionedEvents = rawGroups.mapValues { recurringEvent in
                recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
            }
        } catch {
            self.errorMessage = "Failed to fetch events. The following error occured: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func updateUserProfile() async {
        self.errorMessage = nil
        do {
            try await userService.updateProfileInfo(userId: currentUser.id, username: currentUser.username, profileImage: selectedImage, email: currentUser.email)
        } catch {
            self.errorMessage = "Failed to update user's profile iamge. The following error occured: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func fetchFriends() async {
        self.errorMessage = nil
        do {
            let friends = try await userService.fetchUserFriends(userId: profileUser.id)
            self.friends = friends
            self.numberOfFriends = friends.count
            if friends.contains(where: { $0.id == currentUser.id }) && profileUser.id != currentUser.id {
                self.isViewingFriend = true
            } else {
                self.isViewingFriend = false
            }
        } catch {
            self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func fetchUserPosts() async {
        self.errorMessage = nil
        do {
            self.userPosts = try await postService.fetchPostsByUserId(userId: profileUser.id)
        } catch {
            self.errorMessage = "Failed to fetch posts"
        }
    }
    
    @MainActor
    func fetchFriendsInfo() async {
        do {
            let friendsInfo = try await searchService.fetchFriendsSearchInfo(friendIds: self.friends.map(\.id))
            // ensures that we have unique number of friend ids that we fetched since
            // Dictionary(uniqueKeysWithValues:) will cause a runtime error if there are duplicates
            if Set(friendsInfo.map(\.user.id)).count == friendsInfo.count {
                self.friendsInfoDict = Dictionary(uniqueKeysWithValues: friendsInfo.map { ($0.user.id, $0) })
            }
        } catch {
            self.errorMessage = "Failed to fetch any friends!"
        }
    }
}

