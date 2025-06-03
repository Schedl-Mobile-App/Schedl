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
                        Image(systemName: "house.fill")
                    }
                    
                    NavigationStack {
                        ScheduleView(currentUser: user)
                            .ignoresSafeArea(.all)
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                    }
                    
                    NavigationStack {
                        SearchView(currentUser: user)
                    }
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    NavigationStack {
                        ProfileView(currentUser: user, profileUser: user)
                    }
                    .tabItem {
                        Image(systemName: "person")
                    }
                }
                .background(Color(hex: 0xf7f4f2))
                .accentColor(Color.primary)
                .navigationBarBackButtonHidden(true)
            }
        } else {
            LoginView()
        }
    }
}
