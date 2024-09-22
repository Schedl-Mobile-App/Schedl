import SwiftUI

struct WeekView: View {
    @EnvironmentObject var dateHolder: DateHolder
    
    private var daysOfWeek: [Date] {
        getDaysOfWeek()
    }

    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        VStack {
            ForEach(daysOfWeek, id: \.self) { day in
                let isToday = Calendar.current.isDateInToday(day)
                let dayNumber = dayFormatter.string(from: day)
                let dayName = weekdayFormatter.string(from: day)
                
                HStack {
                    Text(dayNumber)  // date
                        .frame(width: 40, height: 40)
                        .background(isToday ? Color.blue : Color.blue.opacity(0.1))  // today
                        .cornerRadius(8)
                        .foregroundColor(isToday ? .white : .black)
                    
                    Spacer()
                    
                    Text(dayName)
                        .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    

                    Button(action: {
                        // add an event
                        print("Add event for \(dayName) \(dayNumber)")
                    }) {
                        Text("Add Event")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // lisr the events
                    Button(action: {
                        print("List events for \(dayName) \(dayNumber)")
                    }) {
                        Text("List Event")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Divider()
            }
        }
        .padding()
    }
    
    private func getDaysOfWeek() -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dateHolder.currentDate))!
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
}

#Preview {
    WeekView()
        .environmentObject(DateHolder())
}
