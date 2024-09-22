import SwiftUI

struct MainTabBarViewController: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        TabView {
            MyFeedView()
                .tabItem {
                    Label("Month View", systemImage: "calendar.badge.plus")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            MySchedulesView()
                .environmentObject(dateHolder)
                .tabItem {
                    Label("Week View", systemImage: "calendar")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            MyPlannersView()
                .tabItem {
                    Label("Day View", systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            MyAccountView()
                .tabItem {
                    Label("Day View", systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
        }
    }
}

#Preview {
    MainTabBarViewController()
        .environmentObject(DateHolder())
}
