import SwiftUI

struct ScheduleView: View {
    
    @StateObject private var scheduleViewModel: ScheduleViewModel
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let rowCount = 12
    let timeSlots = (0..<12).map { hour in
        "\(hour + 8):00"
    }
    @EnvironmentObject var dateHolder: DateHolder
    
    init(scheduleViewModel: ScheduleViewModel =
         ScheduleViewModel()) {
        _scheduleViewModel = StateObject(wrappedValue: scheduleViewModel)
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
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Header row within a LazyVGrid for alignment with event cells
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysOfWeek.count), spacing: 0) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Text(day)
                                    .font(.headline)
                                    .frame(width: geometry.size.width * 0.10, height: geometry.size.height * 0.0625)
                                    .background(Color.gray.opacity(0.2))
                                    .border(Color.black, width: 1)
                            }
                        }.frame(width: geometry.size.width * 0.90)
                        
                        // Event cells grid, sharing the same column configuration
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysOfWeek.count), spacing: 0) {
                            ForEach(0..<(rowCount * daysOfWeek.count), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * 0.10,
                                           height: geometry.size.height * 0.85 / CGFloat(rowCount))
                                    .border(Color.black, width: 0.5)
                            }
                        }
                    }
                    .frame(width: geometry.size.width*0.875, height: geometry.size.height)
                }
                
                Button("Save") {
                    scheduleViewModel.togglePopUp()
                }
                
                if scheduleViewModel.showPopUp { // Display logic remains in the view
                    PopUpView()
                        .frame(width: 300, height: 200)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
        .ignoresSafeArea()  // Expands to fill the entire screen
    }
}

#Preview {
    ScheduleView(scheduleViewModel: ScheduleViewModel())
        .environmentObject(DateHolder())
}
