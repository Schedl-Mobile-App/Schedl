//
//  SearchCoordinator.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI

enum SearchCoordinatorSheet: Identifiable, View {
    case editProfile(vm: ProfileViewModel)
    
    var id: String {
        switch self {
        case .editProfile:
            return "editProfile"
        }
    }
    
    var body: some View {
        switch self {
        case .editProfile:
            EmptyView()
        }
    }
}

@Observable
class SearchCoordinator: Router {
    var path = NavigationPath()
    
    var sheet: SheetDestination?
    var cover: CoverDestination?
}

struct SearchCoordinatorView: View {
    
    @Environment(\.tabBar) var tabBar: TabBarViewModel
    @State private var coordinator = SearchCoordinator()
    var currentUser: User
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PageDestination.search(currentUser: currentUser)
                .navigationDestination(for: PageDestination.self) { destination in
                    if destination.shouldHideTabbar {
                        tabBar.isTabBarHidden = true
                    } else {
                        tabBar.isTabBarHidden = false
                    }
                    return destination
                }
                .sheet(item: $coordinator.sheet) { $0 }
                .fullScreenCover(item: $coordinator.cover) { $0 }
                .onAppear {
                    tabBar.isTabBarHidden = false
                }
//                .onDisappear {
//                    if !coordinator.path.isEmpty {
//                        tabBar.isTabBarHidden = true
//                    }
//                }
        }
        .toolbar(tabBar.isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .environment(\.router, coordinator)
    }
}


