
import SwiftUI

class TabBarState: ObservableObject {
    @Published var hideTabbar: Bool = false
}

struct MainTabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var tabBarState: TabBarState = TabBarState()
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        if let user = authViewModel.currentUser {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    FeedView(currentUser: user)
                }
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }
                .tag(0)
                
                ZStack {
                    Color(hex: 0xf7f4f2)
                        .ignoresSafeArea()
                    
                    ScheduleView(currentUser: user)
                        .ignoresSafeArea(edges: [.top, .bottom])
                        .environmentObject(tabBarState)
                }
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(1)
                
                NavigationStack {
                    SearchView(currentUser: user)
                        .environmentObject(authViewModel)
                        .environmentObject(tabBarState)
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
                
                NavigationStack {
                    ProfileView(currentUser: user, profileUser: user)
                        .environmentObject(authViewModel)
                        .environmentObject(tabBarState)
                }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
            }
            .navigationBarBackButtonHidden(true)
            .onChange(of: selectedTab) { _, oldValue in
                // Animate tab bar items (this requires accessing the UITabBar)
                DispatchQueue.main.async {
                    animateTabBarSelection()
                }
                
                previousTab = oldValue
            }
            .onAppear {
                setupTabBarAppearance()
            }
        } else {
            LoginView()
        }
    }
    
    private func setupTabBarAppearance(transparentBackground: Bool = false) {
        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
//        tabBarAppearance.shadowColor = .clear
//        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.configureWithTransparentBackground()
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func animateTabBarSelection() {
        // Find the current tab bar
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let tabBar = findTabBar(in: window) {
            
            // Animate the selected tab item
            animateSelectedTabBarItem(tabBar: tabBar, selectedIndex: selectedTab)
        }
    }
    
    private func findTabBar(in view: UIView) -> UITabBar? {
        if let tabBar = view as? UITabBar {
            return tabBar
        }
        
        for subview in view.subviews {
            if let tabBar = findTabBar(in: subview) {
                return tabBar
            }
        }
        
        return nil
    }
    
    private func animateSelectedTabBarItem(tabBar: UITabBar, selectedIndex: Int) {
        // Get all tab bar button views
        let tabBarItemViews = tabBar.subviews.filter {
            $0.isKind(of: NSClassFromString("UITabBarButton")!)
        }
        
        guard selectedIndex < tabBarItemViews.count else { return }
        
        let selectedItemView = tabBarItemViews[selectedIndex]
        
        // Apply pulse animation
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            selectedItemView.transform = CGAffineTransform(scaleX: 0.9, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                selectedItemView.transform = CGAffineTransform.identity
            })
        }
    }
}
