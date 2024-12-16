import SwiftUI

struct MainTabBarView: View {
    @EnvironmentObject var userObj: AuthService
    
    var body: some View {
        TabView {
            
            FeedView()
                .tabItem {
                    Label("My Feed", systemImage: "house")
                }
            
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            
<<<<<<< Updated upstream
            FriendsView()
=======
            FriendsView(userObj: userObj)
>>>>>>> Stashed changes
                .tabItem {
                    Label("Friends", systemImage: "person.circle")
                }
        
            AccountView()
                .tabItem {
                    Label("My Account", systemImage: "person")
                }
        }
        .accentColor(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}
