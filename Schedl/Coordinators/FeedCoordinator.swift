//
//  FeedCoordinator.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI

@Observable
class FeedCoordinator: Router {
    var path = NavigationPath()
    
    var sheet: SheetDestination?
    var cover: CoverDestination?
}

struct FeedCoordinatorView: View {
    
    @Environment(\.tabBar) var tabBar: TabBarViewModel
    @State private var coordinator = FeedCoordinator()
    let currentUser: User
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PageDestination.feed(currentUser: currentUser)
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
                .onDisappear {
                    if !coordinator.path.isEmpty {
                        tabBar.isTabBarHidden = true
                    }
                }
        }
        .toolbar(tabBar.isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .environment(\.router, coordinator)
    }
}
