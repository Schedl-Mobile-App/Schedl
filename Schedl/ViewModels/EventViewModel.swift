//
//  EventViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 5/27/25.
//

import Foundation
import SwiftUI

struct FriendAvailability: Codable {
    let available: Bool
    let userId: String
}

class EventViewModel: ObservableObject, Equatable, Hashable {
    
    let id = UUID()
    static func == (lhs: EventViewModel, rhs: EventViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var currentUser: User
    var event: EventOccurrence?
    var eventId: String?
    
    @Published var schedules: [Schedule] = []
    @Published var selectedSchedule: Schedule?
    
    @Published var showSaveChangesModal = false
    @Published var showDeleteEventModal = false
    
    // Binding variables for picker views
    @Published var title: String? = nil
    @Published var startDate: Date? = nil
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    @Published var selectedPlacemark: MTPlacemark? = nil
    @Published var notes: String? = nil
    @Published var eventColor: Color? = nil
    @Published var selectedFriends: [User] = []
    @Published var recurrence: RecurrenceRule? = nil
        
    // Error strings for invalid inputs
    @Published var titleError: String = ""
    @Published var startDateError: String = ""
    @Published var recurrenceError: String = ""
    @Published var startTimeError: String = ""
    @Published var endTimeError: String = ""
    @Published var locationError: String = ""
    @Published var notesError: String = ""
    @Published var submitError: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var eventCreatorName: String = ""
    
    @Published var invitedUserIds: [InvitedUser] = []
    @Published var hasTriedSubmitting = false
    
    func resetErrors() {
        titleError = ""
        startDateError = ""
        recurrenceError = ""
        startTimeError = ""
        endTimeError = ""
        locationError = ""
        notesError = ""
        submitError = ""
        hasTriedSubmitting = false
    }
    
    var shouldShowEditRecurringModal: Bool {
        // if there's not a recurrence rule stored on the event, then no need to show modal
        return event?.event.recurrence != nil
    }
    
    var hasEventInfoChanged: Bool {
        guard let event = event?.event else { return false }
        
        guard let title, let startDate, let startTime, let endTime, let selectedPlacemark else { return false }
        
        let startTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let endTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        
        let startTimeAsInt = (startTimeComponents.hour ?? 0) * 60 + (startTimeComponents.minute ?? 0)
        let endTimeAsInt = (endTimeComponents.hour ?? 0) * 60 + (endTimeComponents.minute ?? 0)
        
        return event.title != title || event.startTime != startTimeAsInt || event.endTime != endTimeAsInt || event.location != selectedPlacemark || event.notes != notes || event.recurrence != recurrence
    }
    
    var isRecurringEvent: Bool {
        return event?.event.recurrence != nil
    }
    
    var userCanEdit: Bool {
        guard let event else { return false }
        return event.event.ownerId == currentUser.id
    }
    
    var selectedColor: String {
        if let color = eventColor {
            return color.toHex()!
        }
        // default Schedl teal color of the event if a user doesn't select one
        return "3C859E"
    }
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    init(currentUser: User, event: EventOccurrence? = nil, eventId: String? = nil, currentScheduleId: String? = nil, userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.currentUser = currentUser
        self.userService = userService
        self.eventService = eventService
        self.scheduleService = scheduleService
        self.notificationService = notificationService
        if let event = event {
            self.event = event
            setInitialValues()
        }
        self.eventId = eventId
    }
    
    @MainActor
    func deleteEvent() async {
        guard let event = event else {
            return
        }
        
        do {
            try await eventService.deleteEvent(eventId: event.event.id)            
        } catch {
            self.errorMessage = "Failed to delete event."
        }
    }
    
    @MainActor
    func updateRecurringEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            if !checkValidInputs() {
                return
            }
            
            guard let event = event else { return }
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to update event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func updateAllFutureRecurringEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            if !checkValidInputs() {
                return
            }
            
            guard let event = event else {
                return }
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to update event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func updateEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            if !checkValidInputs() { return }
            guard let event = event else { return }
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to update event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createEvent() async {
        guard let schedule = selectedSchedule else { return }
        if !checkValidInputs() { return }
        
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let title, let startDate, let startTime, let endTime, let selectedPlacemark else { return }
            
            let startTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
            let endTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
            
            let startTimeAsInt = (startTimeComponents.hour ?? 0) * 60 + (startTimeComponents.minute ?? 0)
            let endTimeAsInt = (endTimeComponents.hour ?? 0) * 60 + (endTimeComponents.minute ?? 0)
            
            let userIds = selectedFriends.compactMap { InvitedUser(userId: $0.id) }
            
            try await eventService.createEvent(userId: currentUser.id, title: title, startDate: startDate, startTime: startTimeAsInt, endTime: endTimeAsInt, location: selectedPlacemark, color: selectedColor, recurrence: recurrence, notes: notes, invitedUsers: userIds, scheduleId: schedule.id)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchSchedules() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let schedules = try await scheduleService.fetchAllSchedules(userId: currentUser.id)
            self.schedules = schedules
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
        
    @MainActor
    func deleteAllRecurringEvents() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let event = event else { return }
            try await eventService.deleteEvent(eventId: event.event.id)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchEventData() async {
        guard let event = event, let invitedUsers = event.event.invitedUsers else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.selectedFriends = try await userService.fetchUsers(friendIds: invitedUsers.map(\.userId))
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch event data: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            guard let eventId = self.eventId else { return }
            let event = try await eventService.fetchEvent(eventId: eventId)
            
            self.event = EventOccurrence(recurringDate: event.startDate, event: event)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch event. Please try again."
            self.isLoading = false
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
    
    func checkValidInputs() -> Bool {
        titleError = ""
        startDateError = ""
        recurrenceError = ""
        startTimeError = ""
        endTimeError = ""
        locationError = ""
        
        var isValid = true
                
        if title == nil || title?.isEmpty == true {
            titleError = "Title is required"
            isValid = false
        }
        if startDate == nil {
            startDateError = "Start date is required"
            isValid = false
        }
        if startTime == nil {
            startTimeError = "Start time is required"
            isValid = false
        }
        if endTime == nil {
            endTimeError = "End time is required"
            isValid = false
        }
        if selectedPlacemark == nil {
            locationError = "Location is required"
            isValid = false
        }
        
        if let startTime = startTime, let endTime = endTime, startTime <= endTime {
            let endOfDayTime = 60 * 24
            let startTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
            let endTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
            
            let startTimeAsInt = (startTimeComponents.hour ?? 0) * 60 + (startTimeComponents.minute ?? 0)
            let endTimeAsInt = (endTimeComponents.hour ?? 0) * 60 + (endTimeComponents.minute ?? 0)
            
            if startTime >= endTime {
                endTimeError = "Invalid time range"
                isValid = false
            } else if endTimeAsInt >= endOfDayTime {
                endTimeError = "End time exceeds current day"
                isValid = false
            }
        }
        
        if let recurrence {
            if let startDate = startDate, let endDate = recurrence.endDate {
                if endDate < startDate {
                    recurrenceError = "Invalid end date"
                    isValid = false
                } else if let repeatingDays = recurrence.repeatingDays, repeatingDays.isEmpty {
                    recurrenceError = "No repeated days have been selected"
                    isValid = false
                }
            } else if let repeatingDays = recurrence.repeatingDays, repeatingDays.isEmpty == false {
                recurrenceError = "End date is required for recurring events"
                isValid = false
            }
        }
        
        if let notes = notes {
            if notes.count > 255 {
                notesError = "Notes cannot exceed 255 characters"
                isValid = false
            }
        }
        
        if !isValid {
            hasTriedSubmitting = true
            return isValid
        }
        
        return isValid
    }
    
    func setInitialValues() {
        guard let event = event else { return }
                
        self.title = event.event.title
        self.startDate = event.event.startDate
        self.startTime = Date.convertHourAndMinuteToDate(time: event.event.startTime)
        self.endTime = Date.convertHourAndMinuteToDate(time: event.event.endTime)
        self.selectedPlacemark = event.event.location
        self.eventColor = Color(hex: Int(event.event.color, radix: 16)!)
        self.invitedUserIds = event.event.invitedUsers ?? []
        
        self.notes = event.event.notes
        self.recurrence = recurrence
    }
}

