//
//  ScheduleEventView.swift
//  calendarTest
//
//  Created by David Medina on 12/16/24.
//

import SwiftUI

struct EventDetailsView: View {
    
    @State var selectedEvent: Event
    @EnvironmentObject private var scheduleViewModel: ScheduleViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var formattedDate: String {
        let eventDate = Date(timeIntervalSince1970: selectedEvent.eventDate)
        return eventDate.formatted(date: .long, time: .omitted)
    }
    
    var formattedStartTime: String {
        let eventDate = Date(timeIntervalSince1970: selectedEvent.eventDate)
        return eventDate.formatted(date: .omitted, time: .shortened)
    }
    
    var formattedEndTime: String {
        let eventDate = Date(timeIntervalSince1970: selectedEvent.eventDate + selectedEvent.eventDate)
        return eventDate.formatted(date: .omitted, time: .shortened)
    }
    
    init(event: Event) {
        selectedEvent = event
    }

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                HStack(spacing: 12) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.primary)
                    }
                    Spacer()
                    Text("Event Details")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    Button(action: {
                        print("Now Editing")
                    }) {
                        Text("Edit")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("\(selectedEvent.title)")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .tracking(0.1)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: 0x333333))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date and Time")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                            HStack(alignment: .top) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 22))
                                VStack(alignment: .leading, spacing: 0) {
                                    let formattedStartTime = returnTimeFormatted(timeObj: selectedEvent.startTime)
                                    let formattedEndTime = returnTimeFormatted(timeObj: selectedEvent.endTime)
                                    Text("\(formattedDate)")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    Text("\(formattedStartTime) - \(formattedEndTime)")
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x666666))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.white))
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                            HStack(alignment: .top) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 22))
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("\(selectedEvent.locationName)")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    Text("\(selectedEvent.locationAddress)")
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x666666))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.white))
                                .shadow(radius: 3)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Invited Users")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                            HStack {
                                Image(systemName: "person")
                                    .font(.system(size: 22))
                                HStack(spacing: 0) {
                                    Text("Number of Invitees: ")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    Text("\(selectedEvent.taggedUsers.count)")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x666666))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.white))
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let hours = Int(timeObj / 3600)
        let minutes = (Double(timeObj / 3600.0) - Double(hours)) * 60
        if hours == 0 {
            return "12:\(String(format: "%02d", Int(minutes))) AM"
        } else if hours == 12 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) PM"
        } else if hours < 11 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) AM"
        } else {
            return "\(Int(hours - 12)):\(String(format: "%02d", Int(minutes))) PM"
        }
    }
}
