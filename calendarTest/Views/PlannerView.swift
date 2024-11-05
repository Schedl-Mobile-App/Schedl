import SwiftUI

// Rename 'Event' to 'PlannerEvent' to avoid conflict
struct PlannerEvent: Identifiable {
    let id = UUID()
    let name: String
    let host: String
    let date: String
    let location: String
}

struct PlannerView: View {
    let events = [
        PlannerEvent(name: "Team Meeting", host: "Henry Adams", date: "Oct 10, 2024 at 3:00 PM", location: "Online"),
        PlannerEvent(name: "Birthday Party", host: "Son Goku", date: "Oct 12, 2024 at 7:00 PM", location: "987 W. 28th St"),
        PlannerEvent(name: "Gym Session", host: "Arnold", date: "Oct 15, 2024 at 10:00 AM", location: "Trufit 10th St")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(events) { event in
                        NavigationLink(destination: EventView()) {
                            EventCardView(event: event)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("My Planners View")
        }
    }
}

struct EventCardView: View {
    let event: PlannerEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(event.name)
                        .font(.headline)
                    Text("Hosted by: \(event.host)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(event.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Location: \(event.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()

                Button(action: {
                    print("Event '\(event.name)' favorited!")
                }) {
                    Image(systemName: "star")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .contentShape(Rectangle())
    }
}

// Preview
#Preview {
    PlannerView()
}
