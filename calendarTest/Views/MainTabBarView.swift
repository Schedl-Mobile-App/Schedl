import SwiftUI

struct MainTabBarView: View {
    @StateObject var userObj: AuthService
    
    init(userObj: AuthService = AuthService()) {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black.withAlphaComponent(0.5)
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
        _userObj = StateObject(wrappedValue: userObj)
    }
    
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
        
            AccountView(userObj: userObj)
                .tabItem {
                    Label("My Account", systemImage: "person")
                }
        }
        .accentColor(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabBarView(userObj: AuthService())
}
