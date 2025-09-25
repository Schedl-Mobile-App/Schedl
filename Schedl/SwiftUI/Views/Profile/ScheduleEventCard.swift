//
//  ScheduleEventCardView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct ScheduleEventCard: View {
    
    let events: [RecurringEvents]
    let key: Double
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let todayStart = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(timeObj)
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    func eventHasEnded(startTime: Double, date: Double) -> Bool {
        let currentTime = Date.computeTimeSinceStartOfDay(date: Date())
        return startTime < currentTime && date <= todayStart
    }
    
    var body: some View {
        
        let tomorrowStart = todayStart + 86400
        let blockDate = Date(timeIntervalSince1970: key)
        let dayText: String = {
            if key == todayStart     { return "Today" }
            if key == tomorrowStart  { return "Tomorrow" }
            let wd = Calendar.current.component(.weekday, from: blockDate)
            return weekdays[wd-1]
        }()
        let monthIdx = Calendar.current.component(.month, from: blockDate) - 1
        let monthName = months[monthIdx]
        let dayOfMonth = Calendar.current.component(.day, from: blockDate)

        HStack(alignment: .top, spacing: 20) {
            LazyVStack( alignment: .leading, spacing: 8) {
                HStack {
                    Text(dayText)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .tracking(-0.25)
                        .foregroundStyle(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text("\(monthName) \(String(format: "%02d", dayOfMonth))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("SecondaryText"))
                        .lineLimit(1)
                }
                
                ForEach(events, id: \.self.id) { event in
                    HStack(spacing: 12) {
                        let formattedTime = returnTimeFormatted(timeObj: event.event.startTime)
                        Text("\(event.event.title)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color("PrimaryText"))
                            .tracking(1)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .strikethrough(eventHasEnded(startTime: event.event.startTime, date: event.date), color: Color(.black))
                        
                        Spacer(minLength: 6)

                        Text("\(formattedTime)")
                            .font(.system(size: 13, weight: .medium))
                            .monospacedDigit()
                            .foregroundStyle(Color("SecondaryText"))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .strikethrough(eventHasEnded(startTime: event.event.startTime, date: event.date), color: Color(.black))
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .padding(.trailing, 10)
        .padding(.leading, 20)
        .background(
            ZStack(alignment: .leading) {
                Color("CardBackground")
                
                Color("ButtonColors")
                    .frame(width: 7)
                    .frame(maxHeight: .infinity)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
