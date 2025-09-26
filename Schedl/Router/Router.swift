//
//  Router.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI
import MapKit

enum PageDestination: Hashable, View {
    // Destinations from both contexts
    case friends(profileUser: User)
    case eventDetails(currentUser: User, event: RecurringEvents, scheduleId: String)
    case editEvent(vm: EventViewModel)
    case createEvent(currentUser: User, scheduleId: String)
    
    // destinations exclusive for the schedule view
    case schedule(currentUser: User)
    
    // destinations exclusive for the profile view
    case profile(currentUser: User, profileUser: User, preferBackButton: Bool)

    @ViewBuilder
    var body: some View {
        switch self {
        case .friends(let user):
            FriendsView(profileUser: user)
        case .eventDetails(let user, let event, let scheduleId):
            FullEventDetailsView(recurringEvent: event, currentUser: user, currentScheduleId: scheduleId)
        case .editEvent(let vm):
            EditEventView(vm: vm)
        case .createEvent(let user, let scheduleId):
            CreateEventView(currentUser: user, currentScheduleId: scheduleId)
        case .schedule(let user):
            ScheduleView(currentUser: user)
        case .profile(let currentUser, let profileUser, let preferBackButton):
            ProfileView(currentUser: currentUser, profileUser: profileUser, preferBackButton: preferBackButton)
        }
    }
}

enum SheetDestination: Identifiable, View {
    case eventDate(date: Binding<Date?>)
    case eventTime(time: Binding<Date?>)
    case color(color: Binding<Color>)
    case invitedUsers(currentUser: User, selectedFriends: Binding<[User]>)
    case eventSearch(currentUser: User, events: [RecurringEvents])
    case locationSearch(listPlacemarks: Binding<[MTPlacemark]>, visibleRegion: Binding<MKCoordinateRegion?>, detailPlacemark: Binding<MTPlacemark?>)
    case locationDetail(detailPlacemark: MTPlacemark, selectedPlacemark: Binding<MTPlacemark?>)
    
    var id: String {
        switch self {
        case .eventDate:
            return "eventDate"
        case .eventTime:
            return "eventTime"
        case .color:
            return "color"
        case .invitedUsers:
            return "invitedUsers"
        case .eventSearch:
            return "eventSearch"
        case .locationSearch:
            return "locationSearch"
        case .locationDetail:
            return "locationDetail"
        }
    }
    
    var body: some View {
        switch self {
        case .eventDate(let date):
            DatePickerView(date: date)
        case .eventTime(let time):
            TimePickerView(time: time)
        case .color(let color):
            ColorPickerSheet(selectedColor: color)
        case .invitedUsers(let user, let selectedFriends):
            AddInvitedUsers(currentUser: user, selectedFriends: selectedFriends)
        case .eventSearch(let user, let events):
            EventSearchView(currentUser: user, scheduleEvents: events)
        case .locationSearch(let listPlacemarks, let visibleRegion, let detailPlacemark):
            MapSearchView(listPlacemarks: listPlacemarks, visibleRegion: visibleRegion, detailPlacemark: detailPlacemark)
        case .locationDetail(let detailPlacemark, let selectedPlacemark):
            LocationDetailView(selectedPlacemark: selectedPlacemark, detailPlacemark: detailPlacemark)
        }
    }
}

enum CoverDestination: Identifiable, View {
    case location(selectedPlacemark: Binding<MTPlacemark?>)
    
    var id: String {
        switch self {
        case .location:
            return "location"
        }
    }
    
    var body: some View {
        switch self {
        case .location(let selectedPlacemark):
            LocationView(selectedPlacemark: selectedPlacemark)
        }
    }
}

protocol Router: AnyObject, Observable {
    var path: NavigationPath { get set }
    
    var sheet: SheetDestination? { get set }
    var cover: CoverDestination? { get set }
    
    func push(page: PageDestination)
    func pop(_ last: Int)
    func popToRoot()
    func present(sheet: SheetDestination)
    func present(cover: CoverDestination)
    func dismissSheet()
    func dismissCover()

}

extension Router {
    
    func push(page: PageDestination) {
        path.append(page)
    }
    
    func pop(_ last: Int = 1) {
        path.removeLast(last)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: SheetDestination) {
        self.sheet = sheet
    }
    
    func present(cover: CoverDestination) {
        self.cover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissCover() {
        self.cover = nil
    }
}

class AnyRouter: Router {
    var path = NavigationPath()
    var sheet: SheetDestination?
    var cover: CoverDestination?
}

struct RouterKey: EnvironmentKey {
    // The default value if no router is provided
    static var defaultValue: any Router = AnyRouter()
}

extension EnvironmentValues {
    // The property you will use to access the router
    var router: any Router {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

