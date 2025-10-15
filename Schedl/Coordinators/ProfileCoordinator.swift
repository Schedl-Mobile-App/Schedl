//
//  ProfileCoordinator.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct ScheduleEventCard: View {
    
    let events: [EventOccurrence]
    let key: Date
    let todayStart = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
    
    func returnTimeFormatted(for time: Int) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(TimeInterval(time))
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    func eventHasEnded(startTime: Int, on date: Date) -> Bool {
        let eventTime = Calendar.current.date(byAdding: .hour, value: startTime, to: Calendar.current.startOfDay(for: date))
        let currentTime = Date()
        
        if let eventTime {
            return eventTime < currentTime
        }
        
        return false
    }
    
    var dayText: String {
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: key)
        if let weekday = dateComponent.weekday {
            return Calendar.current.weekdaySymbols[weekday - 1]
        }
        
        return ""
    }
    
    var monthText: String {
        return key.relativeDayString
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            LazyVStack( alignment: .leading, spacing: 8) {
                HStack {
                    Text(dayText)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .tracking(-0.25)
                        .foregroundStyle(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(monthText)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("SecondaryText"))
                        .lineLimit(1)
                }
                
                ForEach(events, id: \.id) { event in
                    HStack(spacing: 12) {
                        Text("\(event.event.title)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color("PrimaryText"))
                            .tracking(1)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .strikethrough(eventHasEnded(startTime: event.event.startTime, on: event.recurringDate), color: Color(.black))
                        
                        Spacer(minLength: 6)

                        Text(returnTimeFormatted(for: event.event.startTime))
                            .font(.system(size: 13, weight: .medium))
                            .monospacedDigit()
                            .foregroundStyle(Color("SecondaryText"))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .strikethrough(eventHasEnded(startTime: event.event.startTime, on: event.recurringDate), color: Color(.black))
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .padding(.trailing, 10)
        .padding(.leading, 20)
        .background(
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                
                Color(.systemBlue)
                    .frame(width: 7)
                    .frame(maxHeight: .infinity)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EventCard: View {
    
    var event: EventOccurrence
    
    func returnTimeFormatted(for time: Int) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(TimeInterval(time))
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    func getEventDateAndTime(for date: Date, with startTime: Int) -> String {
        let dateText = date.relativeDayString
        let timeText = returnTimeFormatted(for: startTime)
        return "\(dateText) - \(timeText)"
        
        // \(String(format: "%02d", dayOfMonth))
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack( alignment: .leading, spacing: 8) {
                Text("\(event.event.title)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 8) {
                    Text("📆")
                        .font(.footnote)
                    HStack(spacing: 0) {
                        Text(getEventDateAndTime(for: event.recurringDate, with: event.event.startTime))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .tracking(0.75)
                            .foregroundStyle(Color("SecondaryText"))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                HStack(spacing: 8) {
                    Text("📍")
                        .font(.footnote)
                    
                    Text(event.event.location.address)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .tracking(0.75)
                        .foregroundStyle(Color("SecondaryText"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.top, 8)
            
        }
        .padding(.leading, 20)
        .padding(.trailing, 10)
        .frame(minHeight: 90)
        .background(
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                
                Color(hex: Int(event.event.color, radix: 16)!)
                    .frame(width: 7)
                    .frame(maxHeight: .infinity)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}




@Observable
class ProfileCoordinator: Router {
    var path = NavigationPath()
    
    var sheet: SheetDestination?
    var cover: CoverDestination?
}

struct ProfileCoordinatorView: View {
    
    @Environment(\.tabBar) var tabBar: TabBarViewModel
    @State private var coordinator = ProfileCoordinator()
    let currentUser: User
    let profileUser: User
    let prefersBackButton: Bool
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PageDestination.profile(currentUser: currentUser, profileUser: profileUser, preferBackButton: prefersBackButton)
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

#Preview {
    
    let user = MockUserFactory.createUser()
    let scheduleService = MockScheduleService(userId: user.id, name: user.displayName)
    let eventService = MockEventService(userId: user.id)
    let userService = MockUserService(user: user)
    
    NavigationStack {
        ProfileView(currentUser: user, profileUser: user, preferBackButton: false, scheduleService: scheduleService, eventService: eventService, userService: userService)
    }
}

import PhotosUI
import Kingfisher

enum ProfileDestinations: Hashable {
    case eventDetails(EventOccurrence)
    case settings
    case createEvent
    case friendsView
}

struct Profile_ScheduleDayCards: View {
    
    var schedules: [Schedule]
    @Binding var currentSchedule: Schedule?
    
    var partitionedEvents: [Date: [EventOccurrence]]
    
    var sortedKeys: [Date] {
        return Array(partitionedEvents.keys).sorted(by: <)
    }
    
    func returnPartionedEvents(forKey key: Date) -> [EventOccurrence] {
        guard let events = partitionedEvents[key] else { return [] }
        return events
    }
    
    var body: some View {
        if sortedKeys.isEmpty {
            //            NavigationLink(value: , label: {
            //                Text(profileViewModel.isViewingFriend ? "\(profileViewModel.profileUser.displayName.split(separator: " ").first!) has no upcoming events. Tell them that they should create some!" : "No upcoming events. Tap anywhere here to create one!")
            //                    .font(.subheadline)
            //                    .fontDesign(.monospaced)
            //                    .tracking(-0.25)
            //                    .fontWeight(.medium)
            //                    .foregroundStyle(Color("SecondaryText"))
            //                    .multilineTextAlignment(.center)
            //                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            //                    .padding(.horizontal, 25)
            //            })
        } else {
            LazyVStack {
                ForEach(sortedKeys, id: \.self) { key in
                    ScheduleEventCard(events: returnPartionedEvents(forKey: key), key: key)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct Profile_EventCards: View {
    
    @Environment(\.router) var router: Router
    @Namespace private var namespace
    
    var selectedType: ProfileEventType
    
    var currentEvents: [EventOccurrence]
    var invitedEvents: [EventOccurrence]
    var pastEvents: [EventOccurrence]
    
    let currentUser: User
    
    var body: some View {
        VStack(spacing: 15) {
            LazyVStack {
                switch selectedType {
                case .upcoming:
                    if currentEvents.isEmpty {
                        Spacer()
                            .frame(height: 125)
                        Button(action: {
                            router.push(page: .createEvent(currentUser: currentUser, namespace: namespace))
                        }, label: {
                            Text("No upcoming events. Tap anywhere here to create one!")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("SecondaryText"))
                                .multilineTextAlignment(.center)
                                .matchedTransitionSource(id: "zoom", in: namespace)
                        })
                    } else {
                        ForEach(currentEvents, id: \.id) { event in
                            Button(action: {
                                router.push(page: .eventDetails(currentUser: currentUser, event: event, namespace: namespace))
                            }, label: {
                                EventCard(event: event)
                                    .matchedTransitionSource(id: "zoom", in: namespace)
                            })
                        }
                    }
                    
                case .invited:
                    if invitedEvents.isEmpty {
                        Spacer()
                            .frame(height: 125)
                        Text("You haven't been invited to any upcoming events yet. Text your friends to invite you!")
                            .font(.subheadline)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("SecondaryText"))
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(invitedEvents, id: \.self.id) { event in
                            Button(action: {
                                router.push(page: .eventDetails(currentUser: currentUser, event: event, namespace: namespace))
                            }, label: {
                                EventCard(event: event)
                                    .matchedTransitionSource(id: "zoom", in: namespace)
                            })
                        }
                    }
                    
                case .past:
                    if pastEvents.isEmpty {
                        Spacer()
                            .frame(height: 125)
                        Button(action: {
                            router.push(page: .createEvent(currentUser: currentUser, namespace: namespace))
                        }, label: {
                            Text("You have no past events to show. Try creating one by tapping here!")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("SecondaryText"))
                                .multilineTextAlignment(.center)
                        })
                    } else {
                        ForEach(pastEvents, id: \.self.id) { event in
                            Button(action: {
                                router.push(page: .eventDetails(currentUser: currentUser, event: event, namespace: namespace))
                            }, label: {
                                EventCard(event: event)
                                    .matchedTransitionSource(id: "zoom", in: namespace)
                            })
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
    }
}

struct Profile_ActivityCards: View {
    
    var posts: [Post]
    
    var body: some View {
        if posts.isEmpty {
            Spacer()
                .frame(height: 150)
            Button(action: {
                // make this into a navigation link when create posts are up
            }) {
                Text("No activity to show here yet. Tap anywhere here to create your first post!")
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("SecondaryText"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
            }
        } else {
            Spacer()
                .frame(height: 125)
            ScrollView(.vertical, showsIndicators: false) {
                Text("Posts go here")
            }
            .padding(.horizontal, 25)
        }
    }
}

enum ProfileEventType: CaseIterable {
    case upcoming
    case invited
    case past
    
    var name: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .invited: return "Invited"
        case .past: return "Past"
        }
    }
}

import UIKit

struct ProfileView: View {
    
    @StateObject var vm: ProfileViewModel
    
    @Environment(\.router) var coordinator: Router
    @Environment(\.tabBar) var tabBar: TabBarViewModel
    @Environment(\.dismiss) var dismiss
    
    @Namespace private var animation
    
    @State var preferBackButton: Bool
        
    init(currentUser: User, profileUser: User, preferBackButton: Bool) {
        _vm = StateObject(wrappedValue: ProfileViewModel(currentUser: currentUser, profileUser: profileUser))
        _preferBackButton = State(initialValue: preferBackButton)
    }
    
    init(currentUser: User, profileUser: User, preferBackButton: Bool, scheduleService: ScheduleServiceProtocol, eventService: EventServiceProtocol, userService: UserServiceProtocol) {
        _vm = StateObject(wrappedValue: ProfileViewModel(userService: userService, scheduleService: scheduleService, eventService: eventService, currentUser: currentUser, profileUser: profileUser))
        _preferBackButton = State(initialValue: preferBackButton)
    }
    
    var displayName: String {
        let splitName = vm.profileUser.displayName.split(separator: " ")
        guard let firstName = splitName.first else { return "Anon" }
        return String(firstName)
    }
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProfileLoadingView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(/*pinnedViews: .sectionHeaders*/) {
                        Section {
                            VStack(alignment: .center, spacing: 15) {
                                UserProfileImage(profileImage: vm.profileUser.profileImage, displayName: vm.profileUser.displayName)
                                
                                Text(displayName)
                                    .foregroundStyle(Color("PrimaryText"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .tracking(1)
                                
                                ProfileInformatics(friendsCount: vm.profileUser.numOfFriends, eventsCount: vm.profileUser.numOfEvents, postsCount: vm.profileUser.numOfPosts, profileUser: vm.profileUser)
                            }
                        }
                        
                        Section(content: {
                            // user is either viewing their profile or a friend's profile
                            if vm.showProfileDetails {
                                switch vm.profileViewType {
                                case .schedules:
                                    Profile_ScheduleDayCards(schedules: vm.schedules, currentSchedule: $vm.currentSchedule, partitionedEvents: vm.partitionedEvents)
                                case .events:
                                    Profile_EventCards(selectedType: vm.profileEventViewType, currentEvents: vm.currentEvents, invitedEvents: vm.invitedEvents, pastEvents: vm.pastEvents, currentUser: vm.currentUser)
                                case .activity:
                                    Profile_ActivityCards(posts: vm.posts)
                                }
                                
                                // user is viewing a public profile who is not their friend
                            } else {
                                Button(action: {
                                    vm.showAddFriendAlert = true
                                }) {
                                    Text("You can't see \(vm.getFirstName())'s schedule until you add them as a friend. Click anywhere here to request them!")
                                        .font(.subheadline)
                                        .fontDesign(.monospaced)
                                        .tracking(-0.25)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color("SecondaryText"))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 25)
                                }
                                .alert(isPresented: $vm.showAddFriendAlert) {
                                    if vm.friendRequestPending {
                                        Alert(title: Text("Friend Request Pending"),
                                              message: Text("There's already a pending friend request with \(vm.getFirstName()). Either check your notifications or wait for them to respond!"),
                                              dismissButton: .default(Text("Ok"), action: {
                                            vm.showAddFriendAlert = false
                                        }))
                                    } else {
                                        Alert(title: Text("Send Friend Request"),
                                              message: Text("Would you like to send \(vm.getFirstName()) a friend request?"),
                                              primaryButton: .destructive(Text("Cancel"), action: {
                                            vm.showAddFriendAlert = false
                                        }), secondaryButton: .default(Text("Send"), action: {
                                            Task {
                                                await vm.sendFriendRequest()
                                            }
                                        }))
                                    }
                                }
                            }
                        }, header: {
                            VStack {
                                UserViewOptions(selectedTab: $vm.profileViewType)
                                VStack {
                                    HStack {
                                        ForEach(ProfileEventType.allCases, id: \.self) { type in
                                            Button(action: {
                                                withAnimation(.bouncy) {
                                                    vm.profileEventViewType = type
                                                }
                                            }) {
                                                Text(type.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                    .fontDesign(.monospaced)
                                                    .foregroundStyle(Color("SecondaryText"))
                                                    .tracking(-0.25)
                                                    .frame(maxWidth: .infinity)
                                            }
                                        }
                                    }
                                    
                                    GeometryReader { proxy in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemBlue))
                                            .frame(width: proxy.size.width / CGFloat(ProfileEventType.allCases.count), height: 4)
                                            .offset(x: CGFloat(proxy.size.width / CGFloat(ProfileEventType.allCases.count)) * CGFloat(vm.getEventViewTypeIndex()))
                                            .animation(.bouncy, value: vm.profileEventViewType)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                            .background(Color(.systemBackground))
                        })
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .task {
            await vm.loadProfileData()
        }
        .modifier(ProfileViewModifier(currentUser: vm.currentUser, preferBackButton: $preferBackButton, isCurrentUser: vm.isCurrentUser))
    }
}

import SwiftUI

struct ProfileViewModifier: ViewModifier {
    
    @Environment(\.router) var coordinator: Router
    
    let currentUser: User
    
    @Binding var preferBackButton: Bool
    var isCurrentUser: Bool = false
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationTitle("Profile")
                .toolbarTitleDisplayMode(isCurrentUser ? .inlineLarge : .inline)
                .toolbar {
                    if isCurrentUser {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                coordinator.present(sheet: .editProfile)
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                coordinator.push(page: .settings(currentUser: currentUser))
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                    }
                }
        } else {
            if isCurrentUser {
                content
                    .navigationTitle("Profile")
                    .toolbarTitleDisplayMode(.inlineLarge)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                coordinator.present(sheet: .editProfile)
                            }, label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            })
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                coordinator.push(page: .settings(currentUser: currentUser))
                            }, label: {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            })
                        }
                    }
            } else {
                content
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                    }
            }
        }
    }
}





struct UserViewOptions: View {
    
    @Binding var selectedTab: ProfileTab
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    var body: some View {
        Picker("", selection: $selectedTab) {
            ForEach(ProfileTab.allCases, id: \.self) { option in
                Text(option.title)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
        .padding()
        .onAppear {
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.systemBlue.withAlphaComponent(1)
            UISegmentedControl.appearance().tintColor = UIColor.systemBlue.withAlphaComponent(1)
        }
    }
}

import Kingfisher

struct UserProfileImage: View {
    
    var profileImage: String
    var displayName: String
    
    var formattedDisplayName: String {
        guard displayName.isEmpty == false else { return "JD" } // john doe
        let splitName = displayName.split(separator: " ")
        
        let firstInitial = splitName.first ?? "J"
        let secondInitial = splitName.last ?? "D"
        
        return String(firstInitial + secondInitial)
    }
    
    @State private var imageLoadingError = false
    
    var body: some View {
        avatar
    }
    
    @ViewBuilder
    private var avatar: some View {
        if profileImage.isEmpty == false {
            KFImage.url(URL(string: profileImage))
                .placeholder { ProgressView() }
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .onFailure { _ in imageLoadingError = true }
                .resizable()
                .scaledToFill()
                .frame(width: 115, height: 115)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color("SectionalColors"))
                .strokeBorder(Color("ButtonColors"), lineWidth: 1.5)
                .frame(width: 113.5, height: 113.5)
                .overlay {
                    Text(formattedDisplayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .tracking(1)
                        .foregroundStyle(Color("SecondaryText"))
                }
        }
    }
}

import SwiftUI

struct ProfileInformatics: View {
    
    @Environment(\.router) var coordinator: Router
    
    let friendsCount: Int
    let eventsCount: Int
    let postsCount: Int
    let profileUser: User
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                coordinator.push(page: .friends(profileUser: profileUser))
            }, label: {
                VStack(alignment: .center, spacing: 6) {
                    
                    Text("\(friendsCount)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(Color("PrimaryText"))
                    Text("Friends")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SecondaryText"))
                        .tracking(-0.25)
                        .lineLimit(1)
                }
                .frame(minWidth: 70)
            })
            
            VStack(alignment: .center, spacing: 6) {
                Text("\(eventsCount)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(Color("PrimaryText"))
                Text("Events")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("SecondaryText"))
                    .tracking(-0.25)
                    .lineLimit(1)
            }
            .frame(minWidth: 70)
            
            VStack(alignment: .center, spacing: 6) {
                Text("\(postsCount)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(Color("PrimaryText"))
                Text("Posts")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("SecondaryText"))
                    .tracking(-0.25)
                    .lineLimit(1)
            }
            .frame(minWidth: 70)
        }
    }
}
