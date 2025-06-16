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
    @Published var scheduleEvents: [Event] = []
    @Published var showCreateEvent = false
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var activeSidebar = false
    @Published var partionedEvents: [Double : [Event]]?
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
    
    // Use of MainActor ensures that updates to the Published variables occur on the main thread
    @MainActor
    func fetchSchedule() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let fetchedSchedule = try await scheduleService.fetchSchedule(userId: currentUser.id)
            self.userSchedule = fetchedSchedule
            
            let scheduleId = fetchedSchedule.id
            
            let fetchedEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            self.scheduleEvents = fetchedEvents

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
    
    @MainActor
    func deleteSchedule() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id as? String else { return }
            try await eventService.deleteScheduleEvents(scheduleId: scheduleId)
            try await scheduleService.deleteSchedule(scheduleId: scheduleId, userId: currentUser.id)
        } catch {
            self.errorMessage = "Failed to delete schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchEvents() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id as? String else {
                self.isLoading = false
                return
            }
            let fetchedEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            self.scheduleEvents = fetchedEvents
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch events: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createEvent(title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, endDate: Double? = nil, repeatedDays: [String]? = nil) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id else { return }
            
            let taggedUsers: [String] = self.invitedUsersForEvent.compactMap { $0.id }
            
            let eventId = try await eventService.createEvent(scheduleId: scheduleId, userId: currentUser.id, title: title, startDate: startDate, startTime: startTime, endTime: endTime, location: location, color: color, notes: notes, endDate: endDate, repeatedDays: repeatedDays)
            
            try await notificationService.sendEventInvites(senderId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUserIds: taggedUsers, eventId: eventId)
            
            self.isLoading = false
        } catch {
            print("Failed to create event: \(error.localizedDescription)")
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
        
        removeScheduleObservers(scheduleId: scheduleId)
        
        addedEventsHandler = scheduleService.observeAddedEvents(scheduleId: scheduleId) { [weak self] eventId in
            guard let self = self else { return }
            
            Task { @MainActor in
                do {
                    let newlyAddedEvent = try await self.eventService.fetchEvent(eventId: eventId)
                    self.scheduleEvents.append(newlyAddedEvent)
                } catch {
                    self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
                }
            }
        }
        
        removedEventsHandler = scheduleService.observeRemovedEvents(scheduleId: scheduleId) { [weak self] eventId in
            guard let self = self else { return }
            
            guard let removedEventIndex = self.scheduleEvents.firstIndex(where: { $0.id == eventId }) else { return }
            self.scheduleEvents.remove(at: removedEventIndex)
        }
    }
    
    @MainActor
    func removeScheduleObservers(scheduleId: String) {
        if let addHandler = addedEventsHandler {
            scheduleService.removeScheduleObserver(handle: addHandler, scheduleId: scheduleId)
            addedEventsHandler = nil
        }
        
        if let removeHandler = removedEventsHandler {
            scheduleService.removeScheduleObserver(handle: removeHandler, scheduleId: scheduleId)
            addedEventsHandler = nil
        }
    }
}

