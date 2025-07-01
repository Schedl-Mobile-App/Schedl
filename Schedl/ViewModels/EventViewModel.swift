//
//  EventViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 5/27/25.
//

import Foundation

class EventViewModel: EventViewModelProtocol, ObservableObject {
    var currentUser: User
    var selectedEvent: RecurringEvents
    var invitedUsersForEvent: [User] = []
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var hasLoadedPreviousPage = true
    @Published var eventCreatorName: String = ""
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    
    init(currentUser: User, selectedEvent: RecurringEvents, userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared) {
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
            try await eventService.deleteEvent(eventId: selectedEvent.event.id, scheduleId: selectedEvent.event.scheduleId, userId: selectedEvent.event.userId)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchEventData() async {
        self.isLoading = false
        self.errorMessage = nil
        do {
            if selectedEvent.event.userId != currentUser.id {
                self.eventCreatorName = try await userService.fetchDisplayNameById(userId: selectedEvent.event.userId)
            } else {
                self.eventCreatorName = currentUser.displayName
            }
            self.invitedUsersForEvent = try await userService.fetchUsers(userIds: selectedEvent.event.taggedUsers)
        } catch {
            self.errorMessage = "Failed to fetch event data: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
