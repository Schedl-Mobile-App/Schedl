//
//  AIEventDetails.swift
//  Schedl
//
//  Created by David Medina on 9/29/25.
//

import SwiftUI

struct CalendarEventDetailsView: View {
    let event: CalendarEvent
    
    var body: some View {
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            
        }
    }
    
    
}

struct DetailRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .imageScale(.large)
                .foregroundColor(iconColor)
//                .padding(.top, 2)
            content
        }
    }
}

// MARK: - Model
struct CalendarEvent {
    let title: String
    let startDate: Date
    let startTime: Date
    let endTime: Date
    let location: String
    let color: Color
    let endDate: Date?
    let recurringDays: [String]?
    let invitedUsers: [String]?
    let notes: String?
}

// MARK: - Preview
struct CalendarEventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let endTime = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: now)!
        
        let sampleEvent = CalendarEvent(
            title: "Team Sync Meeting",
            startDate: startDate,
            startTime: startDate,
            endTime: endTime,
            location: "Conference Room B",
            color: .blue,
            endDate: nil,
            recurringDays: ["Monday", "Wednesday", "Friday"],
            invitedUsers: ["Sarah Johnson", "Mike Chen", "Emily Rodriguez"],
            notes: "Please review the Q4 roadmap before the meeting. We'll discuss priorities and resource allocation."
        )
        
        NavigationView {
            CalendarEventDetailsView(event: sampleEvent)
                .navigationTitle("Event Details")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CalendarEventDetailsView_Previews.previews
}
