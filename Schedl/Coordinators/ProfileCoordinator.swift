//
//  ProfileCoordinator.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI

@Observable
class ProfileCoordinator: Router {
    var path = NavigationPath()
    
    var sheet: SheetDestination?
    var cover: CoverDestination?
}

struct ProfileCoordinatorView: View {
    
    @State private var coordinator = ProfileCoordinator()
    let currentUser: User
    let profileUser: User
    let prefersBackButton: Bool
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PageDestination.profile(currentUser: currentUser, profileUser: profileUser, preferBackButton: prefersBackButton)
                .navigationDestination(for: PageDestination.self) { $0 }
                .sheet(item: $coordinator.sheet) { $0 }
                .fullScreenCover(item: $coordinator.cover) { $0 }
        }
        .environment(\.router, coordinator)
    }
}
