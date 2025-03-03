//
//  ScheduleEventView.swift
//  calendarTest
//
//  Created by David Medina on 12/16/24.
//

import SwiftUI

func formattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy"
    let formattedDate = formatter.string(from: date)
    return formattedDate
}

struct EventDetailsView: View {
    
    @State var eventStartTime: Date
    @State var eventEndTime: Date
    @EnvironmentObject private var scheduleViewModel: ScheduleViewModel
    @EnvironmentObject private var authService: AuthService
    var components = DateComponents(hour: Calendar.current.component(.hour, from: Date()), minute: Calendar.current.component(.minute, from: Date()))
    @State var dayList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State var location: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State var eventDate: Date
    @State var eventObject: Event
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    init(event: Event) {
        _eventObject = State(initialValue: event)
        _eventStartTime = State(initialValue: Date.convertHourAndMinuteToDate(time: event.startTime))
        _eventEndTime = State(initialValue: Date.convertHourAndMinuteToDate(time: event.endTime))
        _eventDate = State(initialValue: Date.convertTimeSince1970ToDate(time: event.eventDate))
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.primary)
                }
                Text("Event Details")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 25, weight: .bold))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 30) {
                    Text(eventObject.title)
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    HStack {
                        Spacer()
                        Text(formattedDate(date: eventDate))
                            .font(.system(size: 18, weight: .regular, design: .monospaced))
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        VStack {
                            Text("Start Time")
                                .font(.system(size: 20, weight: .regular, design: .monospaced))
                                .padding(.horizontal)
                            
                            DatePicker(
                                "",
                                selection: $eventStartTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .labelsHidden()
                        }
                        Spacer()
                        VStack {
                            Text("End Time")
                                .font(.system(size: 20, weight: .regular, design: .monospaced))
                                .padding(.horizontal)
                            
                            DatePicker(
                                "",
                                selection: $eventEndTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .labelsHidden()
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .foregroundStyle(Color(.systemBackground))
                        .overlay {
                            VStack {
                                HStack(spacing: 15) {
                                    ForEach(dayList, id: \.self) { day in
                                        VStack(alignment: .center, spacing: 10) {
                                            Text(day)
                                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                            Button(action: {}) {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundStyle(Color.gray.opacity(0.2))
                                                    .frame(width: 30, height: 30)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 75)
                                .padding(.horizontal)
                                .cornerRadius(15)
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                            .background(Color(.systemBackground))
                        }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Location")
                                .font(.system(size: 20, weight: .regular, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .overlay {
                                TextField("Enter Location", text: $location)
                                    .foregroundStyle(Color.red)
                                    .padding(.horizontal)
                                    .padding(.leading, 15)
                            }
                            .frame(height: 45)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Tagged Users")
                                .font(.system(size: 20, weight: .regular, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(.horizontal)
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .overlay {
                                TextField("Enter Location", text: $location)
                                    .foregroundStyle(Color.red)
                                    .padding(.horizontal)
                                    .padding(.leading, 15)
                            }
                            .frame(height: 45)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
//                        scheduleViewModel.updateEvent()
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .overlay {
                                Text("Save Changes")
                                    .foregroundColor(Color.white)
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, minHeight: 45)
                    .padding()
                    .foregroundStyle(Color("FormButtons"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .foregroundStyle(Color("PrimaryTextColor"))
        .navigationBarBackButtonHidden(true)
    }
        
//    private func createPost() async {
//        let postObj = Post(
//            id: UUID().uuidString,
//            title: viewModel.selectedEvent?.title ?? "No Title",
//            description: "No Description",
//            creationDate: Date().timeIntervalSince1970
//        )
//        if let user = userObj.currentUser {
//            await viewModel.createPost(postObj: postObj, userId: user.id, friendIds: user.friendIds)
//        }
//    }
}

//let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
//
//let yearComponents = Calendar.current.dateComponents([.month, .day, .year], from: Date())
//
//let date = Calendar.current.date(from: yearComponents)
//let startTime = Calendar.current.date(from: timeComponents)
//let endTime = Calendar.current.date(from: timeComponents)
//
//let mockEvent: Event = Event(id: "1", scheduleId: "2", title: "Going to the gym", eventDate: date ?? Date(), startTime: startTime ?? Date(), endTime: endTime ?? Date(), creationDate: Date().timeIntervalSince1970)
//
//#Preview {
//    EventDetailsView(event: mockEvent)
//        .environmentObject(ScheduleViewModel())
//        .environmentObject(AuthService())
//}
