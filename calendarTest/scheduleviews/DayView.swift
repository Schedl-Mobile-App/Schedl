import SwiftUI

struct DayView: View {
    let hours: [String] = {
        var hoursArray = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        
        for hour in 0..<24 {
            let date = Calendar.current.date(bySetting: .hour, value: hour, of: Date())!
            hoursArray.append(formatter.string(from: date))
        }
        return hoursArray
    }()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(hours, id: \.self) { hour in
                    HStack {
                        Text(hour)
                            .frame(width: 60, alignment: .leading)
                        Spacer()
                        
                        // Add an event
                        Button(action: {
                            print("Add event for \(hour)")
                        }) {
                            Text("Add Event")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // List events
                        Button(action: {
                            print("List events for \(hour)")
                        }) {
                            Text("List Event")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .background(isCurrentHour(hour) ? Color.blue.opacity(0.3) : Color.clear)  // Highlight current hour
                    .cornerRadius(8)
                    
                    Divider()
                }
            }
            .padding()
        }
    }
    
    func isCurrentHour(_ hour: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        
        let currentHourDate = Date()
        let currentHourString = formatter.string(from: currentHourDate)
        
        return hour == currentHourString
    }
}

#Preview {
    DayView()
}
