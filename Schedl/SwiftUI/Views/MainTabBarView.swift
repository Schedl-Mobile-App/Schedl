
import SwiftUI

struct MainTabBarView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if let user = authViewModel.currentUser {
             Group {
                TabView {
                    NavigationStack {
                        FeedView(currentUser: user)
                    }
                    .tabItem {
                        Label("Feed", systemImage: "house.fill")
                    }
                    
                    ZStack {
                        Color(hex: 0xf7f4f2)
                            .ignoresSafeArea()
                        
                        ScheduleView(currentUser: user)
                            .ignoresSafeArea(edges: .top)
                    }
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                    
                    NavigationStack {
                        SearchView(currentUser: user)
                    }
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    
                    NavigationStack {
                        ProfileView(currentUser: user, profileUser: user)
                            .environmentObject(authViewModel)
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            
        } else {
            LoginView()
        }
    }
}
