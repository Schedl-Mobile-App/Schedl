import SwiftUI

struct ScheduleView: View {
    
    @StateObject private var viewModel: ScheduleViewModel
    @StateObject private var userModel: AuthService
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let rowCount = 12
    let timeSlots = (0..<12).map { hour in
        "\(hour + 8):00"
    }
    @EnvironmentObject var dateHolder: DateHolder
    
    init(viewModel: ScheduleViewModel =
         ScheduleViewModel(), userModel: AuthService = AuthService()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _userModel = StateObject(wrappedValue: userModel)
    }
    //    @State private var selectedView = "Month"
    //    @ObservedObject var viewModel: AuthService
    //    //@State var scheduleViewModel: ScheduleViewModel
    //
    //    var body: some View {
    //        // Schedules Tab
    //        VStack {
    //            // Display date
    //            Text(dateHolder.currentDate, formatter: dateFormatter)
    //                .font(.headline)
    //                .padding()
    //
    //            //switch between views
    //            Picker("View", selection: $selectedView) {
    //                Text("Month").tag("Month")
    //                Text("Week").tag("Week")
    //                Text("Day").tag("Day")
    //            }
    //            .pickerStyle(SegmentedPickerStyle())
    //            .padding()
    //
    //            if selectedView == "Month" {
    //                MonthView()
    //                    .environmentObject(dateHolder)
    //            } else if selectedView == "Week" {
    //                WeekView()
    //                    .environmentObject(dateHolder)
    //            } else {
    //                DayView().environmentObject(dateHolder)
    //
    //            }
    //        }
    //    }
    //
    //    // formats date for display
    //    private var dateFormatter: DateFormatter {
    //        let formatter = DateFormatter()
    //        formatter.dateStyle = .full
    //        return formatter
    //    }
    var body: some View {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading schedule...")
                } else if let schedule = viewModel.schedule {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Title: \(schedule.title)")
                            .font(.headline)
                    }
                    .padding()
                    if let events = viewModel.events {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Events:")
                                .font(.headline)
                            ForEach(events) { event in
                                Text("\(event.title)")
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
            .onAppear {
                viewModel.fetchSchedule(id: "-OBzdLE_JS-pxdgALnIL")
            }
        }

}

#Preview {
            ScheduleView(viewModel: ScheduleViewModel(), userModel: AuthService())
        .environmentObject(DateHolder())
}
