//
//  SearchCoordinator.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI

enum SearchCoordinatorPage: Hashable, View {
    case search(currentUser: User)
    case profile(currentUser: User, profileUser: User, prefersBackButton: Bool)
    case eventDetails(event: RecurringEvents, currentUser: User, scheduleId: String)
    case editEvent(vm: EventViewModel)
    
    var body: some View {
        switch self {
        case .search(let user):
            SearchView(currentUser: user)
        case .profile(let currentUser, let profileUser, let prefersBackButton):
            ProfileView(currentUser: currentUser, profileUser: profileUser, preferBackButton: prefersBackButton)
        case .eventDetails(let event, let user, let scheduleId):
            FullEventDetailsView(recurringEvent: event, currentUser: user, currentScheduleId: scheduleId)
        case .editEvent(let vm):
            EditEventView(vm: vm)
        }
    }
}

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

extension EnvironmentValues {
    @Entry var searchCoordinator = SearchCoordinator()
}

@Observable
class SearchCoordinator {
    var path = NavigationPath()
    
    var sheet: SearchCoordinatorSheet?
    
    func push(page: SearchCoordinatorPage) {
        path.append(page)
    }
    
    func pop(_ last: Int = 1) {
        path.removeLast(last)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: SearchCoordinatorSheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
}

struct SearchCoordinatorView: View {
    
    @State private var coordinator = SearchCoordinator()
    var currentUser: User
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SearchCoordinatorPage.search(currentUser: currentUser)
                .navigationDestination(for: SearchCoordinatorPage.self) { $0 }
                .sheet(item: $coordinator.sheet) { $0 }
                
        }
        .environment(\.searchCoordinator, coordinator)
    }
}


