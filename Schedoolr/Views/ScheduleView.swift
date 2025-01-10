import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var userObj: AuthService
    @StateObject var viewModel: ScheduleViewModel = ScheduleViewModel()
    @State var showNotifications: Bool = false
    @State var showEventPopUp: Bool = false
    @State var showEventDetails: Bool = false
    
    private let hourHeight: CGFloat = 60 // Height for one hour
    private let dayWidth: CGFloat = 150  // Width for one day column
    private let timeColumnWidth: CGFloat = 50
    private let currentMonth: Int = Calendar.current.component(.month, from: Date())
    private let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                scheduleHeader(showNotifications: $showNotifications)
                    .padding(.bottom, 10)
                // Fixed week row at top, aligned with grid
                HStack(spacing: 0) {
                    // Empty space above time column
                    Text("")
                        .frame(width: timeColumnWidth)
                        .background(Color.white)
                    
                    // Horizontally scrollable days header
                    ScrollView(.horizontal, showsIndicators: false) {
                        WeekRow(dayWidth: dayWidth)
                    }
                }
                .background(Color.white)
                
                // Scrollable content area
                ScrollView([.vertical], showsIndicators: true) {
                    HStack(spacing: 0) {
                        // Fixed time column on left
                        TimeColumn(hourHeight: hourHeight)
                            .background(Color.white)
                            .frame(width: timeColumnWidth)
                        
                        // Horizontally scrollable events area
                        ScrollView(.horizontal, showsIndicators: true) {
                            EventsGrid(hourHeight: hourHeight, dayWidth: dayWidth, showEventDetails: $showEventDetails)
                        }
                    }
                }
                
                if showNotifications {
                    NotificationsView(isShowing: $showNotifications)
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.8) // Limit height to 80% of screen
            
            Button(action: {
                showEventPopUp.toggle()
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.black)
                    .font(.title2)
            }
            .padding(15)
            
            if showEventPopUp {
                PopUpView(isShowing: $showEventPopUp)
            }
            
            if showEventDetails {
                EventDetailsView(isShowing: $showEventDetails)
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            if let user = userObj.currentUser {
                viewModel.fetchSchedule(id: user.schedules[0])
            }
        }
    }
}

struct WeekRow: View {
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let dayWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek.indices, id: \.self) { index in
                Text(daysOfWeek[index])
                    .font(.caption)
                    .bold()
                    .frame(width: dayWidth, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .border(Color.gray.opacity(0.2), width: 0.5)
            }
        }
    }
}

struct scheduleHeader: View {
    @Binding var showNotifications: Bool
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row with month and notifications
            HStack {
                Text(monthYearString)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: { showNotifications.toggle() }) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.black)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color.white)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

struct TimeColumn: View {
    let hourHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                Text(String(format: "%02d:00", hour))
                    .font(.caption)
                    .frame(height: hourHeight)
                    .frame(maxWidth: .infinity)
                    .border(Color.gray.opacity(0.2), width: 0.5)
            }
        }
    }
}

struct EventsGrid: View {
    @EnvironmentObject var viewModel: ScheduleViewModel
    let hourHeight: CGFloat
    let dayWidth: CGFloat
    @Binding var showEventDetails: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<7) { dayIndex in
                VStack(spacing: 0) {
                    // Create 24 hour cells for each day
                    ForEach(0..<24) { hour in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: dayWidth, height: hourHeight)
                            .border(Color.gray.opacity(0.2), width: 0.5)
                    }
                }
                .overlay(
                    // Overlay events for this day
                    eventsForDay(dayIndex: dayIndex)
                )
            }
        }
    }
    
    @ViewBuilder
    private func eventsForDay(dayIndex: Int) -> some View {
        if let events = viewModel.events {
            ForEach(events.filter { event in
                let calendar = Calendar.current
                let eventDate = Date(timeIntervalSince1970: event.startTime)
                let weekday = calendar.component(.weekday, from: eventDate) - 1
                return weekday == dayIndex
            }) { event in
                let position = calculateEventPosition(event: event)
                EventCell(event: event, showEventDetails: $showEventDetails)
                    .frame(width: dayWidth - 4) // Slight padding
                    .frame(height: position.height)
                    .position(x: dayWidth/2, y: position.offset + position.height/2)
            }
        }
    }
    
    private func calculateEventPosition(event: Event) -> (height: CGFloat, offset: CGFloat) {
        // Convert event time to hours for positioning
        let calendar = Calendar.current
        let startDate = Date(timeIntervalSince1970: event.startTime)
        let endDate = Date(timeIntervalSince1970: event.endTime)
        
        let startHour = calendar.component(.hour, from: startDate)
        let startMinute = calendar.component(.minute, from: startDate)
        let endHour = calendar.component(.hour, from: endDate)
        let endMinute = calendar.component(.minute, from: endDate)
        
        let startOffset = CGFloat(startHour) * hourHeight + CGFloat(startMinute) / 60.0 * hourHeight
        let duration = CGFloat(endHour - startHour) * hourHeight +
                      CGFloat(endMinute - startMinute) / 60.0 * hourHeight
        
        return (height: duration, offset: startOffset)
    }
}

struct EventCell: View {
    let event: Event
    @Binding var showEventDetails: Bool
    @EnvironmentObject var viewModel: ScheduleViewModel
    
    var body: some View {
        Button(action: {
            viewModel.selectedEvent = event
            showEventDetails.toggle()
        }) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.blue.opacity(0.2))
                .overlay(
                    Text(event.title)
                        .font(.caption)
                        .padding(4)
                        .lineLimit(1)
                )
        }
    }
}
