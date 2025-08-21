//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabBarState: TabBarState
        
    @State var navigateToEventDetails = false
    @State var navigateToSettings = false
    @State var navigateToFriends = false
    @State var navigateToCreateEventView = false
    
    @State var selectedType: Int = 0
    var utils = ["Upcoming", "Invited", "Past"]
    @Environment(\.dismiss) var dismiss
        
    init(currentUser: User, profileUser: User) {
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(currentUser: currentUser, profileUser: profileUser))
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            if profileViewModel.isLoadingProfileView {
                ProfileLoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.bottom, 0.5)
            } else {
                VStack {
                    ZStack(alignment: .leading) {
                        if profileViewModel.isCurrentUser {
                            Text("Profile")
                                .foregroundStyle(Color(hex: 0x333333))
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack {
                                Button(action: {
                                    if profileViewModel.isEditingProfile {
                                        profileViewModel.showSaveChangesModal.toggle()
                                    } else {
                                        profileViewModel.isEditingProfile.toggle()
                                    }
                                }) {
                                    Text(profileViewModel.isEditingProfile ? "Done" : "Edit")
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(-0.25)
                                }
                                Spacer()
                                Button(action: {
                                    tabBarState.hideTabbar = true
                                    navigateToSettings = true
                                }) {
                                    Image(systemName: "gearshape")
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(Color(hex: 0x333333))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Profile")
                                .foregroundStyle(Color(hex: 0x333333))
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack {
                                Button(action: {
                                    tabBarState.hideTabbar = true
                                    dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .fontWeight(.bold)
                                        .imageScale(.large)
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(Color(hex: 0x333333))
                                }
                                Spacer()
                                Button(action: {
                                    profileViewModel.showAddFriendModal = true
                                }) {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 24, weight: .medium))
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(Color.primary)
                                        .accessibilityLabel("Send Friend Request")
                                }
                                .hidden(profileViewModel.isViewingFriend || profileViewModel.isCurrentUser)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            UserProfileImage(profileViewModel: profileViewModel)
                            UserDisplayName(profileViewModel: profileViewModel)
                        }
                        
                        ProfileInformatics(profileViewModel: profileViewModel, navigateToFriends: $navigateToFriends).environmentObject(tabBarState)
                        
                        UserViewOptions(profileViewModel: profileViewModel)
                        
                        if profileViewModel.isCurrentUser || profileViewModel.isViewingFriend {
                            switch profileViewModel.selectedTab {
                            case .schedules:
                                let sortedKeys = Array(profileViewModel.partitionedEvents.keys).sorted(by: <)
                                if sortedKeys.isEmpty {
                                    Button(action: {
                                        tabBarState.hideTabbar = true
                                        navigateToCreateEventView = true
                                    }) {
                                        Text(profileViewModel.isViewingFriend ? "\(profileViewModel.profileUser.displayName.split(separator: " ").first!) has no upcoming events. Tell them that they should create some!" : "No upcoming events. Tap anywhere here to create one!")
                                            .font(.subheadline)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(hex: 0x666666))
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .padding(.horizontal, 25)
                                    }
                                } else {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        LazyVStack(spacing: 10) {
                                            ForEach(sortedKeys, id: \.self) { key in
                                                ScheduleEventCards(profileViewModel: profileViewModel, key: key)
                                            }
                                        }
                                        .padding(.bottom)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 25)
                                }
                            case .events:
                                VStack(spacing: 10) {
                                    HStack {
                                        ForEach(utils.indices, id: \.self) { index in
                                            Text("\(utils[index])")
                                                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                                                .foregroundStyle(Color(hex: 0x666666))
                                                .tracking(0.001)
                                                .fixedSize()
                                                .frame(maxWidth: .infinity)
                                                .onTapGesture {
                                                    selectedType = index
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                    
                                    GeometryReader { proxy in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: 0x3C859E))
                                            .frame(width: proxy.size.width / CGFloat(utils.count), height: 4)
                                            .offset(x: CGFloat(proxy.size.width / CGFloat(utils.count)) * CGFloat(selectedType))
                                            .animation(.bouncy, value: selectedType)
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.bottom, 10)
                                    
                                    ScrollView(.vertical, showsIndicators: false) {
                                        LazyVStack(spacing: 10) {
                                            switch selectedType {
                                            case 0:
                                                if profileViewModel.currentEvents.isEmpty {
                                                    Spacer()
                                                        .frame(height: 75)
                                                    Button(action: {
                                                        tabBarState.hideTabbar = true
                                                        navigateToCreateEventView = true
                                                    }) {
                                                        Text(profileViewModel.isViewingFriend ? "\(profileViewModel.profileUser.displayName.split(separator: " ").first!) has no upcoming events. Tell him that he should create some!" : "No upcoming events. Tap anywhere here to create one!")
                                                            .font(.subheadline)
                                                            .fontDesign(.monospaced)
                                                            .tracking(-0.25)
                                                            .fontWeight(.medium)
                                                            .foregroundStyle(Color(hex: 0x666666))
                                                            .multilineTextAlignment(.center)
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                    }
                                                } else {
                                                    ForEach(profileViewModel.currentEvents, id: \.self.id) { event in
                                                        if event.event.startTime >= Date.computeTimeSinceStartOfDay(date: Calendar.current.startOfDay(for: Date())) {
                                                            
                                                            EventCard(event: event, navigateToEventDetails: $navigateToEventDetails, selectedEvent: $profileViewModel.selectedEvent).environmentObject(tabBarState)
                                                        }
                                                    }
                                                }
                                            case 1:
                                                if profileViewModel.invitedEvents.isEmpty {
                                                    Spacer()
                                                        .frame(height: 75)
                                                    Text(profileViewModel.isViewingFriend ? "\(profileViewModel.profileUser.displayName.split(separator: " ").first!) hasn't been invited to any events. You should invite them to one!" : "You haven't been invited to any upcoming events yet. Text your friends to invite you!")
                                                        .font(.subheadline)
                                                        .fontDesign(.monospaced)
                                                        .tracking(-0.25)
                                                        .fontWeight(.medium)
                                                        .foregroundStyle(Color(hex: 0x666666))
                                                        .multilineTextAlignment(.center)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                } else {
                                                    ForEach(profileViewModel.invitedEvents, id: \.self.id) { event in
                                                        if event.event.startTime >= Date.computeTimeSinceStartOfDay(date: Calendar.current.startOfDay(for: Date())) {
                                                            
                                                            EventCard(event: event, navigateToEventDetails: $navigateToEventDetails, selectedEvent: $profileViewModel.selectedEvent).environmentObject(tabBarState)
                                                        }
                                                    }
                                                }
                                            case 2:
                                                if profileViewModel.pastEvents.isEmpty {
                                                    Spacer()
                                                        .frame(height: 75)
                                                    Button(action: {
                                                        tabBarState.hideTabbar = true
                                                        navigateToCreateEventView = true
                                                    }) {
                                                        Text(profileViewModel.isViewingFriend ? "\(profileViewModel.profileUser.displayName.split(separator: " ").first!) has no past events to show. Maybe they're new here..." : "No past events to show. Maybe you're new here... If so, tap anywhere here to create one!")
                                                            .font(.subheadline)
                                                            .fontDesign(.monospaced)
                                                            .tracking(-0.25)
                                                            .fontWeight(.medium)
                                                            .foregroundStyle(Color(hex: 0x666666))
                                                            .multilineTextAlignment(.center)
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                    }
                                                } else {
                                                    ForEach(profileViewModel.pastEvents, id: \.self.id) { event in
                                                        EventCard(event: event, navigateToEventDetails: $navigateToEventDetails, selectedEvent: $profileViewModel.selectedEvent).environmentObject(tabBarState)}
                                                }
                                            default: EmptyView()
                                            }
                                        }
                                        .padding(.bottom)
                                        .frame(maxHeight: .infinity)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 25)
                                    .layoutPriority(1)
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                            case .activity:
                                if profileViewModel.userPosts.isEmpty {
                                    Button(action: {
                                        
                                    }) {
                                        Text(profileViewModel.isViewingFriend ? "\(profileViewModel.profileUser.displayName.split(separator: " ").first!) has no recent activity. Tell them to create a post!" : "No activity to show here yet. Tap anywhere here to create your first post!")
                                            .font(.subheadline)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(hex: 0x666666))
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .padding(.horizontal, 25)
                                    }
                                } else {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        Text("Posts go here")
                                            .padding(.bottom)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 25)
                                }
                            }
                        } else {
                            Button(action: {
                                profileViewModel.showAddFriendModal = true
                            }) {
                                Text("You can't see \(profileViewModel.profileUser.displayName.split(separator: " ").first!)'s schedule until you add them as a friend. Click anywhere here to request them!")
                                    .font(.subheadline)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: 0x666666))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(.horizontal, 25)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding(.bottom, 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                ZStack {
                    Color(.black.opacity(0.7))
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    AddFriendModal(profileViewModel: profileViewModel)
                }
                .zIndex(100)
                .hidden(!profileViewModel.showAddFriendModal)
                .allowsHitTesting(profileViewModel.showAddFriendModal)
                
                ZStack {
                    Color(.black.opacity(0.7))
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    SaveChangesForm(profileViewModel: profileViewModel)
                }
                .zIndex(1)
                .hidden(!profileViewModel.showSaveChangesModal)
                .allowsHitTesting(profileViewModel.showSaveChangesModal)
            }
        }
        .onAppear {
            tabBarState.hideTabbar = false
        }
        .navigationBarBackButtonHidden(true)
        .task {
            if profileViewModel.shouldReloadData {
                await profileViewModel.loadProfileData()
            }
        }
        .toolbar(profileViewModel.showSaveChangesModal || profileViewModel.showAddFriendModal || tabBarState.hideTabbar ? .hidden : .visible, for: .tabBar)
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView(profileViewModel: profileViewModel)
                .environmentObject(authViewModel)
                .environmentObject(tabBarState)
        }
        .navigationDestination(isPresented: $navigateToEventDetails) {
            if let event = profileViewModel.selectedEvent {
                EventDetailsView(event: event, currentUser: profileViewModel.currentUser, shouldReloadData: $profileViewModel.shouldReloadData)
            }
        }
        .navigationDestination(isPresented: $navigateToFriends) {
            FriendsView(profileViewModel: profileViewModel)
                .environmentObject(tabBarState)
        }
        .navigationDestination(isPresented: $navigateToCreateEventView) {
            CreateEventView(currentUser: profileViewModel.currentUser,
                            shouldReloadData: $profileViewModel.shouldReloadData).environmentObject(tabBarState)
        }
    }
}



struct UserViewOptions: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
        
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: 0xe0dad5))
                .cornerRadius(30)
            
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: 0x3C859E))
                    .frame(width: proxy.size.width / CGFloat(profileViewModel.tabOptions.count))
                    .offset(x: CGFloat(proxy.size.width / CGFloat(profileViewModel.tabOptions.count)) * CGFloat(profileViewModel.returnSelectedOptionIndex()))
                    .animation(.bouncy, value: profileViewModel.selectedTab)
            }
            
            HStack {
                ForEach(profileViewModel.tabOptions, id: \.self) { option in
                    Text("\(option.title)")
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundStyle(profileViewModel.selectedTab == option ? Color(hex: 0xf7f4f2) : Color(hex: 0x666666))
                        .tracking(0.001)
                        .fixedSize()
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            profileViewModel.selectedTab = option
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 45, alignment: .center)
        .padding(.horizontal, 25)
    }
}

struct HiddenScheduleEventCardView: View {
    
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var fakeTitles = [
        "Going to the movies",
        "Hiking with John",
        "Gym",
        "Dinner plans",
        "Shopping with Jennifer",
        "Movie night with friends",
    ]
    @Binding var displayName: String
    
    var body: some View {
        ZStack(alignment: .center) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(1..<5, id: \.self) { index in
                       
                        var dateToDisplay: String {
                            if index == 1 { return "Today" }
                            if index == 2 { return "Tomorrow"}
                            let today = Calendar.current.date(byAdding: .day, value: index - 1, to: Date())!
                            return weekdays[min(Calendar.current.component(.weekday, from: today), 6)]
                        }
                        var monthToDisplay: String {
                            let today = Calendar.current.date(byAdding: .day, value: index - 1, to: Date())!
                            let monthIdx = Calendar.current.component(.month, from: today) - 1
                            return months[monthIdx]
                        }
                        
                        var dayToDisplay: String {
                            let today = Calendar.current.date(byAdding: .day, value: index - 1, to: Date())!
                            return String(Calendar.current.component(.day, from: today))
                        }
                        
                        HStack(alignment: .top, spacing: 20) {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(dateToDisplay)
                                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                                        .tracking(-0.25)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Text("\(monthToDisplay) \(dayToDisplay)")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(Color(hex: 0x666666))
                                        .lineLimit(1)
                                }
                                
                                let randomValue = Int.random(in: 2...5)
                                ForEach(1..<randomValue, id: \.self) { _ in
                                    HStack(spacing: 12) {
                                        Text(fakeTitles.randomElement()!)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color(hex: 0x333333))
                                            .tracking(1)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        
                                        Spacer(minLength: 6)
                                        
                                        Text("9:30 AM")
                                            .font(.system(size: 13, weight: .medium))
                                            .monospacedDigit()
                                            .foregroundStyle(Color(hex: 0x666666))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        .padding(.trailing, 10)
                        .padding(.leading, 20)
                        .background(
                            ZStack(alignment: .leading) {
                                Color.white
                                
                                Color(hex: 0x3C859E)
                                    .frame(width: 7)
                                    .frame(maxHeight: .infinity)
                                
                                
                            }
                        )
                        .blur(radius: 5, opaque: false)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        //                                            .padding(.horizontal, 25)
                        //                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                }
                .padding(.bottom)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 25)
            
            Text("Add \(displayName.split(separator: " ").first!) as a friend to see her schedule!")
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.monospaced)
                .tracking(-0.25)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(hex: 0xf7f4f2))
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.30))
                )
                .padding(.horizontal)
        }
    }
}

struct UserProfileImage: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var pickerItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color(hex: 0x6d8a96), lineWidth: 1.5)
                .frame(width: 114, height: 114)
                .overlay {
                    if let selectedImage = profileViewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 112.5, height: 112.5)
                            .clipShape(Circle())
                    } else if let cachedImage = profileViewModel.cachedProfileImage {
                        Image(uiImage: cachedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 112.5, height: 112.5)
                            .clipShape(Circle())
                    } else if !profileViewModel.profileUser.profileImage.isEmpty {
                        AsyncImage(url: URL(string: profileViewModel.profileUser.profileImage)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 112.5, height: 112.5)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 112.5, height: 112.5)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(hex: 0xe0dad5))
                            .frame(width: 112.5, height: 112.5)
                            .overlay {
                                Text("\(profileViewModel.profileUser.displayName.first?.uppercased() ?? "J")\(profileViewModel.profileUser.displayName.last?.uppercased() ?? "D")")
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .multilineTextAlignment(.center)
                            }
                    }
                }
            if profileViewModel.isEditingProfile {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Circle()
                        .foregroundStyle(Color(hex: 0x3C859E))
                        .frame(maxWidth: 30, maxHeight: 30)
                        .foregroundStyle(.clear)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(.white)
                                .containerShape(Circle())
                        }
                }
                .frame(width: 125, height: 112.5, alignment: .topTrailing)
            }
        }
        .onChange(of: pickerItem) {
            Task {
                if let imageData = try await pickerItem?.loadTransferable(type: Data.self) {
                    profileViewModel.selectedImage = UIImage(data: imageData)
                }
            }
        }
    }
}

struct UserDisplayName: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @State var isEditingProfile = false
    @State var isEditingUsername = false
    
    var body: some View {
        HStack(spacing: 4) {
            TextField("Placeholder", text: $profileViewModel.profileUser.displayName)
              .font(.system(size: 18, weight: .bold, design: .monospaced))
              .multilineTextAlignment(.center)
              .disabled(!isEditingProfile && !isEditingUsername)
              .overlay {
                  Rectangle()
                      .foregroundStyle(.clear)
                      .clipShape(RoundedRectangle(cornerRadius: 5))
                      .padding(-5)
              }

            if isEditingProfile {
              Image(systemName: "pencil")
                .font(.system(size: 14, weight: .medium))
                .padding(.leading, 5)
                .onTapGesture {
                    isEditingUsername.toggle()
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

