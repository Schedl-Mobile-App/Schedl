import SwiftUI

@Observable
class TabBarState {
    var hideTabbar: Bool = false
}

struct MainTabBarView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if let user = authViewModel.currentUser {
            TabView {
                if #available(iOS 26.0, *) {
                    Tab("Feed", systemImage: "house") {
                        NavigationStack {
                            FeedView(currentUser: user)
                        }
                    }
                } else {
                    Tab("Feed", systemImage: "house") {
                        NavigationStack {
                            FeedView(currentUser: user)
                        }
                    }
                }
                
                Tab("Schedule", systemImage: "calendar") {
                    SchedulesCoordinatorView(currentUser: user)
                }
                
                if #available(iOS 26.0, *) {
                    Tab("Profile", systemImage: "person") {
                        ProfileCoordinatorView(currentUser: user, profileUser: user, prefersBackButton: false)
                    }
                    
                    Tab("Search", systemImage: "magnifyingglass", role: .search) {
                        SearchCoordinatorView(currentUser: user)
                    }
                } else {
                    Tab("Search", systemImage: "magnifyingglass", role: .search) {
                        SearchCoordinatorView(currentUser: user)
                    }
                    
                    Tab("Profile", systemImage: "person") {
                        ProfileCoordinatorView(currentUser: user, profileUser: user, prefersBackButton: false)
                    }
                }
            }
            .tint(Color("AccentColor"))
            .navigationBarBackButtonHidden(true)
            .modifier(TabbarViewModifier())
        } else {
            LoginView()
        }
    }
}


struct TabbarViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
                .onAppear {
                    setupTabBarAppearance()
                }
        }
    }
    
    private func setupTabBarAppearance(transparentBackground: Bool = false) {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color("BackgroundColor"))
        tabBarAppearance.shadowColor = nil
        tabBarAppearance.shadowImage = nil
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color("BackgroundColor"))
        navBarAppearance.shadowColor = nil
        navBarAppearance.shadowImage = nil
        
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.configureWithTransparentBackground()
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = compactAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = compactAppearance
    }
}

