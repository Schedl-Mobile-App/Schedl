//
//  EventViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 5/27/25.
//

import Foundation

class EventViewModel: EventViewModelProtocol, ObservableObject {
    var currentUser: User
    var selectedEvent: Event
    var invitedUsersForEvent: [User] = []
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    
    init(currentUser: User, selectedEvent: Event, userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared) {
        self.currentUser = currentUser
        self.selectedEvent = selectedEvent
        self.userService = userService
        self.eventService = eventService
        self.scheduleService = scheduleService
    }
    
//    @MainActor
//    func updateEvent(title: String, eventDate: Double, startTime: Double, endTime: Double) async {
//        self.isLoading = true
//        self.errorMessage = nil
//        do {
//            guard let event = selectedEvent else { return }
//            try await eventService.updateEvent(eventId: event.id, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime)
//
//            let newEvent = Event(id: event.id, scheduleId: event.scheduleId, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime, creationDate: event.creationDate)
//            if let index = scheduleEvents.firstIndex(where: { $0.id == newEvent.id }) {
//              scheduleEvents[index] = newEvent
//            }
//
//            self.isLoading = false
//        } catch {
//            self.errorMessage = "Failed to update event: \(error.localizedDescription)"
//            self.isLoading = false
//        }
//    }
        
    @MainActor
    func deleteEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await eventService.deleteEvent(eventId: selectedEvent.id, scheduleId: selectedEvent.scheduleId)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchInvitedUsers() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.invitedUsersForEvent = try await userService.fetchUsers(userIds: selectedEvent.taggedUsers)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch invited users: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
