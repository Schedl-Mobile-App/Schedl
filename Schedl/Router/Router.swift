//
//  Router.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI
import MapKit

//let navigationBarAppearance = UINavigationBarAppearance()
//navigationBarAppearance.configureWithTransparentBackground()
//navigationBarAppearance.backgroundColor = UIColor(Color("CalendarNavigationBackground"))
//navigationBarAppearance.shadowColor = .clear
//navigationBarAppearance.shadowImage = UIImage()
//
//UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

enum PageDestination: Hashable, View {
    
    // schedule navigation
//    case calendarYearView(vm: ScheduleViewModel, centerYear: Date)
//    case calendarMonthView(vm: ScheduleViewModel, centerMonth: Date)
//    case calendarWeekView(vm: ScheduleViewModel, centerDay: Date)
    
    // profile navigation
    case profile(currentUser: User, profileUser: User, preferBackButton: Bool, namespace: Namespace.ID? = nil)
    case settings(currentUser: User)
    
    // feed navigation
    case feed(currentUser: User)
    case notifications(currentUser: User)
    
    // seach navigation
    case search(currentUser: User)
    
    // shared navigation
    case friends(profileUser: User)
    case eventDetails(currentUser: User, event: EventOccurrence, namespace: Namespace.ID? = nil)
    case editEvent(vm: EventViewModel)
    case createEvent(currentUser: User, scheduleId: String? = nil, namespace: Namespace.ID? = nil)
    case locationView(placemark: MTPlacemark)
    
    var shouldHideTabbar: Bool {
        switch self {
        case .friends, .eventDetails, .editEvent, .createEvent, .settings, .notifications, .locationView:
            return true
        case .feed, .profile, .search:
            return false
        }
    }

    @ViewBuilder
    var body: some View {
        switch self {
            
        // profile navigation
        case .profile(let currentUser, let profileUser, let preferBackButton, let namespace):
            if namespace != nil {
                ProfileView(currentUser: currentUser, profileUser: profileUser, preferBackButton: preferBackButton)
                    .navigationTransition(.zoom(sourceID: "zoom", in: namespace!))
            } else {
                ProfileView(currentUser: currentUser, profileUser: profileUser, preferBackButton: preferBackButton)
            }
                
        case .settings(let user):
            SettingsView(currentUser: user)
            
        // feed navigation
        case .feed(let user):
            FeedView(currentUser: user)
        case .notifications(let user):
            NotificationsView(currentUser: user)
            
        // search navigation
        case .search(let user):
            SearchView(currentUser: user)
            
        // shared navigation
        case .locationView(let placemark):
            SelectedLocationView(desiredPlacemark: placemark)
        case .friends(let user):
            FriendsView(profileUser: user)
        case .eventDetails(let currentUser, let event, let namespace):
            if namespace != nil {
                FullEventDetailsView(event: event, currentUser: currentUser)
                    .navigationTransition(.zoom(sourceID: "zoom", in: namespace!))
            } else {
                FullEventDetailsView(event: event, currentUser: currentUser)
            }
        case .editEvent(let vm):
            EditEventView(vm: vm)
        case .createEvent(let user, let scheduleId, let namespace):
            if namespace != nil {
                CreateEventView(currentUser: user, currentScheduleId: scheduleId)
                    .navigationTransition(.zoom(sourceID: "zoom", in: namespace!))
            } else {
                CreateEventView(currentUser: user, currentScheduleId: scheduleId)
            }
        }
    }
}

enum SheetDestination: Identifiable, View {
    
    // create/edit event sheets
    case eventDate(date: Binding<Date?>)
    case eventTime(time: Binding<Date?>)
    case color(color: Binding<Color>)
    case invitedUsers(currentUser: User, selectedFriends: Binding<[User]>)
    case eventSearch(currentUser: User, events: [EventOccurrence])
    case locationSearch(listPlacemarks: Binding<[MTPlacemark]>, visibleRegion: Binding<MKCoordinateRegion?>, detailPlacemark: Binding<MTPlacemark?>)
    case locationDetail(detailPlacemark: MTPlacemark, selectedPlacemark: Binding<MTPlacemark?>)
    
    // profile sheets
    case editProfile
    
    // feed sheets
    
    
    var id: String {
        switch self {
            
        // create/edit event sheets
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
            
        // profile sheets
        case .editProfile:
            return "editProfile"
        }
    }
    
    var body: some View {
        switch self {
            
        // create/edit event sheets
        case .eventDate(let date):
            DatePickerView(date: date)
        case .eventTime(let time):
            TimePickerView(time: time)
        case .color(let color):
            ColorPickerSheet(selectedColor: color)
        case .invitedUsers(let user, let selectedFriends):
            AddInvitedUsers(currentUser: user, selectedFriends: selectedFriends)
        case .eventSearch(let user, let events):
            EventSearchView(currentUser: user)
        case .locationSearch(let listPlacemarks, let visibleRegion, let detailPlacemark):
            MapSearchView(listPlacemarks: listPlacemarks, visibleRegion: visibleRegion, detailPlacemark: detailPlacemark)
        case .locationDetail(let detailPlacemark, let selectedPlacemark):
            LocationDetailView(selectedPlacemark: selectedPlacemark, detailPlacemark: detailPlacemark)
            
        // profile sheets
        case .editProfile:
            EditProfileView()
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

// Define a dummy class of our Router to use when configuring the default
// value for the environment value

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
    // This will allow us set the value of our environment with any coordinator
    // that conforms to the Router protocol
    var router: any Router {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

