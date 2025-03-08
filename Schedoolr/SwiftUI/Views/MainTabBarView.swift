import SwiftUI

struct MainTabBarView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        if authService.isLoggedIn {
            Group {
                TabView {
                    FeedView()
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                    ScheduleView()
                        .ignoresSafeArea(.all)
                        .tabItem {
                            Image(systemName: "calendar")
                        }
                    SearchView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                        }
                    ProfileView(userid: authService.currentUser?.id ?? "")
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
