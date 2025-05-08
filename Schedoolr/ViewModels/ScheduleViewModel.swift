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
    var friendsSchedules: [Schedule] = []
    var selectedEvent: Event?
    @Published var scheduleEvents: [Event] = []
    @Published var showCreateEvent = false
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var activeSidebar = false
    @Published var scheduleListener: DatabaseHandle?
    @Published var partionedEvents: [Double : [Event]]?
    var scheduleService: ScheduleServiceProtocol
    var eventService: EventServiceProtocol
    
    init(currentUser: User, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared) {
        self.scheduleService = scheduleService
        self.currentUser = currentUser
        self.eventService = eventService
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
            setupScheduleListener(scheduleId: scheduleId)
            
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
    func createEvent(title: String, eventDate: Double, startTime: Double, endTime: Double) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id as? String else { return }
            let newEvent = try await eventService.createEvent(scheduleId: scheduleId, userId: currentUser.id, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime)
            self.scheduleEvents.append(newEvent)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchEvents() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let scheduleId = userSchedule?.id as? String else { return }
            let fetchedEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
            self.scheduleEvents = fetchedEvents
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch events: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func updateEvent(title: String, eventDate: Double, startTime: Double, endTime: Double) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let event = selectedEvent else { return }
            try await eventService.updateEvent(eventId: event.id, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime)
            
            let newEvent = Event(id: event.id, scheduleId: event.scheduleId, title: title, eventDate: eventDate, startTime: startTime, endTime: endTime, creationDate: event.creationDate)
            if let index = scheduleEvents.firstIndex(where: { $0.id == newEvent.id }) {
              scheduleEvents[index] = newEvent
            }
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to update event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func deleteEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let eventId = selectedEvent?.id as? String else { return }
            guard let scheduleId = userSchedule?.id as? String else { return }
            try await eventService.deleteEvent(eventId: eventId, scheduleId: scheduleId)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func setupScheduleListener(scheduleId: String) {
        removeScheduleListener(scheduleId: scheduleId)
        scheduleListener = scheduleService.observeScheduleChanges(scheduleId: scheduleId) { [weak self] eventIds in
            Task { @MainActor in
                do {
                    if let updatedEvents = try await self?.eventService.fetchEvents(eventIds: eventIds) {
                        self?.scheduleEvents = updatedEvents
                    }
                } catch {
                    self?.errorMessage = "Failed to fetch events: \(error.localizedDescription)"
                }
            }
        }
    }
    
    @MainActor
    func removeScheduleListener(scheduleId: String) {
        if let handle = scheduleListener {
            scheduleService.removeScheduleObserver(handle: handle, scheduleId: scheduleId)
            scheduleListener = nil
        }
    }
}

