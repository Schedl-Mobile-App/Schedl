import SwiftUI

struct MainTabBarView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var viewModel: AuthService
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("My Feed", systemImage: "house")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            ScheduleView(userModel: viewModel)
                .environmentObject(dateHolder)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            PlannerView()
                .tabItem {
                    Label("My Plans", systemImage: "square.and.pencil")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            AccountView(viewModel: viewModel)
                .tabItem {
                    Label("My Account", systemImage: "person")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabBarView(viewModel: AuthService())
        .environmentObject(DateHolder())
}
