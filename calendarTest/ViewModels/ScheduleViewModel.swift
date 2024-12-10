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
    @Published var schedule: Schedule? // Holds the fetched schedule
    @Published var isLoading: Bool = false // Indicates loading state
    @Published var errorMessage: String? // Holds error messages if any
    @Published var events: [Event]? // Holds the actual event objects of a schedule instance
    
    func togglePopUp() {
        showPopUp.toggle()
    }

    // Use of MainActor ensures that updates to the Published variables occur on the main thread
    @MainActor
    func fetchSchedule(id: String) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let fetchedSchedule = try await FirebaseManager.shared.fetchScheduleAsync(id: id)
                let fetchedEvents = try await FirebaseManager.shared.fetchEventsForScheduleAsync(eventIDs: fetchedSchedule.events)
                self.schedule = fetchedSchedule
                self.events = fetchedEvents
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func createEvent(event: Event) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let fetchedEvent = try await FirebaseManager.shared.createNewEventAsync(eventData: event)
                self.events?.append(fetchedEvent)
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to create event: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func calculatePosition(event: Event) -> (offset: CGFloat, height: CGFloat) {
        let calendar = Calendar.current
        let eventDate = Date(timeIntervalSince1970: event.startTime)
        let startOfDay = calendar.startOfDay(for: eventDate).timeIntervalSince1970
        
        let timeFromStartOfDay = event.startTime - startOfDay
        let hoursFromStartOfDay = Int(timeFromStartOfDay / 3600)
        let minutesFromStartOfHour = Int((timeFromStartOfDay.truncatingRemainder(dividingBy: 3600)) / 60)
        
        let totalSlots = (hoursFromStartOfDay * 4) + (minutesFromStartOfHour / 15)
        let offset = CGFloat(totalSlots) * 25
        
        let durationInSeconds = event.endTime - event.startTime
        let durationInSlots = Int(ceil(durationInSeconds / (15 * 60)))
        let height = CGFloat(durationInSlots) * 25
        
        return (offset, height)
    }
}

