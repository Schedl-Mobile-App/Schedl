//
//  ScheduleViewModel.swift
//  calendarTest
//
//  Created by David Medina on 10/16/24.
//

import SwiftUI
import Firebase

enum CalendarScrollState {
    case scrollingUp
    case scrollingDown
    case none
}

class ScheduleViewModel: ObservableObject, Identifiable, Equatable, Hashable {

    let id = UUID()
    static func == (lhs: ScheduleViewModel, rhs: ScheduleViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var currentUser: User
    @Published var userSchedules: [Schedule] = []
    @Published var selectedSchedule: Schedule? = nil
    
    @Published var userBlends: [Blend] = []
    @Published var selectedBlend: Blend? = nil
    
    @Published var invitedUsersForEvent: [User] = []
    
    var friends: [User] = []
    @Published var scheduleEvents: [EventOccurrence] = []
    @Published var showCreateEvent = false
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var activeSidebar = false
    @Published var partionedEvents: [Double : [Event]]?
    @Published var shouldReloadData = true
    
    @Published var showSearchView = false
    
//    @Published var calendarViewType: CalendarType = .week
    
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
    
    @Published var scrollState: CalendarScrollState = .scrollingUp
    @Published var scrollToCurrentPosition = false
    
    func shouldShowCreateEvent() {
        showCreateEvent.toggle()
    }
    
    func shouldShowSidebar() {
        activeSidebar.toggle()
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

                var formattedEvents: [EventOccurrence] = []
                if allEvents.isEmpty {
                    self.scheduleEvents = []
                } else {
                    for event in allEvents {
                        formattedEvents.append(contentsOf: parseRecurringEvents(for: event))
                    }
                    
                    self.scheduleEvents = formattedEvents
                    
                    let sorter: (EventOccurrence, EventOccurrence) -> Bool = { o1, o2 in
                        let dayComparison = Calendar.current.compare(o1.recurringDate, to: o2.recurringDate, toGranularity: .day)
                        if dayComparison != .orderedSame {
                            return dayComparison == .orderedAscending
                        }
                        return o1.event.startTime < o2.event.startTime
                    }
                    
                    self.scheduleEvents.sort(by: sorter)
                }
            }
            
            userBlends = try await scheduleService.fetchAllBlendSchedules(userId: currentUser.id)
            
            self.isLoading = false
        } catch {
            print("Error Message: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchNewSchedule(id: String) async {
        
        guard selectedSchedule?.id != id else { return }
        
        self.errorMessage = nil
        self.isLoading = true
        do {
            guard let scheduleObj = userSchedules.first(where: {
                $0.id == id
            }) else { return }
            
            self.selectedSchedule = scheduleObj
            self.selectedBlend = nil
            
            let allEvents = try await eventService.fetchEventsByScheduleId(scheduleId: scheduleObj.id)

            var formattedEvents: [EventOccurrence] = []
            if allEvents.isEmpty {
                self.scheduleEvents = []
            } else {
                for event in allEvents {
                    formattedEvents.append(contentsOf: parseRecurringEvents(for: event))
                }
                
                self.scheduleEvents = formattedEvents
                
                let sorter: (EventOccurrence, EventOccurrence) -> Bool = { o1, o2 in
                    let dayComparison = Calendar.current.compare(o1.recurringDate, to: o2.recurringDate, toGranularity: .day)
                    if dayComparison != .orderedSame {
                        return dayComparison == .orderedAscending
                    }
                    return o1.event.startTime < o2.event.startTime
                }
                
                self.scheduleEvents.sort(by: sorter)
            }
            
            self.isLoading = false
        } catch {
            print("Error message: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchBlendSchedule(id: String) async {
        
        guard selectedBlend?.id != id else { return }
        
        self.errorMessage = nil
        self.isLoading = true
        do {
            guard let blendObj = userBlends.first(where: {
                $0.id == id
            }) else { return }
            
            self.selectedBlend = blendObj
            self.selectedSchedule = nil
            
            var allRecurringEvents: [EventOccurrence] = []
            
            // Fetch events for each scheduleId in the blend schedule
            let events = try await eventService.fetchEventsByScheduleIds(scheduleIds: blendObj.scheduleIds)

            for event in events {
                allRecurringEvents.append(contentsOf: parseRecurringEvents(for: event))
            }
            self.scheduleEvents = allRecurringEvents
            
            let sorter: (EventOccurrence, EventOccurrence) -> Bool = { o1, o2 in
                let dayComparison = Calendar.current.compare(o1.recurringDate, to: o2.recurringDate, toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return o1.event.startTime < o2.event.startTime
            }
            
            self.scheduleEvents.sort(by: sorter)
            
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

            var formattedEvents: [EventOccurrence] = []
            for event in allEvents {
                formattedEvents.append(contentsOf: parseRecurringEvents(for: event))
            }
            
            self.scheduleEvents = formattedEvents
            
            let sorter: (EventOccurrence, EventOccurrence) -> Bool = { o1, o2 in
                let dayComparison = Calendar.current.compare(o1.recurringDate, to: o2.recurringDate, toGranularity: .day)
                if dayComparison != .orderedSame {
                    return dayComparison == .orderedAscending
                }
                return o1.event.startTime < o2.event.startTime
            }
            
            self.scheduleEvents.sort(by: sorter)
            
            self.isLoading = false
            
        } catch {
            self.errorMessage = "Failed to fetch events: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

}

