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
    @Published var events: [Event]? = []
    
    func togglePopUp() {
        showPopUp.toggle()
    }

    func fetchSchedule(id: String) {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let fetchedSchedule = try await FirebaseManager.shared.fetchScheduleAsync(id: id)
                let fetchedEvents = try await FirebaseManager.shared.fetchEventsForScheduleAsync(eventIDs: fetchedSchedule.events)

                DispatchQueue.main.async {
                    self.schedule = fetchedSchedule
                    self.events = fetchedEvents
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch schedule: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

}

