import SwiftUI

struct MainTabBarViewController: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        TabView {
            MyFeedView()
                .tabItem {
                    Label("My Feed", systemImage: "house")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            MySchedulesView()
                .environmentObject(dateHolder)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            MyPlannersView()
                .tabItem {
                    Label("My Plans", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            MyAccountView()
                .tabItem {
                    Label("My Account", systemImage: "person")
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
