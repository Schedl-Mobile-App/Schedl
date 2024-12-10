import SwiftUI

struct ScheduleView: View {
    
    @StateObject private var viewModel: ScheduleViewModel
    @StateObject private var userObj: AuthService
    let timeSlots = Array(0..<24)
    
    init(viewModel: ScheduleViewModel =
         ScheduleViewModel(), userObj: AuthService = AuthService()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _userObj = StateObject(wrappedValue: userObj)
    }
    @State private var currentTimeSlot: Int = {
            let calendar = Calendar.current
            let now = Date()
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)
            return (hour * 4) + (minute / 15)
        }()
    @State private var currentDayIndex: Int = Calendar.current.component(.weekday, from: Date()) - 1
    
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading schedule...")
                } else if let schedule = viewModel.schedule {
                    Text(monthString)
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    ZStack (alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack (spacing: 0) {
                                WeekRow()
                                ScrollViewReader { verticalProxy in
                                    ScrollView(.vertical, showsIndicators: false) {
                                        HStack() {
                                            TimeColumn()
                                            EventsFlow(viewModel: viewModel)
                                        }
                                        .onAppear {
                                            withAnimation {
                                                verticalProxy.scrollTo(currentTimeSlot+5, anchor: .leading)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("No schedule to display")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            .onAppear {
                viewModel.fetchSchedule(id: "-OBzdLE_JS-pxdgALnIL")
            }
            
            Button(action: {
                viewModel.togglePopUp()
            }) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                    )
                    .shadow(radius: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            
            if viewModel.showPopUp {
                PopUpView(
                    isShowing: $viewModel.showPopUp,
                    scheduleId: "-OBzdLE_JS-pxdgALnIL",
                    viewModel: viewModel
                )
                    .transition(.scale)
            }
        }
        .animation(.easeInOut, value: viewModel.showPopUp)
    }
}

struct WeekRow: View {
    
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("")
                .frame(width: 40, height: 30)
            
            ForEach(daysOfWeek.indices, id: \.self) { index in
                Text(daysOfWeek[index])
                    .font(.caption)
                    .bold()
                    .frame(width: 125, height: 30)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .zIndex(1)
    }
}

struct TimeColumn: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<96) { timeSlot in
                if timeSlot % 4 == 0 {
                    Text("\(timeSlot/4):00")
                        .font(.caption)
                        .frame(height: 25)
                        .id(timeSlot)
                } else {
                    Text("")
                        .frame(height: 25)
                        .id(timeSlot)
                }
            }
        }
        .frame(width: 35)
    }
}

struct EventsFlow: View {
    
    @StateObject var viewModel: ScheduleViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<7) { dayIndex in
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ForEach(0..<24) { _ in
                            Rectangle()
                                .stroke(Color.gray.opacity(0.3))
                                .frame(width: 125, height: 100)
                        }
                    }
                    
                    if let events = viewModel.events {
                        ForEach(events.filter { event in
                            let calendar = Calendar.current
                            let eventDate = Date(timeIntervalSince1970: event.startTime)
                            let weekday = calendar.component(.weekday, from: eventDate) - 1
                            return weekday == dayIndex
                        }) { event in
                            let position = viewModel.calculatePosition(event: event)
                            EventCell(event: event)
                                .frame(width: 125)
                                .frame(height: position.height)
                                .offset(y: position.offset)
                        }
                    }
                }
                .frame(width: 125)
                .id(dayIndex)
            }
        }
    }
}

// Event view component
struct EventCell: View {
    let event: Event
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.3))
            .overlay(
                Text(event.title)
                    .font(.caption)
                    .padding(4)
            )
            .padding(.horizontal, 4)
    }
}

#Preview {
    ScheduleView(viewModel: ScheduleViewModel(), userObj: AuthService())
}
