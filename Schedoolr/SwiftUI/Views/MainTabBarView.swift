import SwiftUI

struct MainTabBarView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if let user = authViewModel.currentUser {
            Group {
                TabView {
                    FeedView(currentUser: user)
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                    ScheduleView(currentUser: user)
                        .ignoresSafeArea(.all)
                        .tabItem {
                            Image(systemName: "calendar")
                        }
                    SearchView(currentUser: user)
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                        }
                    ProfileView(currentUser: user, profileUserId: user.id)
                        .tabItem {
                            Image(systemName: "person")
                        }
                }
                .accentColor(Color.primary)
                .navigationBarBackButtonHidden(true)
            }
        } else {
            LoginView()
        }
    }
}
