//
//  ScheduleViewModel.swift
//  calendarTest
//
//  Created by David Medina on 10/16/24.
//

import SwiftUI
import Firebase

class ScheduleViewModel: ObservableObject {
    
    var currentUser: User
    @Published var userSchedules: [Schedule] = []
    @Published var selectedSchedule: Schedule? = nil
    
    @Published var userBlends: [Blend] = []
    @Published var selectedBlend: Blend? = nil
    
    @Published var invitedUsersForEvent: [User] = []
    
    var friends: [User] = []
    @Published var scheduleEvents: [RecurringEvents] = []
    @Published var showCreateEvent = false
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var activeSidebar = false
    @Published var partionedEvents: [Double : [Event]]?
    @Published var shouldReloadData = true
    
    private var addedEventsHandler: (DatabaseHandle, String)?
    private var removedEventsHandler: (DatabaseHandle, String)?
    private var updatedEventsHandler: (DatabaseHandle, String)?
    
    private var addedBlendEventsHandler: [DatabaseHandle: String] = [:]
    private var removedBlendEventsHandler: [DatabaseHandle: String] = [:]
    private var updatedBlendEventsHandler: [DatabaseHandle: String] = [:]
    
    private var newBlendHandler: DatabaseHandle?
    
    private var addedScheduleIdToBlendHandler: (DatabaseHandle, String)?
    private var removedScheduleIdToBlendHandler: (DatabaseHandle, String)?
    
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
        
        // 1. For clarity and efficiency, create a single Calendar instance.
        let calendar = Calendar.current
        
        // 2. Handle non-recurring events with an early exit.
        //    We also change repeatingDays to a Set<Int> for performance and type safety.
        guard let repeatedDays: Set<Int> = event.repeatingDays, !repeatedDays.isEmpty, let endDate = event.endDate else {
            return [RecurringEvents(date: event.startDate, event: event)]
        }

        // 3. (PERFORMANCE) Create a dictionary for exceptions for O(1) lookups.
        //    This is the most significant performance improvement.
//        let exceptionsByDate = Dictionary(uniqueKeysWithValues: event.exceptions.map { ($0.date, $0) })
        
        // 4. Set up loop variables.
        var generatedEvents: [RecurringEvents] = []
        var cursor = Date(timeIntervalSince1970: event.startDate)
        let finalDate = Date(timeIntervalSince1970: endDate)
        
//        var globalException: EventException? = nil

        // 5. Loop through each day in the range.
        while cursor <= finalDate {
            let weekIndex = calendar.component(.weekday, from: cursor) - 1 // Assumes Sunday = 1, so result is 0-6.
            
            // 6. (DRY) First, check if the current day is a day the event should occur on.
            if repeatedDays.contains(weekIndex) {
                let cursorTimeInterval = cursor.timeIntervalSince1970
                let  eventForThisDay = event // Default to the original event.
                // 7. (OPTIMIZED) Now, check for an exception using our fast dictionary lookup.
//                if let exception = exceptionsByDate[cursorTimeInterval] {
//                    // If an exception exists, create a new modified event instance for this occurrence.
//                    // A helper function makes this much cleaner.
//                    
//                    eventForThisDay = createEventInstance(from: event, with: exception)
//                    if exception.futureEventsIncluded {
//                        globalException = exception
//                    }
//                } else if let globalException = globalException {
//                    eventForThisDay = createEventInstance(from: event, with: globalException)
//                }
                
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
            ownerId: baseEvent.ownerId,
            title: exception.title ?? baseEvent.title,
            startDate: baseEvent.startDate, // The series start date remains the same
            startTime: exception.startTime ?? baseEvent.startTime,
            endTime: exception.endTime ?? baseEvent.endTime,
            locationName: exception.locationName ?? baseEvent.location.name,
            locationAddress: exception.locationAddress ?? baseEvent.location.address,
            latitude: exception.latitude ?? baseEvent.location.latitude,
            longitude: exception.longitude ?? baseEvent.location.longitude,
            invitedUsers: baseEvent.invitedUsers,
            color: exception.color ?? baseEvent.color,
            notes: exception.notes ?? baseEvent.notes,
            // The original exceptions list is carried over for context if needed
//            exceptions: baseEvent.exceptions
        )
    }
    
    // Use of MainActor ensures that updates to the Published variables occur on the main thread
    @MainActor
    func fetchSchedule() async {
        self.errorMessage = nil
        self.isLoading = true
        do {
            self.userSchedules = try await scheduleService.fetchAllSchedules(userId: currentUser.id)
            
            if !userSchedules.isEmpty {
                self.selectedSchedule = self.userSchedules.first!
                let scheduleId = self.selectedSchedule!.id
                
                let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
                
                // now that we've fetched all events in DB, we need to check if any events are recurring meaning they'll have repeats in the future
                // note that even singular events will be stored in this array of type RecurringEvents since there isn't a need
                // to separate these from regular Event objects
                var formattedEvents: [RecurringEvents] = []
                if allEvents.isEmpty {
                    self.scheduleEvents = []
                } else {
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
                }
            }
            
            userBlends = try await scheduleService.fetchAllBlendSchedules(userId: currentUser.id)
            
//            observeScheduleChanges()
//            observeNewBlends()
            
            self.isLoading = false
        } catch {
            print("Error Message: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchNewSchedule(id: String) async {
        self.errorMessage = nil
        self.isLoading = true
        do {
//            removeScheduleObservers()
//            removeBlendObservers()
            guard let scheduleObj = userSchedules.first(where: {
                $0.id == id
            }) else { return }
            
            self.selectedSchedule = scheduleObj
            self.selectedBlend = nil
            
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleObj.id)
            
            // now that we've fetched all events in DB, we need to check if any events are recurring meaning they'll have repeats in the future
            // note that even singular events will be stored in this array of type RecurringEvents since there isn't a need
            // to separate these from regular Event objects
            var formattedEvents: [RecurringEvents] = []
            if allEvents.isEmpty {
                self.scheduleEvents = []
            } else {
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
            }
            
            /*observeScheduleChanges*/()
            
            self.isLoading = false
        } catch {
            print("Error message: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchBlendSchedule(id: String) async {
        self.errorMessage = nil
        self.isLoading = true
        do {
//            removeScheduleObservers()
//            removeBlendObservers()
            guard let fetchedBlendSchedule = try await scheduleService.fetchBlendSchedule(blendId: id) else { return }
            
            self.selectedBlend = fetchedBlendSchedule
            self.selectedSchedule = nil
            
            var allRecurringEvents: [RecurringEvents] = []
            // Fetch events for each scheduleId in the blend schedule
            let events = try await eventService.fetchEventsByScheduleIds(scheduleIds: fetchedBlendSchedule.scheduleIds)
//            let userId = events.first(where: {
//                fetchedBlendSchedule.invitedUsers.contains($0.userId)
//            })?.userId ?? ""
            for event in events {
//                var copyEvent = event
//                copyEvent.color = selectedBlend?.colors[userId] ?? "F7F4F2"
//                print(copyEvent.color)
                allRecurringEvents.append(contentsOf: parseRecurringEvents(event: event))
            }
            self.scheduleEvents = allRecurringEvents.sorted {
                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return $0.event.startTime < $1.event.startTime
            }
            
//            observeBlendScheduleChanges()
            
            self.isLoading = false
        } catch {
            print("Error message: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch blend schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createSchedule(title: String) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let newSchedule = try await scheduleService.createSchedule(userId: currentUser.id, title: title)
            
            self.userSchedules.append(newSchedule)
            self.selectedSchedule = newSchedule
            
//            observeScheduleChanges()
            
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
            guard let schedule = selectedSchedule else { return }
            try await scheduleService.updateSchedule(scheduleId: schedule.id, title: schedule.title)
            self.isLoading = false
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
            guard let scheduleId = selectedSchedule?.id as? String else {
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
    
//    @MainActor
//    func observeScheduleChanges() {
//        
//        guard let scheduleId = selectedSchedule?.id else { return }
//        removeScheduleObservers()
//        
//        let addHandle = scheduleService.observeAddedEvents(scheduleId: scheduleId) { [weak self] eventId in
//            guard let self = self else {
//                return
//            }
//            if self.scheduleEvents.contains(where: { $0.event.id == eventId }) {
//                return
//            } else {
//                Task { @MainActor in
//                    do {
//                        let newlyAddedEvent = try await self.eventService.fetchEvent(eventId: eventId)
//                        let modifiedEvent = self.parseRecurringEvents(event: newlyAddedEvent)
//                        self.scheduleEvents.append(contentsOf: modifiedEvent)
//                    } catch {
//                        self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
//                    }
//                }
//            }
//        }
//        
//        addedEventsHandler = (addHandle, scheduleId)
//        
//        let removeHandle = scheduleService.observeRemovedEvents(scheduleId: scheduleId) { [weak self] eventId in
//            guard let self = self else { return }
//            
//            guard let removedEventIndex = self.scheduleEvents.firstIndex(where: { $0.event.id == eventId }) else { return }
//            self.scheduleEvents.remove(at: removedEventIndex)
//            
//        }
//        
//        removedEventsHandler = (removeHandle, scheduleId)
//        
//        let updateHandle = scheduleService.observeUpdatedEvents(scheduleId: scheduleId, completion: { [weak self] eventId in
//            
//            guard let self = self else {
//                return
//            }
//            
//            Task { @MainActor in
//                do {
//                    let updatedEvent = try await self.eventService.fetchEvent(eventId: eventId)
//                    let modifiedEvent = self.parseRecurringEvents(event: updatedEvent)
//                    self.scheduleEvents.removeAll(where: { $0.event.id == eventId })
//                    self.scheduleEvents.append(contentsOf: modifiedEvent)
//                } catch {
//                    self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
//                }
//            }
//        })
//        
//        updatedEventsHandler = (updateHandle, scheduleId)
//    }
//    
//    func removeScheduleObservers() {
//        if let addHandler = addedEventsHandler {
//            scheduleService.removeScheduleObserver(handle: addHandler.0, scheduleId: addHandler.1)
//            addedEventsHandler = nil
//        }
//        
//        if let removeHandler = removedEventsHandler {
//            scheduleService.removeScheduleObserver(handle: removeHandler.0, scheduleId: removeHandler.1)
//            removedEventsHandler = nil
//        }
//        
//        if let updateHandler = updatedEventsHandler {
//            scheduleService.removeScheduleObserver(handle: updateHandler.0, scheduleId: updateHandler.1)
//            updatedEventsHandler = nil
//        }
//    }
//    
//    func observeNewBlends() {
//        removeNewBlendObservers()
//        
//        let addHandle = scheduleService.observeCreatedBlend(userId: currentUser.id, completion: { [weak self] blendId in
//            guard let self = self else {
//                return
//            }
//            if self.userBlends.contains(where: { $0.id == blendId }) {
//                return
//            } else {
//                Task { @MainActor in
//                    do {
//                        let newBlend = try await self.scheduleService.fetchBlendSchedule(blendId: blendId)
//                        self.userBlends.append(newBlend)
//                    } catch {
//                        self.errorMessage = "Unable to load blend schedule: \(error.localizedDescription)"
//                    }
//                }
//            }
//        })
//        
//        newBlendHandler = addHandle
//    }
//    
//    func observeBlendScheduleChanges() {
//        guard let blendId = selectedBlend?.id, let scheduleIds = selectedBlend?.scheduleIds else { return }
//        
//        removeBlendObservers()
//        
//        let addedScheduleHandler = scheduleService.observeAddedBlendSchedules(blendId: blendId, completion: { [weak self] scheduleId in
//            guard let self = self else { return }
//            
//            if !self.scheduleEvents.isEmpty {
//                return
//            } else {
//                Task { @MainActor in
//                    do {
//                        self.selectedBlend?.scheduleIds.append(scheduleId)
//                        let fetchedEvents = try await self.eventService.fetchEventsByScheduleId(scheduleId: scheduleId)
//                        
//                        var formattedEvents: [RecurringEvents] = []
//                        if !fetchedEvents.isEmpty {
//                            for event in fetchedEvents {
//                                formattedEvents.append(contentsOf: self.parseRecurringEvents(event: event))
//                                //            let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
//                            }
//                            
//                            self.scheduleEvents.append(contentsOf: formattedEvents)
//                            self.scheduleEvents = self.scheduleEvents.sorted {
//                                let dayComparison = Calendar.current.compare(Date(timeIntervalSince1970: $0.date), to: Date(timeIntervalSince1970: $1.date), toGranularity: .day)
//                                
//                                // if the event start dates are different, then we sort by their date
//                                if dayComparison != .orderedSame {
//                                    return dayComparison == .orderedAscending
//                                }
//                                
//                                // if they occur on the same day, then we sort by their start time
//                                return $0.event.startTime < $1.event.startTime
//                            }
//                        }
//                    } catch {
//                        self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
//                    }
//                }
//                
//                let addHandle = scheduleService.observeAddedEvents(scheduleId: scheduleId) { [weak self] eventId in
//                    guard let self = self else {
//                        return
//                    }
//                    if self.scheduleEvents.contains(where: { $0.event.id == eventId }) {
//                        return
//                    } else {
//                        Task { @MainActor in
//                            do {
//                                let newlyAddedEvent = try await self.eventService.fetchEvent(eventId: eventId)
//                                let modifiedEvent = self.parseRecurringEvents(event: newlyAddedEvent)
//                                self.scheduleEvents.append(contentsOf: modifiedEvent)
//                            } catch {
//                                self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                }
//                
//                addedBlendEventsHandler[addHandle] = scheduleId
//                
//                let removeHandle = scheduleService.observeRemovedEvents(scheduleId: scheduleId) { [weak self] eventId in
//                    guard let self = self else { return }
//                    
//                    guard let removedEventIndex = self.scheduleEvents.firstIndex(where: { $0.event.id == eventId }) else { return }
//                    self.scheduleEvents.remove(at: removedEventIndex)
//                    
//                }
//                
//                removedBlendEventsHandler[removeHandle] = scheduleId
//            }
//        })
//
//                                                                              
//        self.addedScheduleIdToBlendHandler = (addedScheduleHandler, blendId)
//        
//        let removedScheduleHandler = self.scheduleService.observeRemovedBlendSchedules(blendId: blendId, completion: { [weak self] scheduleId in
//            guard let self = self else { return }
//            
//            self.selectedBlend?.scheduleIds.removeAll(where: { $0 == scheduleId })
//            self.scheduleEvents.removeAll(where: { $0.event.scheduleId == scheduleId })
//            
//            if self.addedBlendEventsHandler.values.contains(scheduleId) {
//                let handle = self.addedBlendEventsHandler.first(where: { $0.value == scheduleId })!.key
//                self.scheduleService.removeScheduleObserver(handle: handle, scheduleId: scheduleId)
//            }
//            
//            if self.updatedBlendEventsHandler.values.contains(scheduleId) {
//                let handle = self.updatedBlendEventsHandler.first(where: { $0.value == scheduleId })!.key
//                self.scheduleService.removeScheduleObserver(handle: handle, scheduleId: scheduleId)
//            }
//            
//            if self.removedBlendEventsHandler.values.contains(scheduleId) {
//                let handle = self.removedBlendEventsHandler.first(where: { $0.value == scheduleId })!.key
//                self.scheduleService.removeScheduleObserver(handle: handle, scheduleId: scheduleId)
//            }
//        })
//        
//        self.removedScheduleIdToBlendHandler = (removedScheduleHandler, blendId)
//        
//        
//        
//        for id in scheduleIds {
//            let addHandle = scheduleService.observeAddedEvents(scheduleId: id) { [weak self] eventId in
//                guard let self = self else {
//                    return
//                }
//                
//                if self.scheduleEvents.contains(where: { $0.event.id == eventId }) {
//                    return
//                } else {
//                    Task { @MainActor in
//                        do {
//                            print("Being called in the observer blend schedule changes")
//                            let newlyAddedEvent = try await self.eventService.fetchEvent(eventId: eventId)
//                            let modifiedEvent = self.parseRecurringEvents(event: newlyAddedEvent)
//                            self.scheduleEvents.append(contentsOf: modifiedEvent)
//                        } catch {
//                            self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
//                        }
//                    }
//                }
//            }
//            
//            addedBlendEventsHandler[addHandle] = id
//            
//            let removeHandle = scheduleService.observeRemovedEvents(scheduleId: id) { [weak self] eventId in
//                guard let self = self else { return }
//                
//                guard let removedEventIndex = self.scheduleEvents.firstIndex(where: { $0.event.id == eventId }) else { return }
//                self.scheduleEvents.remove(at: removedEventIndex)
//                
//            }
//            
//            removedBlendEventsHandler[removeHandle] = id
//            
//            let updateHandle = scheduleService.observeUpdatedEvents(scheduleId: id, completion: { [weak self] eventId in
//                
//                guard let self = self else {
//                    return
//                }
//                
//                Task { @MainActor in
//                    do {
//                        let updatedEvent = try await self.eventService.fetchEvent(eventId: eventId)
//                        let modifiedEvent = self.parseRecurringEvents(event: updatedEvent)
//                        self.scheduleEvents.removeAll(where: { $0.event.id == eventId })
//                        self.scheduleEvents.append(contentsOf: modifiedEvent)
//                    } catch {
//                        self.errorMessage = "Unable to load schedule events: \(error.localizedDescription)"
//                    }
//                }
//            })
//            
//            updatedBlendEventsHandler[updateHandle] = id
//            
//        }
//    }
//    
//    func removeBlendObservers() {
//        
//        for handle in addedBlendEventsHandler {
//            scheduleService.removeScheduleObserver(handle: handle.key, scheduleId: handle.value)
//        }
//        
//        addedBlendEventsHandler = [:]
//        
//        for handle in updatedBlendEventsHandler {
//            scheduleService.removeScheduleObserver(handle: handle.key, scheduleId: handle.value)
//        }
//        
//        updatedBlendEventsHandler = [:]
//        
//        for handle in removedBlendEventsHandler {
//            scheduleService.removeScheduleObserver(handle: handle.key, scheduleId: handle.value)
//        }
//        
//        removedBlendEventsHandler = [:]
//        
//        if let addHandle = addedScheduleIdToBlendHandler {
//            scheduleService.removeBlendObserver(handle: addHandle.0, blendId: addHandle.1)
//            addedScheduleIdToBlendHandler = nil
//        }
//        
//        if let removeHandle = removedScheduleIdToBlendHandler {
//            scheduleService.removeBlendObserver(handle: removeHandle.0, blendId: removeHandle.1)
//            removedScheduleIdToBlendHandler = nil
//        }
//    }
//    
//    func removeNewBlendObservers() {
//        if let handle = newBlendHandler {
//            scheduleService.removeNewBlendObserver(handle: handle, userId: currentUser.id)
//            newBlendHandler = nil
//        }
//    }
//    
//    deinit {
//        removeScheduleObservers()
//        removeBlendObservers()
//    }
}

