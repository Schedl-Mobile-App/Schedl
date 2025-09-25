import SwiftUI

class TabBarState: ObservableObject {
    @Published var hideTabbar: Bool = false
}

enum MainTab: Hashable {
    case feed, schedule, search, profile
}

enum ScheduleDestinations: Hashable {
    // You'll need to make RecurringEvents Hashable
    case eventDetails(event: RecurringEvents, currentUser: User, scheduleId: String)
    case editEvent(vm: EventViewModel)
}

struct MainTabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var tabBarState: TabBarState = TabBarState()
    @State var searchText = ""
    @State var activeTab: MainTab = .feed
    
    @State private var path = NavigationPath()
    
    var body: some View {
        if let user = authViewModel.currentUser {
            TabView(selection: $activeTab) {
                if #available(iOS 26.0, *) {
                    Tab("Feed", systemImage: "house", value: MainTab.feed) {
                        NavigationStack {
                            FeedView(currentUser: user)
                                .environmentObject(tabBarState)
                        }
                    }
                } else {
                    Tab("Feed", systemImage: "house", value: MainTab.feed) {
                        NavigationStack {
                            FeedView(currentUser: user)
                                .environmentObject(tabBarState)
                        }
                    }
                }
                
                Tab("Schedule", systemImage: "calendar", value: MainTab.schedule) {
                    NavigationStack(path: $path) {
                        ZStack {
                            Color(hex: 0xf7f4f2)
                                .ignoresSafeArea()
                            
                            ScheduleView(currentUser: user, onShowEventDetails: { event, currentUser, scheduleId in
                                path.append(ScheduleDestinations.eventDetails(event: event, currentUser: currentUser, scheduleId: scheduleId))
                            })
                                .ignoresSafeArea(edges: [.top, .bottom])
                                .background { Color("BackgroundColor") }
                                .environmentObject(tabBarState)
                                .navigationTitle("Schedule")
                                .navigationDestination(for: ScheduleDestinations.self) { destination in
                                    switch destination {
                                    case .eventDetails(let event, let user, let scheduleId):
                                        FullEventDetailsView(recurringEvent: event, currentUser: user, currentScheduleId: scheduleId)
                                    case .editEvent(vm: let vm):
                                        EditEventView(vm: vm)
                                    }
                                }
                        }
                    }
                }
                
                if #available(iOS 26.0, *) {
                    Tab("Profile", systemImage: "person", value: MainTab.profile) {
                        NavigationStack {
                            ProfileView(currentUser: user, profileUser: user, preferBackButton: false)
                                .environmentObject(authViewModel)
                                .environmentObject(tabBarState)
                        }
                    }
                    
                    Tab("Search", systemImage: "magnifyingglass", value: MainTab.search, role: .search) {
                        NavigationStack {
                            SearchView(currentUser: user)
                                .environmentObject(authViewModel)
                                .environmentObject(tabBarState)
                        }
                    }
                } else {
                    Tab("Search", systemImage: "magnifyingglass", value: MainTab.search, role: .search) {
                        NavigationStack {
                            SearchView(currentUser: user)
                                .environmentObject(authViewModel)
                                .environmentObject(tabBarState)
                        }
                    }
                    
                    Tab("Profile", systemImage: "person", value: MainTab.profile) {
                        NavigationStack {
                            ProfileView(currentUser: user, profileUser: user, preferBackButton: false)
                                .environmentObject(authViewModel)
                                .environmentObject(tabBarState)
                        }
                    }
                }
            }
            .tint(Color("AccentColor"))
            .navigationBarBackButtonHidden(true)
            .modifier(TabbarViewModifier(activeTab: $activeTab))
        } else {
            LoginView()
        }
    }
}


struct TabbarViewModifier: ViewModifier {
    @Binding var activeTab: MainTab
    
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

