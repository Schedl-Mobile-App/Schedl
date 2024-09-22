import SwiftUI

struct MonthView: View {
    @EnvironmentObject var dateHolder: DateHolder  // Access DateHolder
    
    private var daysInMonth: [Date] {
        getDaysInMonth()
    }
    //format for day
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        let daysPerRow = 7
        
        VStack {
            // grid for the days
            let rows = daysInMonth.chunked(into: daysPerRow)
            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { date in
                        let dayNumber = dayFormatter.string(from: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        
                        Button(action: {
                            //when the day is pressed
                            print("\(dayNumber)")
                        }) {
                            Text(dayNumber)
                                .frame(width: 40, height: 40)
                                .background(isToday ? Color.blue : Color.blue.opacity(0.1))  // keep track of day
                                .cornerRadius(8)
                                .foregroundColor(isToday ? .white : .black)
                        }
                        .padding(2)
                    }
                }
            }
        }
        .padding()
    }
    
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: dateHolder.currentDate))!
        
        // days in a month
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: currentMonth)
        }
    }
}

extension Array {
    func chunked(into chunkSize: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        for index in stride(from: 0, to: count, by: chunkSize) {
            let chunk = Array(self[index..<Swift.min(index + chunkSize, count)])
            chunks.append(chunk)
        }
        return chunks
    }
}

#Preview {
    MonthView()
        .environmentObject(DateHolder())
}
