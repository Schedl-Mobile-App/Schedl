//
//  ScheduleViewModel.swift
//  calendarTest
//
//  Created by David Medina on 10/16/24.
//

import SwiftUI
import Firebase

class ScheduleViewModel: ObservableObject {
    
    @Published var showPopUp = false
    @Published var schedule: Schedule?          // Holds the fetched schedule
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var events: [Event]?             // Holds the actual event objects of a schedule instance
    @Published var selectedEvent: Event?
    @Published var sideBarState = true
    @Published var scheduleListener: DatabaseHandle?
    
    func togglePopUp() {
        showPopUp.toggle()
    }
    
    func toggleSideBar() {
        sideBarState.toggle()
    }
    
    func makeNewEvent(title: String, eventDate: TimeInterval, startTime: TimeInterval, endTime: TimeInterval) -> Event {
        
        let newEvent = Event(
            id: UUID().uuidString,  // Generate new ID
            scheduleId: self.schedule?.id ?? "",
            title: title,
            eventDate: eventDate,
            startTime: startTime,
            endTime: endTime,
            creationDate: Date().timeIntervalSince1970
        )
        
        return newEvent
    }
    
    // Use of MainActor ensures that updates to the Published variables occur on the main thread
    @MainActor
    func fetchSchedule(id: String) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let fetchedSchedule = try await FirebaseManager.shared.fetchScheduleAsync(id: id)
            let fetchedEvents = try await FirebaseManager.shared.fetchEventsForScheduleAsync(eventIDs: fetchedSchedule.events)
            setupScheduleListener(scheduleId: id)
            self.schedule = fetchedSchedule
            self.events = fetchedEvents
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createEvent(newEvent: Event) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let fetchedEvent = try await FirebaseManager.shared.createNewEventAsync(eventData: newEvent)
            self.events?.append(fetchedEvent)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create event: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func createPost(postObj: Post, userId: String, friendIds: [String]) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await FirebaseManager.shared.createPostAsync(postData: postObj, userId: userId, friendIds: friendIds)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to create post: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func setupScheduleListener(scheduleId: String) {
        removeScheduleListener(scheduleId: scheduleId)
        scheduleListener = FirebaseManager.shared.observeScheduleChanges(scheduleId: scheduleId) { [weak self] events in
            DispatchQueue.main.async {
                self?.events = events
            }
        }
    }
    
    @MainActor
    func removeScheduleListener(scheduleId: String) {
        if let handle = scheduleListener {
            FirebaseManager.shared.removeScheduleObserver(handle: handle, scheduleId: scheduleId)
            scheduleListener = nil
        }
    }
}

