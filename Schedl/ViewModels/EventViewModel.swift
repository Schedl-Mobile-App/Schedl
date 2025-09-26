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
    var event: RecurringEvents?
    @Published var shouldDismiss: Bool = false
    @Published var showSaveChangesModal = false
    
    @Published var showDeleteEventModal = false
    @Published var shouldDismissToRoot = false
    
    
    var currentScheduleId: String
        
    // Binding variables for picker views
    @Published var title: String? = nil
    @Published var eventDate: Date? = nil
    @Published var eventEndDate: Date? = nil
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    @Published var selectedPlacemark: MTPlacemark? = nil
    @Published var notes: String? = nil
    @Published var eventColor: Color? = nil
    @Published var selectedFriends: [User] = []
    @Published var repeatedDays: Set<Int>? = nil
    
    var shouldShowEditRecurringModal: Bool {
        guard let event = event, event.event.repeatingDays != nil, event.event.repeatingDays!.isEmpty == false else {
            return false
        }
        
        let newTitle = event.event.title == title ? nil : title
        let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
        let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
        var newLocation: MTPlacemark? {
            return event.event.location == selectedPlacemark ? nil : selectedPlacemark
        }
        var newEndDate: Double? {
            if event.event.endDate != nil && eventEndDate != nil && Date(timeIntervalSince1970: event.event.endDate!) != eventEndDate! {
                return eventEndDate!.timeIntervalSince1970
            } else if event.event.endDate == nil && eventEndDate != nil {
                return eventEndDate!.timeIntervalSince1970
            }
            return nil
        }
        
        let newEventColor = event.event.color == selectedColor ? nil : selectedColor
        let newNotes = event.event.notes == (notes ?? "") ? nil : notes
        
        if newTitle != nil || newStartTime != nil || newEndTime != nil || newLocation != nil || newEventColor != nil || newNotes != nil {
            return true
        }
        
        return false
    }
        
    @Published var titleError: String = ""
    @Published var startDateError: String = ""
    @Published var endDateError: String = ""
    @Published var startTimeError: String = ""
    @Published var endTimeError: String = ""
    @Published var locationError: String = ""
    @Published var notesError: String = ""
    @Published var submitError: String = ""
    
    @Published var invitedUserIds: [InvitedUser] = []
    
    // Binding values to trigger/dismiss sheets/pickers
    
    @Published var hasTriedSubmitting = false
    
    func resetErrors() {
        titleError = ""
        startDateError = ""
        endDateError = ""
        startTimeError = ""
        endTimeError = ""
        locationError = ""
        notesError = ""
        submitError = ""
        hasTriedSubmitting = false
    }
    
    var isRecurringEvent: Bool {
        guard let event else { return false }
        if event.event.repeatingDays != nil && event.event.repeatingDays!.isEmpty {
            return true
        }
        return false
    }
    
    var userCanEdit: Bool {
        if let event = event {
            return event.event.ownerId == currentUser.id || event.event.invitedUsers.contains{$0.userId == currentUser.id}
        }
        return false
    }
    
    var selectedColor: String {
        if let color = eventColor {
            return color.toHex()!
        }
        // default Schedl teal color of the event if a user doesn't select one
        return "3C859E"
    }
    
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    
    var eventCreatorName: String = ""
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    init(currentUser: User, event: RecurringEvents? = nil, currentScheduleId: String, userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.currentUser = currentUser
        self.userService = userService
        self.eventService = eventService
        self.scheduleService = scheduleService
        self.notificationService = notificationService
        self.currentScheduleId = currentScheduleId
        if let event = event {
            self.event = event
            setInitialValues()
        }
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
            /*
             we need to have scheduleIds in order to properly issue updates to the scheduleEvents node to
             trigger the firebase listeners for users who are online at the same moment besides this current user
            */
            
            guard let event = event else {
                return
            }
            
//            let newTitle = event.event.title == title ? nil : title
//            let newStartDate = Date(timeIntervalSince1970: event.event.startDate) == eventDate ? nil : eventDate!.timeIntervalSince1970
//            let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
//            let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
//            var newLocation: MTPlacemark? {
//                return (event.event.locationName == selectedPlacemark?.name && event.event.locationAddress == selectedPlacemark?.address && event.event.latitude == selectedPlacemark?.latitude && event.event.longitude == selectedPlacemark?.longitude) ? nil : selectedPlacemark
//            }
//            
//            let newRepeatedDays = event.event.repeatingDays == repeatedDays ? nil : repeatedDays
//            let newEventColor = event.event.color == selectedColor ? nil : selectedColor
//            let newNotes = event.event.notes == (notes ?? "") ? nil : notes
//            
//            var newEndDate: Double? {
//                if event.event.endDate != nil && eventEndDate != nil && Date(timeIntervalSince1970: event.event.endDate!) != eventEndDate! {
//                    return eventEndDate!.timeIntervalSince1970
//                } else if event.event.endDate == nil && eventEndDate != nil {
//                    return eventEndDate!.timeIntervalSince1970
//                }
//                return nil
//            }
//            
//            let invitedUserIds = selectedFriends.map { InvitedUser(userId: $0.id) }
//            
//            let newTaggedUsers = event.event.taggedUsers == invitedUserIds ? nil : invitedUserIds
//            
//            if newTitle == nil && newStartDate == nil && newStartTime == nil && newEndTime == nil && newLocation == nil && newRepeatedDays == nil && newEventColor == nil && newNotes == nil {
//                submitError = "You haven't made any changes!"
//                hasTriedSubmitting = true
//                return
//            }
//            
//            let scheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
//            
//            try await eventService.updateSingleRecurringEvent(eventId: event.event.id, recurringDate: event.date, scheduleId: scheduleId, title: newTitle, eventDate: newStartDate, repeatedDays: newRepeatedDays, endDate: newEndDate, startTime: newStartTime, endTime: newEndTime, location: newLocation, taggedUsers: newTaggedUsers, color: newEventColor, notes: newNotes)
//            
//            selectedEvent = RecurringEvents(date: event.date, event: Event(id: event.event.id, userId: event.event.userId, scheduleId: event.event.scheduleId, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), creationDate: event.event.creationDate, locationName: selectedPlacemark!.name, locationAddress: selectedPlacemark!.address, latitude: selectedPlacemark!.latitude, longitude: selectedPlacemark!.longitude, taggedUsers: event.event.taggedUsers, color: selectedColor, notes: notes ?? "", repeatingDays: repeatedDays))
            
            shouldDismiss = true

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
            
            /*
             we need to have scheduleIds in order to properly issue updates to the scheduleEvents node to
             trigger the firebase listeners for users who are online at the same moment besides this current user
             */
            
            
//            let newTitle = event.event.title == title ? nil : title
//            let newStartDate = Date(timeIntervalSince1970: event.event.startDate) == eventDate ? nil : eventDate!.timeIntervalSince1970
//            let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
//            let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
//            var newLocation: MTPlacemark? {
//                return (event.event.locationName == selectedPlacemark?.name && event.event.locationAddress == selectedPlacemark?.address && event.event.latitude == selectedPlacemark?.latitude && event.event.longitude == selectedPlacemark?.longitude) ? nil : selectedPlacemark
//            }
//            let newRepeatedDays = event.event.repeatingDays == repeatedDays ? nil : repeatedDays
//            let newEventColor = event.event.color == selectedColor ? nil : selectedColor
//            let newNotes = event.event.notes == (notes ?? "") ? nil : notes
//            
//            var newEndDate: Double? {
//                if event.event.endDate != nil && eventEndDate != nil && Date(timeIntervalSince1970: event.event.endDate!) != eventEndDate! {
//                    return eventEndDate!.timeIntervalSince1970
//                } else if event.event.endDate == nil && eventEndDate != nil {
//                    return eventEndDate!.timeIntervalSince1970
//                }
//                return nil
//            }
//            
//            let invitedUserIds = selectedFriends.map { InvitedUser(userId: $0.id) }
//                        
//            let newTaggedUsers = event.event.taggedUsers == invitedUserIds ? nil : invitedUserIds
//            
//            if newTitle == nil && newStartDate == nil && newStartTime == nil && newEndTime == nil && newLocation == nil && newRepeatedDays == nil && newEventColor == nil && newNotes == nil && newEndDate == nil && newTaggedUsers == nil {
//                submitError = "You haven't made any changes!"
//                showSaveChangesModal = false
//                hasTriedSubmitting = true
//                return
//            }
//            
//            let scheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
//            
//            try await eventService.updateAllRecurringEvent(eventId: event.event.id, recurringDate: event.date, scheduleId: scheduleId, title: newTitle, eventDate: newStartDate, repeatedDays: newRepeatedDays, endDate: newEndDate, startTime: newStartTime, endTime: newEndTime, location: newLocation, taggedUsers: invitedUserIds, color: newEventColor, notes: newNotes)
//            
//            selectedEvent = RecurringEvents(date: event.date, event: Event(id: event.event.id, userId: event.event.userId, scheduleId: event.event.scheduleId, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), creationDate: event.event.creationDate, locationName: selectedPlacemark!.name, locationAddress: selectedPlacemark!.address, latitude: selectedPlacemark!.latitude, longitude: selectedPlacemark!.longitude, taggedUsers: event.event.taggedUsers, color: selectedColor, notes: notes ?? ""))
            
            shouldDismiss = true

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
            
            /*
             we need to have scheduleIds in order to properly issue updates to the scheduleEvents node to
             trigger the firebase listeners for users who are online at the same moment besides this current user
            */
                        
//            let newTitle = event.event.title == title ? nil : title
//            let newStartDate = Date(timeIntervalSince1970: event.event.startDate) == eventDate ? nil : eventDate!.timeIntervalSince1970
//            let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
//            let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
//            var newLocation: MTPlacemark? {
//                return (event.event.locationName == selectedPlacemark?.name && event.event.locationAddress == selectedPlacemark?.address && event.event.latitude == selectedPlacemark?.latitude && event.event.longitude == selectedPlacemark?.longitude) ? nil : selectedPlacemark
//            }
//            let newRepeatedDays = event.event.repeatingDays == repeatedDays ? nil : repeatedDays
//            let newEventColor = event.event.color == selectedColor ? nil : selectedColor
//            let newNotes = event.event.notes == (notes ?? "") ? nil : notes
//            
//            var newEndDate: Double? {
//                if event.event.endDate != nil && eventEndDate != nil && Date(timeIntervalSince1970: event.event.endDate!) != eventEndDate! {
//                    return eventEndDate!.timeIntervalSince1970
//                } else if event.event.endDate == nil && eventEndDate != nil {
//                    return eventEndDate!.timeIntervalSince1970
//                }
//                return nil
//            }
//            
//            let invitedUserIds = selectedFriends.map { InvitedUser(userId: $0.id) }
//            
//            let newTaggedUsers = event.event.taggedUsers == invitedUserIds ? nil : invitedUserIds
//            
//            if newTitle == nil && newStartDate == nil && newStartTime == nil && newEndTime == nil && newLocation == nil && newRepeatedDays == nil && newEventColor == nil && newTaggedUsers == nil && newNotes == nil && newEndDate == nil {
//                submitError = "You haven't made any changes!"
//                hasTriedSubmitting = true
//                return
//            }
//            
//            let scheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
//            
//            try await eventService.updateEvent(eventId: event.event.id, scheduleId: scheduleId, title: newTitle, eventDate: newStartDate, startTime: newStartTime, endTime: newEndTime, location: newLocation, repeatedDays: newRepeatedDays, taggedUsers: Array(invitedUserIds), color: newEventColor, notes: newNotes, endDate: newEndDate)
//            
//            selectedEvent = RecurringEvents(date: event.date, event: Event(id: event.event.id, userId: event.event.userId, scheduleId: event.event.scheduleId, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), creationDate: event.event.creationDate, locationName: selectedPlacemark!.name, locationAddress: selectedPlacemark!.address, latitude: selectedPlacemark!.latitude, longitude: selectedPlacemark!.longitude, taggedUsers: Array(invitedUserIds), color: selectedColor, notes: notes ?? ""))
            
            shouldDismiss = true

            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to update event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            if !checkValidInputs() { return }
            
            let eventNotes = notes ?? ""
            let endDateAsDouble: Double? = eventEndDate == nil ? nil : eventEndDate!.timeIntervalSince1970
            
            let userIds = selectedFriends.compactMap { InvitedUser(userId: $0.id) }
                                    
            try await eventService.createEvent(userId: currentUser.id, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), location: selectedPlacemark!, color: selectedColor, notes: eventNotes, taggedUsers: userIds, endDate: endDateAsDouble, repeatedDays: repeatedDays, scheduleId: currentScheduleId)
            
            shouldDismiss = true
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create event: \(error.localizedDescription)"
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
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let event = event else { return }
            self.selectedFriends = try await userService.fetchUsers(friendIds: event.event.invitedUsers.map(\.userId))
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch event data: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func checkValidInputs() -> Bool {
        titleError = ""
        startDateError = ""
        endDateError = ""
        startTimeError = ""
        endTimeError = ""
        locationError = ""
        
        var isValid = true
        
        if title == nil {
            titleError = "Title is required"
            isValid = false
        }
        if eventDate == nil {
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
        
        if let startTime = startTime, let endTime = endTime {
            if Date.computeTimeSinceStartOfDay(date: endTime) < Date.computeTimeSinceStartOfDay(date: startTime) {
                endTimeError = "Invalid time range"
                isValid = false
            } else if Date.computeTimeSinceStartOfDay(date: endTime) > 60 * 60 * 24 {
                endTimeError = "End time exceeds current day"
                isValid = false
            }
        }
        
        if repeatedDays != nil {
            if let startDate = eventDate, let endDate = eventEndDate {
                if endDate.timeIntervalSince1970 < startDate.timeIntervalSince1970 {
                    endDateError = "Invalid end date"
                    isValid = false
                } else if repeatedDays!.isEmpty {
                    endDateError = "No repeated days have been selected"
                    isValid = false
                }
            } else if !repeatedDays!.isEmpty {
                endDateError = "End date is required for recurring events"
                isValid = false
            }
        } else if eventEndDate != nil {
            endDateError = "No repeated days have been selected with the end date"
            isValid = false
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
        self.eventDate = Date(timeIntervalSince1970: event.event.startDate)
        self.startTime = Date.convertHourAndMinuteToDate(time: event.event.startTime)
        self.endTime = Date.convertHourAndMinuteToDate(time: event.event.endTime)
        self.eventEndDate = event.event.endDate != nil ? Date(timeIntervalSince1970: event.event.endDate!) : nil
        self.selectedPlacemark = event.event.location
        self.notes = event.event.notes
        self.eventColor = Color(hex: Int(event.event.color, radix: 16)!)
        self.invitedUserIds = event.event.invitedUsers
        self.repeatedDays = event.event.repeatingDays
    }
}

