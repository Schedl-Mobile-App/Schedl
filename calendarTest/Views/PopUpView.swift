//
//  PopUpView 2.swift
//  calendarTest
//
//  Created by David Medina on 12/4/24.
//

import SwiftUI

struct PopUpView: View {
    @Binding var isShowing: Bool  // Add this to control popup visibility
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @EnvironmentObject var viewModel: ScheduleViewModel
    
    var body: some View {
        NavigationView {
            Form {
                // Title TextField
                Section(header: Text("Event Details")) {
                    TextField("Enter event title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Enter description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.sentences)
                }

                // Time Selection
                Section(header: Text("Time")) {
                    DatePicker("Start Time",
                             selection: $startDate,
                             displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("End Time",
                             selection: $endDate,
                             in: startDate...,  // Ensures end time is after start time
                             displayedComponents: [.date, .hourAndMinute])
                }

                // Submit Button
                Section {
                    Button(action: makeEvent) {
                        Text("Create Event")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(title.isEmpty || endDate <= startDate)
                    
                    Button(action: { isShowing = false }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("New Event")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        .cornerRadius(10)
        .shadow(radius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .transition(.scale)
        .zIndex(1)
    }
    
    private func makeEvent() {
        let newEvent = Event(
            id: UUID().uuidString,  // Generate new ID
            scheduleId: viewModel.schedule?.id ?? "",
            title: title,
            description: description,
            startTime: startDate.timeIntervalSince1970,
            endTime: endDate.timeIntervalSince1970,
            creationDate: Date().timeIntervalSince1970
        )
        viewModel.createEvent(event: newEvent)
        isShowing = false
    }
}
