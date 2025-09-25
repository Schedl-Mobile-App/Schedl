//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

enum ProfileDestinations: Hashable {
    case eventDetails(RecurringEvents)
    case settings
    case createEvent
    case friendsView
}

struct Profile_ScheduleDayCards: View {
    
    var schedules: [Schedule]
    @Binding var currentSchedule: Schedule?
    
    var partitionedEvents: [Double: [RecurringEvents]]
    
    var sortedKeys: [Double] {
        return Array(partitionedEvents.keys).sorted(by: <)
    }
    
    func returnPartionedEvents(forKey key: Double) -> [RecurringEvents] {
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
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(sortedKeys, id: \.self) { key in
                        ScheduleEventCard(events: returnPartionedEvents(forKey: key), key: key)
                    }
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 25)
        }
    }
}

struct Profile_EventCards: View {
    
    var utils = ["Upcoming", "Invited", "Past"]
    @State var selectedType: Int = 0
    
    var currentEvents: [RecurringEvents]
    var invitedEvents: [RecurringEvents]
    var pastEvents: [RecurringEvents]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(utils.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(.bouncy) {
                            selectedType = index
                        }
                    }) {
                        Text("\(utils[index])")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color("SecondaryText"))
                            .tracking(-0.25)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            ZStack {
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("ButtonColors"))
                        .frame(width: proxy.size.width / CGFloat(utils.count), height: 4)
                        .offset(x: CGFloat(proxy.size.width / CGFloat(utils.count)) * CGFloat(selectedType))
                        .animation(.bouncy, value: selectedType)
                }
            }
            .frame(height: 4)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    switch selectedType {
                    case 0:
                        if currentEvents.isEmpty {
                            Spacer()
                                .frame(height: 75)
                            NavigationLink(value: ProfileDestinations.createEvent, label: {
                                Text("No upcoming events. Tap anywhere here to create one!")
                                    .font(.subheadline)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color("SecondaryText"))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            })
                        } else {
                            ForEach(currentEvents, id: \.id) { event in
                                if event.event.startTime >= Date.computeTimeSinceStartOfDay(date: Calendar.current.startOfDay(for: Date())) {
                                    
                                    NavigationLink(value: ProfileDestinations.eventDetails(event), label: {
                                        EventCard(event: event)
                                    })
                                }
                            }
                        }
                        
                    case 1:
                        if invitedEvents.isEmpty {
                            Text("You haven't been invited to any upcoming events yet. Text your friends to invite you!")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("SecondaryText"))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        } else {
                            ForEach(invitedEvents, id: \.self.id) { event in
                                NavigationLink(value: ProfileDestinations.eventDetails(event), label: {
                                    EventCard(event: event)
                                })
                            }
                        }
                        
                    case 2:
                        if pastEvents.isEmpty {
                            NavigationLink(value: ProfileDestinations.createEvent, label: {
                                Text("No past events to show. Maybe you're new here... If so, tap anywhere here to create one!")
                                    .font(.subheadline)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color("SecondaryText"))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            })
                        } else {
                            ForEach(pastEvents, id: \.self.id) { event in
                                NavigationLink(value: ProfileDestinations.eventDetails(event), label: {
                                    EventCard(event: event)
                                })
                            }
                        }
                        
                    default: EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 25)
    }
}

struct Profile_ActivityCards: View {
    
    var posts: [Post]
    
    var body: some View {
        if posts.isEmpty {
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
            ScrollView(.vertical, showsIndicators: false) {
                Text("Posts go here")
                    .padding(.bottom)
            }
            .padding(.horizontal, 25)
        }
    }
}

struct ProfileView: View {
    
    @StateObject var vm: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @Namespace private var animation
    
    @State var preferBackButton: Bool
        
    init(currentUser: User, profileUser: User, preferBackButton: Bool) {
        _vm = StateObject(wrappedValue: ProfileViewModel(currentUser: currentUser, profileUser: profileUser))
        _preferBackButton = State(initialValue: preferBackButton)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if vm.isLoading {
                ProfileLoadingView()
            } else {
                VStack(spacing: 15) {
                    
                    VStack(spacing: 8) {
                        UserProfileImage(profileImage: vm.profileUser.profileImage, displayName: vm.profileUser.displayName)
                        Text(vm.profileUser.displayName)
                            .foregroundStyle(Color("PrimaryText"))
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 5)
                    }
                    
                    ProfileInformatics(friendsCount: vm.profileUser.numOfFriends, eventsCount: vm.profileUser.numOfEvents, postsCount: vm.profileUser.numOfPosts)
                    
                    UserViewOptions(selectedTab: $vm.selectedTab)
                    
                    // user is either viewing their profile or a friend's profile
                    if vm.showProfileDetails {
                        switch vm.selectedTab {
                        case .schedules:
                            Profile_ScheduleDayCards(schedules: vm.schedules, currentSchedule: $vm.currentSchedule, partitionedEvents: vm.partitionedEvents)
                        case .events:
                            Profile_EventCards(currentEvents: vm.currentEvents, invitedEvents: vm.invitedEvents, pastEvents: vm.pastEvents)
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
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                }
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden(false)
        .task {
            await vm.loadProfileData()
        }
        .navigationDestination(for: ProfileDestinations.self, destination: { destination in
            switch destination {
            case .eventDetails(let event):
                if let schedule = vm.currentSchedule {
                    FullEventDetailsView(recurringEvent: event, currentUser: vm.currentUser, currentScheduleId: schedule.id)
                }
            case .settings:
                EmptyView()
            case .createEvent:
                if let schedule = vm.currentSchedule {
                    CreateEventView(currentUser: vm.currentUser, currentScheduleId: schedule.id)
                }
            case .friendsView:
                FriendsView(currentUser: vm.currentUser)
            }
        })
        .modifier(ProfileViewModifier(preferBackButton: $preferBackButton, isCurrentUser: vm.isCurrentUser))
    }
}

struct ProfileViewModifier: ViewModifier {
    
    @Binding var preferBackButton: Bool
    var isCurrentUser: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .toolbar {
                    if !preferBackButton {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("NavItemsColors"))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                    
                    if isCurrentUser {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                    }
                }
        } else {
            content
                .toolbar {
                    if !preferBackButton {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("NavItemsColors"))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    
                    if isCurrentUser {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color("NavItemsColors"))
                            }
                        }
                        //                    } else {
                        //                        ToolbarItem(placement: .topBarTrailing) {
                        //                            Menu {
                        //                                Button(action: {
                        //                                    hideTabbar = true
                        //                                    navigateToSettings = true
                        //                                }, label: {
                        //                                    Label("Settings", systemImage: "gearshape")
                        //                                })
                        //                                
                        //                                Button(action: {
                        //                                    isEditingProfile = true
                        //                                }, label: {
                        //                                    Label("Edit", systemImage: "gearshape")
                        //                                })
                        //                                
                        //                                Button(action: {
                        //                                    showAddFriendModal = true
                        //                                }, label: {
                        //                                    Label("Send Friend Request", systemImage: "person.badge.plus")
                        //                                })
                        //                                
                        //                                Button(action: {
                        //                                    
                        //                                }, label: {
                        //                                    Label("Remove Friend", systemImage: "person.badge.minus")
                        //                                })
                        //                                
                        //                                Button(action: {
                        //                                    
                        //                                }, label: {
                        //                                    Label("Block", systemImage: "person.badge.plus")
                        //                                })
                        //                            } label: {
                        //                                Label("", systemImage: "ellipsis")
                        //                                    .font(.system(size: 20, weight: .bold))
                        //                                    .foregroundStyle(Color("NavItemsColors"))
                        //                            }
                        //                            .task {
                        //                                
                        //                            }
                        //                        }
                        //                    }
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
        if colorScheme == .dark {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(.bouncy) {
                            selectedTab = option
                        }
                    }) {
                        Text(option.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(selectedTab == option ? Color(hex: 0xFDFDFD) : Color("SecondaryText"))
                            .tracking(-0.25)
                            .padding()
                            .background {
                                if selectedTab == option {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color("ButtonColors"))
                                        .matchedGeometryEffect(id: "tabSelection", in: animation)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30))
        } else {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(.bouncy) {
                            selectedTab = option
                        }
                    }) {
                        Text(option.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(selectedTab == option ? Color(hex: 0xFDFDFD) : Color("SecondaryText"))
                            .tracking(-0.25)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background {
                                if selectedTab == option {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color("ButtonColors"))
                                        .matchedGeometryEffect(id: "selector", in: animation)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color("SectionalColors"), in: RoundedRectangle(cornerRadius: 30))
        }
    }
}

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
                .frame(width: 125, height: 125)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color("SectionalColors"))
                .strokeBorder(Color("ButtonColors"), lineWidth: 1.5)
                .frame(width: 123.5, height: 123.5)
                .overlay {
                    Text(formattedDisplayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(1)
                        .foregroundStyle(Color("SecondaryText"))
                }
        }
    }
}


//struct HiddenScheduleEventCardView: View {
//    
//    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
//    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//    var fakeTitles = [
//        "Going to the movies",
//        "Hiking with John",
//        "Gym",
//        "Dinner plans",
//        "Shopping with Jennifer",
//        "Movie night with friends",
//    ]
//    @Binding var displayName: String
//    
//    var body: some View {
//        ZStack(alignment: .center) {
//            ScrollView(.vertical, showsIndicators: false) {
//                LazyVStack {
//                    ForEach(1..<5, id: \.self) { index in
//                       
//                        var dateToDisplay: String {
//                            if index == 1 { return "Today" }
//                            if index == 2 { return "Tomorrow"}
//                            let today = Calendar.current.date(byAdding: .day, value: index - 1, to: Date())!
//                            return weekdays[min(Calendar.current.component(.weekday, from: today), 6)]
//                        }
//                        var monthToDisplay: String {
//                            let today = Calendar.current.date(byAdding: .day, value: index - 1, to: Date())!
//                            let monthIdx = Calendar.current.component(.month, from: today) - 1
//                            return months[monthIdx]
//                        }
//                        
//                        var dayToDisplay: String {
//                            let today = Calendar.current.date(byAdding: .day, value: index - 1, to: Date())!
//                            return String(Calendar.current.component(.day, from: today))
//                        }
//                        
//                        HStack(alignment: .top, spacing: 20) {
//                            LazyVStack(alignment: .leading, spacing: 8) {
//                                HStack {
//                                    Text(dateToDisplay)
//                                        .font(.system(size: 15, weight: .bold, design: .monospaced))
//                                        .tracking(-0.25)
//                                        .foregroundStyle(Color("PrimaryText"))
//                                        .multilineTextAlignment(.leading)
//                                    
//                                    Spacer()
//                                    
//                                    Text("\(monthToDisplay) \(dayToDisplay)")
//                                        .font(.system(size: 13, weight: .medium, design: .rounded))
//                                        .foregroundStyle(Color("SecondaryText"))
//                                        .lineLimit(1)
//                                }
//                                
//                                let randomValue = Int.random(in: 2...5)
//                                ForEach(1..<randomValue, id: \.self) { _ in
//                                    HStack(spacing: 12) {
//                                        Text(fakeTitles.randomElement()!)
//                                            .font(.system(size: 13, weight: .medium, design: .rounded))
//                                            .foregroundStyle(Color("PrimaryText"))
//                                            .tracking(1)
//                                            .lineLimit(1)
//                                            .truncationMode(.tail)
//                                        
//                                        Spacer(minLength: 6)
//                                        
//                                        Text("9:30 AM")
//                                            .font(.system(size: 13, weight: .medium))
//                                            .monospacedDigit()
//                                            .foregroundStyle(Color("SecondaryText"))
//                                            .lineLimit(1)
//                                            .truncationMode(.tail)
//                                    }
//                                }
//                            }
//                            .padding(.vertical)
//                        }
//                        .padding(.trailing, 10)
//                        .padding(.leading, 20)
//                        .background(
//                            ZStack(alignment: .leading) {
//                                Color.white
//                                
//                                Color("ButtonColors")
//                                    .frame(width: 7)
//                                    .frame(maxHeight: .infinity)
//                                
//                                
//                            }
//                        )
//                        .blur(radius: 5, opaque: false)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        
//                        //                                            .padding(.horizontal, 25)
//                        //                                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                        
//                    }
//                }
//                .padding(.bottom)
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .padding(.horizontal, 25)
//            
//            Text("Add \(displayName.split(separator: " ").first!) as a friend to see her schedule!")
//                .font(.title3)
//                .fontWeight(.bold)
//                .fontDesign(.monospaced)
//                .tracking(-0.25)
//                .multilineTextAlignment(.center)
//                .foregroundStyle(Color("BackgroundColor"))
//                .padding(.horizontal)
//                .padding(.vertical, 16)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.black.opacity(0.30))
//                )
//                .padding(.horizontal)
//        }
//    }
//}


