//
//  EventViewModel.swift
//  Schedoolr
//
//  Created by David Medina on 5/27/25.
//

import Foundation
import SwiftUI

struct FriendAvailability {
    let available: Bool
    let userId: String
}

class EventViewModel: ObservableObject {
    var currentUser: User
    var selectedEvent: RecurringEvents?
    var invitedUsersForEvent: [User] = []
    
    @Published var shouldDismiss: Bool = false
    
    @Published var showSaveChangesModal = false
    
    // Binding variables for picker views
    @Published var title: String? = nil
    @Published var eventDate: Date? = nil
    @Published var eventEndDate: Date? = nil
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    @Published var selectedPlacemark: MTPlacemark? = nil
    @Published var notes: String? = nil
    @Published var eventColor: Color? = nil
    @Published var invitedUserIds: [String] = []
    @Published var selectedFriends: [User] = []
    @Published var repeatedDays: Set<Int>? = nil
    
    @Published var availabilityList: [FriendAvailability] = []
    @Published var userFriends: [User] = []
    
    @Published var titleError: String = ""
    @Published var startDateError: String = ""
    @Published var endDateError: String = ""
    @Published var startTimeError: String = ""
    @Published var endTimeError: String = ""
    @Published var locationError: String = ""
    @Published var notesError: String = ""
    @Published var submitError: String = ""
    
    // Binding values to trigger/dismiss sheets/pickers
    
    @Published var showInviteUsersSheet: Bool = false
    @Published var hasTriedSubmitting = false
    
//    var shouldUpdateSingularReference: Bool {
//        guard let selectedEvent = selectedEvent, let title, let eventDate else { return false }
//        // if these values differ, this means that we must update these values
//        if selectedEvent.event.startDate != eventDate.timeIntervalSince1970 && selectedEvent.event.title != title {
//            
//        }
//    }
    
    var isRecurringEvent: Bool {
        guard let selectedEvent else { return false }
        if selectedEvent.event.repeatingDays != nil && !selectedEvent.event.repeatingDays!.isEmpty {
            
            return true
        }
        return false
    }
    
    var userCanEdit: Bool {
        if let event = selectedEvent {
            return event.event.userId == currentUser.id || event.event.taggedUsers.contains(currentUser.id)
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
    @Published var hasLoadedPreviousPage = true
    @Published var eventCreatorName: String = ""
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    init(currentUser: User, selectedEvent: RecurringEvents? = nil, userService: UserServiceProtocol = UserService.shared, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.currentUser = currentUser
        self.selectedEvent = selectedEvent
        self.userService = userService
        self.eventService = eventService
        self.scheduleService = scheduleService
        self.notificationService = notificationService
        
        if selectedEvent != nil {
             setInitialValues()
        }
    }
    
    @MainActor
    func updateRecurringEvent() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            if !checkValidInputs() { return }
            /*
             we need to have scheduleIds in order to properly issue updates to the scheduleEvents node to
             trigger the firebase listeners for users who are online at the same moment besides this current user
            */
            
            guard let event = selectedEvent else { return }
            
            let newTitle = event.event.title == title ? nil : title
            let newStartDate = Date(timeIntervalSince1970: event.event.startDate) == eventDate ? nil : eventDate!.timeIntervalSince1970
            let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
            let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
            var newLocation: MTPlacemark? {
                return (event.event.locationName == selectedPlacemark?.name && event.event.locationAddress == selectedPlacemark?.address && event.event.latitude == selectedPlacemark?.latitude && event.event.longitude == selectedPlacemark?.longitude) ? nil : selectedPlacemark
            }
            
            let newRepeatedDays = event.event.repeatingDays == repeatedDays ? nil : repeatedDays
            let newEventColor = event.event.color == selectedColor ? nil : selectedColor
            let newNotes = event.event.notes == (notes ?? "") ? nil : notes
            
            if newTitle == nil && newStartDate == nil && newStartTime == nil && newEndTime == nil && newLocation == nil && newRepeatedDays == nil && newEventColor == nil && newNotes == nil {
                submitError = "You haven't made any changes!"
                hasTriedSubmitting = true
                return
            }
            
            var newEndDate: Double? {
                if let endDate = event.event.endDate {
                    return endDate
                }
                return nil
            }
            
            let newTaggedUsers = event.event.taggedUsers == invitedUserIds ? nil : invitedUserIds
            
            let scheduleIds = try await scheduleService.fetchScheduleIds(userIds: [currentUser.id] + event.event.taggedUsers)
            
            try await eventService.updateSingleRecurringEvent(eventId: event.event.id, recurringDate: event.date, scheduleIds: scheduleIds, title: newTitle, eventDate: newStartDate, repeatedDays: newRepeatedDays, endDate: newEndDate, startTime: newStartTime, endTime: newEndTime, location: newLocation, taggedUsers: newTaggedUsers, color: newEventColor, notes: newNotes)
            
            selectedEvent = RecurringEvents(date: event.date, event: Event(id: event.event.id, userId: event.event.userId, scheduleId: event.event.scheduleId, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), creationDate: event.event.creationDate, locationName: selectedPlacemark!.name, locationAddress: selectedPlacemark!.address, latitude: selectedPlacemark!.latitude, longitude: selectedPlacemark!.longitude, taggedUsers: event.event.taggedUsers, color: selectedColor, notes: notes ?? ""))
            
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
            if !checkValidInputs() { return }
            guard let event = selectedEvent else { return }
            
            /*
             we need to have scheduleIds in order to properly issue updates to the scheduleEvents node to
             trigger the firebase listeners for users who are online at the same moment besides this current user
            */
            
            
            let newTitle = event.event.title == title ? nil : title
            let newStartDate = Date(timeIntervalSince1970: event.event.startDate) == eventDate ? nil : eventDate!.timeIntervalSince1970
            let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
            let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
            var newLocation: MTPlacemark? {
                return (event.event.locationName == selectedPlacemark?.name && event.event.locationAddress == selectedPlacemark?.address && event.event.latitude == selectedPlacemark?.latitude && event.event.longitude == selectedPlacemark?.longitude) ? nil : selectedPlacemark
            }
            let newRepeatedDays = event.event.repeatingDays == repeatedDays ? nil : repeatedDays
            let newEventColor = event.event.color == selectedColor ? nil : selectedColor
            let newNotes = event.event.notes == (notes ?? "") ? nil : notes
            
            if newTitle == nil && newStartDate == nil && newStartTime == nil && newEndTime == nil && newLocation == nil && newRepeatedDays == nil && newEventColor == nil && newNotes == nil {
                submitError = "You haven't made any changes!"
                hasTriedSubmitting = true
                return
            }
            
            var newEndDate: Double? {
                if let endDate = event.event.endDate {
                    return endDate
                }
                return nil
            }
            
            let newTaggedUsers = event.event.taggedUsers == invitedUserIds ? nil : invitedUserIds
                        
            let scheduleIds = try await scheduleService.fetchScheduleIds(userIds: [currentUser.id] + event.event.taggedUsers)
            
            try await eventService.updateAllRecurringEvent(eventId: event.event.id, recurringDate: event.date, scheduleIds: scheduleIds, title: newTitle, eventDate: newStartDate, repeatedDays: newRepeatedDays, endDate: newEndDate, startTime: newStartTime, endTime: newEndTime, location: newLocation, taggedUsers: newTaggedUsers, color: newEventColor, notes: newNotes)
            
            selectedEvent = RecurringEvents(date: event.date, event: Event(id: event.event.id, userId: event.event.userId, scheduleId: event.event.scheduleId, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), creationDate: event.event.creationDate, locationName: selectedPlacemark!.name, locationAddress: selectedPlacemark!.address, latitude: selectedPlacemark!.latitude, longitude: selectedPlacemark!.longitude, taggedUsers: event.event.taggedUsers, color: selectedColor, notes: notes ?? ""))
            
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
            guard let event = selectedEvent else { return }
            
            /*
             we need to have scheduleIds in order to properly issue updates to the scheduleEvents node to
             trigger the firebase listeners for users who are online at the same moment besides this current user
            */
                        
            let newTitle = event.event.title == title ? nil : title
            let newStartDate = Date(timeIntervalSince1970: event.event.startDate) == eventDate ? nil : eventDate!.timeIntervalSince1970
            let newStartTime = Date.convertHourAndMinuteToDate(time: event.event.startTime) == startTime ? nil : Date.computeTimeSinceStartOfDay(date: startTime!)
            let newEndTime = Date.convertHourAndMinuteToDate(time: event.event.endTime) == endTime ? nil : Date.computeTimeSinceStartOfDay(date: endTime!)
            var newLocation: MTPlacemark? {
                return (event.event.locationName == selectedPlacemark?.name && event.event.locationAddress == selectedPlacemark?.address && event.event.latitude == selectedPlacemark?.latitude && event.event.longitude == selectedPlacemark?.longitude) ? nil : selectedPlacemark
            }
            let newRepeatedDays = event.event.repeatingDays == repeatedDays ? nil : repeatedDays
            let newEventColor = event.event.color == selectedColor ? nil : selectedColor
            let newNotes = event.event.notes == (notes ?? "") ? nil : notes
            
            if newTitle == nil && newStartDate == nil && newStartTime == nil && newEndTime == nil && newLocation == nil && newRepeatedDays == nil && newEventColor == nil && newNotes == nil {
                submitError = "You haven't made any changes!"
                hasTriedSubmitting = true
                return
            }
            
            let scheduleIds = try await scheduleService.fetchScheduleIds(userIds: [currentUser.id] + event.event.taggedUsers)
            
            try await eventService.updateEvent(eventId: event.event.id, scheduleIds: scheduleIds, title: newTitle, eventDate: newStartDate, startTime: newStartTime, endTime: newEndTime, location: newLocation, repeatedDays: newRepeatedDays, taggedUsers: nil, color: newEventColor, notes: newNotes)
            
            selectedEvent = RecurringEvents(date: event.date, event: Event(id: event.event.id, userId: event.event.userId, scheduleId: event.event.scheduleId, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), creationDate: event.event.creationDate, locationName: selectedPlacemark!.name, locationAddress: selectedPlacemark!.address, latitude: selectedPlacemark!.latitude, longitude: selectedPlacemark!.longitude, taggedUsers: event.event.taggedUsers, color: selectedColor, notes: notes ?? ""))
            
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
            
            let userIds = selectedFriends.compactMap { $0.id }
                                    
            let eventId = try await eventService.createEvent(userId: currentUser.id, title: title!, startDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!), location: selectedPlacemark!, color: selectedColor, notes: eventNotes, taggedUsers: userIds, endDate: endDateAsDouble, repeatedDays: repeatedDays)
            
            if !userIds.isEmpty {
                try await notificationService.sendEventInvites(senderId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUserIds: userIds, eventId: eventId, eventDate: eventDate!.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: startTime!), endTime: Date.computeTimeSinceStartOfDay(date: endTime!))
            }
            
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
            guard let selectedEvent = selectedEvent else { return }
            try await eventService.deleteEvent(eventId: selectedEvent.event.id, userId: selectedEvent.event.userId)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
//    @MainActor
//    func deleteSingleRecurringEvent() async {
//        self.isLoading = true
//        self.errorMessage = nil
//        do {
//            guard let selectedEvent = selectedEvent else { return }
////            try await eventService.deleteSingleRecurringEvent(eventId: selectedEvent.event.id, userId: selectedEvent.event.userId)
//            self.isLoading = false
//        } catch {
//            self.errorMessage = "Failed to delete event: \(error.localizedDescription)"
//            self.isLoading = false
//        }
//    }
    
    @MainActor
    func fetchEventData() async {
        self.isLoading = false
        self.errorMessage = nil
        do {
            guard let selectedEvent = selectedEvent else { return }
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
    
    @MainActor
    func fetchFriends() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            guard let eventDate = eventDate, let startTime = startTime, let endTime = endTime else {
                self.errorMessage = "Please fill out the event date, start time, and end time to check if your friends are available!"
                self.isLoading = false
                return
            }
            
            self.userFriends = try await userService.fetchUserFriends(userId: currentUser.id)
            
            let normalizedStartTime: Double = floor(Date.computeTimeSinceStartOfDay(date: startTime) / 900.0) * 900.0
            
            self.availabilityList = try await eventService.checkAvailability(userIds: self.userFriends.map { $0.id }, eventDate: Int(eventDate.timeIntervalSince1970), startTime: Int(normalizedStartTime), endTime: Int(Date.computeTimeSinceStartOfDay(date: endTime)))
            
            self.isLoading = false
        } catch {
            self.errorMessage = "The following error occured: \(error.localizedDescription)"
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
        guard let event = selectedEvent else { return }
        
        self.title = event.event.title
        self.eventDate = Date(timeIntervalSince1970: event.event.startDate)
        self.startTime = Date.convertHourAndMinuteToDate(time: event.event.startTime)
        self.endTime = Date.convertHourAndMinuteToDate(time: event.event.endTime)
        self.eventEndDate = event.event.endDate != nil ? Date(timeIntervalSince1970: event.event.endDate!) : nil
        self.selectedPlacemark = MTPlacemark(name: event.event.locationName, address: event.event.locationAddress, latitude: event.event.latitude, longitude: event.event.longitude)
        self.notes = event.event.notes
        self.eventColor = Color(hex: Int(event.event.color, radix: 16)!)
        self.invitedUserIds = event.event.taggedUsers
        self.repeatedDays = event.event.repeatingDays
    }
}

