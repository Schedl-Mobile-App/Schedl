//
//  ScheduleViewModel.swift
//  calendarTest
//
//  Created by David Medina on 10/16/24.
//

import SwiftUI
import Firebase

class ScheduleViewModel: ScheduleViewModelProtocol, ObservableObject {
    
    var currentUser: User
    @Published var userSchedule: Schedule?
    @Published var invitedUsersForEvent: [User] = []
    var friends: [User] = []
    @Published var scheduleEvents: [RecurringEvents] = []
    @Published var showCreateEvent = false
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var activeSidebar = false
    @Published var partionedEvents: [Double : [Event]]?
    @Published var shouldReloadData = true
    private var addedEventsHandler: DatabaseHandle?
    private var removedEventsHandler: DatabaseHandle?
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var userService: UserServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    init(currentUser: User, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, userService: UserServiceProtocol = UserService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.scheduleService = scheduleService
        self.currentUser = currentUser
        self.eventService = eventService
        self.userService = userService
        self.notificationService = notificationService
    }
    
    func shouldShowCreateEvent() {
        showCreateEvent.toggle()
    }
    
    func shouldShowSidebar() {
        activeSidebar.toggle()
    }
    
    func parseRecurringEvents(event: Event) -> [RecurringEvents] {
        
        let originalEventInstance: RecurringEvents = RecurringEvents(date: event.startDate, event: event)
        
        // if there are no repeatedDays or endDate for this event, we simply return the single instance
        guard let repeatedDays = event.repeatingDays else { return [originalEventInstance] }
        guard let endDate = event.endDate else { return [originalEventInstance] }

        let iterationStart = Date(timeIntervalSince1970: event.startDate)
        let iterationEnd = Date(timeIntervalSince1970: endDate)

        var repeatedEvents: [RecurringEvents] = []
        var cursor = iterationStart
        
        while cursor <= iterationEnd {
            // find the iterator's current weekday index
            let weekIndex = Calendar.current.component(.weekday, from: cursor) - 1
            
            // next, we need to find a way to check whether our event instance includes the same weekday index
            if repeatedDays.contains(String(weekIndex)) {
                repeatedEvents.append(RecurringEvents(date: cursor.timeIntervalSince1970, event: event))
            }
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = next
        }

        return repeatedEvents
    }
    
    // Use of MainActor ensures that updates to the Published variables occur on the main thread
    @MainActor
    func fetchSchedule() async {
        self.errorMessage = nil
        self.isLoading = true
        do {
            let fetchedSchedule = try await scheduleService.fetchSchedule(userId: currentUser.id)
            self.userSchedule = fetchedSchedule
            
            let scheduleId = fetchedSchedule.id
            
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            
            // now that we've fetched all events in DB, we need to check if any events are recurring meaning they'll have repeats in the future
            // note that even singular events will be stored in this array of type RecurringEvents since there isn't a need
            // to separate these from regular Event objects
            var formattedEvents: [RecurringEvents] = []
            for event in allEvents {
                formattedEvents.append(contentsOf: parseRecurringEvents(event: event))
            }
            
//            let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            
            self.scheduleEvents = formattedEvents.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                
                // if the event start dates are different, then we sort by their date
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                
                // if they occur on the same day, then we sort by their start time
                return $0.event.startTime < $1.event.startTime
            }
            
            observeScheduleChanges()
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createSchedule(title: String) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let newSchedule = try await scheduleService.createSchedule(userId: currentUser.id, title: title)
            self.userSchedule = newSchedule
            
            observeScheduleChanges()
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func updateSchedule() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let schedule = userSchedule else { return }
            try await scheduleService.updateSchedule(scheduleId: schedule.id, title: schedule.title)
        } catch {
            self.errorMessage = "Failed to update schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
//    @MainActor
//    func deleteSchedule() async {
//        self.isLoading = true
//        self.errorMessage = nil
//        do {
//            guard let scheduleId = userSchedule?.id as? String else { return }
//            try await eventService.deleteScheduleEvents(scheduleId: scheduleId)
//            try await scheduleService.deleteSchedule(scheduleId: scheduleId, userId: currentUser.id)
//        } catch {
//            self.errorMessage = "Failed to delete schedule: \(error.localizedDescription)"
//            self.isLoading = false
//        }
//    }
    
    @MainActor
    func fetchEvents() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id as? String else {
                return
            }
            
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            
            // now that we've fetched all events in DB, we need to check if any events are recurring meaning they'll have repeats in the future
            // note that even singular events will be stored in this array of type RecurringEvents since there isn't a need
            // to separate these from regular Event objects
            var formattedEvents: [RecurringEvents] = []
            for event in allEvents {
                formattedEvents.append(contentsOf: parseRecurringEvents(event: event))
            }
            
//            let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            
            self.scheduleEvents = formattedEvents.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                
                // if the event start dates are different, then we sort by their date
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                
                // if they occur on the same day, then we sort by their start time
                return $0.event.startTime < $1.event.startTime
            }
            
            self.isLoading = false
            
        } catch {
            self.errorMessage = "Failed to fetch events: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createEvent(title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, invitedUsers: [User], endDate: Double? = nil, repeatedDays: [String]? = nil) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id else { return }
            
            let userIds = invitedUsers.compactMap { $0.id }
                                    
            let eventId = try await eventService.createEvent(scheduleId: scheduleId, userId: currentUser.id, title: title, startDate: startDate, startTime: startTime, endTime: endTime, location: location, color: color, notes: notes, endDate: endDate, repeatedDays: repeatedDays)
            
            try await notificationService.sendEventInvites(senderId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUserIds: userIds, eventId: eventId)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchFriends() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.friends = try await userService.fetchUserFriends(userId: currentUser.id)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func observeScheduleChanges() {
        
        guard let scheduleId = userSchedule?.id else { return }
        removeScheduleObservers()
        
        addedEventsHandler = scheduleService.observeAddedEvents(scheduleId: scheduleId) { [weak self] eventId in
            guard let self = self else {
                return
            }
            if self.scheduleEvents.contains(where: { $0.event.id == eventId }) {
                return
            } else {
                Task { @MainActor in
                    do {
                        let newlyAddedEvent = try await self.eventService.fetchEvent(eventId: eventId)
                        let modifiedEvent = self.parseRecurringEvents(event: newlyAddedEvent)
                        self.scheduleEvents.append(contentsOf: modifiedEvent)
                    } catch {
                        self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
                    }
                }
            }
        }
        
        removedEventsHandler = scheduleService.observeRemovedEvents(scheduleId: scheduleId) { [weak self] eventId in
            guard let self = self else { return }
            
            print("Removed event id is: \(eventId)")
            print("Schedule Events before removal is: \(scheduleEvents.compactMap({$0.id}))")
            
            guard let removedEventIndex = self.scheduleEvents.firstIndex(where: { $0.event.id == eventId }) else { return }
            self.scheduleEvents.remove(at: removedEventIndex)
            
            print("Schedule Events after removal is: \(scheduleEvents)")
        }
    }
    
    func removeScheduleObservers() {
        guard let scheduleId = userSchedule?.id else { return }
        
        if let addHandler = addedEventsHandler {
            scheduleService.removeScheduleObserver(handle: addHandler, scheduleId: scheduleId)
            addedEventsHandler = nil
        }
        
        if let removeHandler = removedEventsHandler {
            scheduleService.removeScheduleObserver(handle: removeHandler, scheduleId: scheduleId)
            removedEventsHandler = nil
        }
    }
    
    deinit {
        removeScheduleObservers()
    }
}

