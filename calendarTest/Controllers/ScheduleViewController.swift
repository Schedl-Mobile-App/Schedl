import SwiftUI

struct ScheduleViewController: View {
    @EnvironmentObject var dateHolder: DateHolder
    @State private var selectedView = "Month" 

    var body: some View {
        // Schedules Tab
        VStack {
            // Display date
            Text(dateHolder.currentDate, formatter: dateFormatter)
                .font(.headline)
                .padding()

            //switch between views
            Picker("View", selection: $selectedView) {
                Text("Month").tag("Month")
                Text("Week").tag("Week")
                Text("Day").tag("Day")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedView == "Month" {
                MonthView()
                    .environmentObject(dateHolder)
            } else if selectedView == "Week" {
                WeekView()
                    .environmentObject(dateHolder)
            } else {
                DayView().environmentObject(dateHolder)
                
            }
        }
    }

    // formats date for display
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

#Preview {
    ScheduleViewController()
        .environmentObject(DateHolder())
}
