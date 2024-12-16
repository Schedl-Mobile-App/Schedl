//import SwiftUI
//
//struct AgendaTask: Identifiable {
//    let id = UUID()
//    let taskName: String
//    let facilitator: String
//    let taskDate: String
//    let taskLocation: String
//}
//
//struct AgendaListView: View {
//    let events = [
//        PlannerEvent(name: "Project Sync", host: "Henry Adams", date: "Oct 10, 2024 at 3:00 PM", location: "Online"),
//        PlannerEvent(name: "Celebration Gathering", host: "Son Goku", date: "Oct 12, 2024 at 7:00 PM", location: "987 W. 28th St"),
//        PlannerEvent(name: "Morning Workout", host: "Arnold", date: "Oct 15, 2024 at 10:00 AM", location: "Trufit 10th St")
//    ]
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    // Profile Card
//                    ProfileCardView(name: "John Doe", description: "iOS Developer, Passionate about SwiftUI and building great apps.", profileImage: "pic1", friendsCount: 5, postsCount: 5)
//                    
//                    // Event Cards
//                    ForEach(events) { event in
//                        NavigationLink(destination: EventView()) {
//                            EventCardView(event: event)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("My Agenda List")
//        }
//    }
//}
//
//
//struct ProfileCardView: View {
//    let name: String
//    let description: String
//    let profileImage: String
//    let friendsCount: Int
//    let postsCount: Int
//    
//    var body: some View {
//        HStack {
//            Image(profileImage)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 80, height: 80)
//                .clipShape(Circle())
//                .shadow(radius: 8)
//            
//            // Profile Details
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("\(friendsCount) Friends")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue)
//                    }
//                    Spacer()
//                    VStack(alignment: .trailing) {
//                        Text("\(postsCount) Posts")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.green)
//                    }
//                }
//                
//                // Name
//                Text(name)
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                
//                // Description
//                Text(description)
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .lineLimit(3) // text limit
//            }
//            .padding(.leading, 10)
//            
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(15)
//        .shadow(radius: 10)
//    }
//}
//
//
//struct AgendaCardView: View {
//    let task: AgendaTask
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(task.taskName)
//                        .font(.headline)
//                    Text("Facilitated by: \(task.facilitator)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text(task.taskDate)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("Venue: \(task.taskLocation)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                Spacer()
//
//                Button(action: {
//                    print("Task '\(task.taskName)' added to favorites!")
//                }) {
//                    Image(systemName: "star")
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(radius: 5)
//        }
//        .contentShape(Rectangle())
//    }
//}
//
//// Preview
//#Preview {
//    AgendaListView()
//}
