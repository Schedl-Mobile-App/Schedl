import SwiftUI

enum currentTabItem {
    case feed, schedule, profile, search
}

struct MainTabBarView: View {
    
    @EnvironmentObject private var vm: AuthViewModel
    @State private var currentTab: currentTabItem = .feed
    
    var body: some View {
        if let user = vm.currentUser {
            TabView(selection: $currentTab) {
                Tab("Feed", systemImage: "house", value: .feed) {
                    FeedCoordinatorView(currentUser: user)
                }
                
                Tab("Schedule", systemImage: "calendar", value: .schedule) {
                    CalendarYearView(currentUser: user, centerYear: createCenterYear())
                        .ignoresSafeArea(edges: [.bottom, .top])
                }
                
                if #available(iOS 26.0, *) {
                    Tab("Profile", systemImage: "person", value: .profile) {
                        ProfileCoordinatorView(currentUser: user, profileUser: user, prefersBackButton: false)
                    }
                    
                    Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                        SearchCoordinatorView(currentUser: user)
                    }
                } else {
                    Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                        SearchCoordinatorView(currentUser: user)
                    }
                    
                    Tab("Profile", systemImage: "person", value: .profile) {
                        ProfileCoordinatorView(currentUser: user, profileUser: user, prefersBackButton: false)
                    }
                }
            }
            .tint(Color("AccentColor"))
            .navigationBarBackButtonHidden(true)
            .modifier(TabbarViewModifier(currentTab: currentTab))
        } else {
            LoginView()
        }
    }
    
        func createCenterYear() -> Date {
            let yearComponent = Calendar.current.dateComponents([.year], from: Date())
            return Calendar.current.date(from: yearComponent)!
        }
}


struct TabbarViewModifier: ViewModifier {
    
    @Environment(\.tabBar) var tabBar: TabBarViewModel
    var currentTab: currentTabItem
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .tabViewStyle(.sidebarAdaptable)
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory(content: {
                    switch currentTab {
                    case .feed:
                        EmptyView()
                    case .schedule:
                        if tabBar.isTabBarHidden {
                            EmptyView()
                        } else {
                            Button(action: {
                                
                            }, label: {
                                Text("David's Schedule")
                                    .fontWeight(.semibold)
                                    .font(.headline)
                            })
                        }
                    case .profile:
                        EmptyView()
                    case .search:
                        EmptyView()
                    }
                })
        } else {
            content
        }
    }
}

