//
//  EventCardView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct EventCard: View {
    
    @EnvironmentObject var tabBarState: TabBarState
    
    var event: RecurringEvents
    @Binding var navigateToEventDetails: Bool
    @Binding var selectedEvent: RecurringEvents?
    
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(timeObj)
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
            
        let todayStart = Date.convertCurrentDateToTimeInterval(date: Date())
        let tomorrowStart = todayStart + 86400
        let blockDate = Date(timeIntervalSince1970: event.date)
        let dayText: String = {
            if event.date == todayStart     { return "Today" }
            if event.date == tomorrowStart  { return "Tomorrow" }
            let wd = Calendar.current.component(.weekday, from: blockDate)
            return weekdays[wd-1]
        }()
        let monthIdx = Calendar.current.component(.month, from: blockDate) - 1
        let monthName = months[monthIdx]
        let dayOfMonth = Calendar.current.component(.day, from: blockDate)

        Button(action: {
            tabBarState.hideTabbar = true
            selectedEvent = event
            navigateToEventDetails = true
        }) {
            HStack(alignment: .top, spacing: 20) {
                VStack( alignment: .leading, spacing: 8) {
                    Text("\(event.event.title)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    HStack(spacing: 8) {
                        Text("📆")
                            .font(.footnote)
                        HStack(spacing: 0) {
                            let formattedTime = returnTimeFormatted(timeObj: event.event.startTime)
                            Text("\(dayText), \(monthName) \(String(format: "%02d", dayOfMonth)) - ")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .tracking(0.75)
                                .foregroundStyle(Color(hex: 0x666666))
                                .multilineTextAlignment(.leading)
                            
                            Text("\(formattedTime)")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .tracking(0.75)
                                .foregroundStyle(Color(hex: 0x666666))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text("📍")
                            .font(.footnote)
                        
                        Text(event.event.locationAddress)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .tracking(0.75)
                            .foregroundStyle(Color(hex: 0x666666))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(.top, 8)
                
            }
            .padding(.leading, 20)
            .frame(minHeight: 90)
            .background(
                ZStack(alignment: .leading) {
                    Color.white
                    
                    Color(hex: Int(event.event.color, radix: 16)!)
                        .frame(width: 7)
                        .frame(maxHeight: .infinity)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

