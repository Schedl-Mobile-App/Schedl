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
                VStack(alignment: .center, spacing: 20) {
                    ZStack {
                        if profileViewModel.isCurrentUser {
                            Text("Profile")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: 0x333333))
                                .tracking(0.001)
                            
                            HStack {
                                Button(action: {
                                    if profileViewModel.isEditingProfile {
                                        profileViewModel.showSaveChangesModal.toggle()
                                    } else {
                                        profileViewModel.isEditingProfile.toggle()
                                    }
                                }) {
                                    Text(profileViewModel.isEditingProfile ? "Done" : "Edit")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.001)
                                }
                                Spacer()
                                NavigationLink(destination: SettingsView(profileViewModel: profileViewModel).environmentObject(authViewModel)) {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 26))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(hex: 0x333333))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Profile")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: 0x333333))
                                .tracking(0.001)
                            
                            HStack {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                            .font(.system(size: 24, weight: .medium))
                                            .labelStyle(.iconOnly)
                                            .foregroundStyle(Color.primary)
                                            .accessibilityLabel("Go Back")
                                }
                                Spacer()
                                Button(action: {
                                    profileViewModel.showAddFriendModal.toggle()
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
                    
                    VStack(spacing: 8) {
                        UserProfileImage(profileViewModel: profileViewModel)
                        UserDisplayName(profileViewModel: profileViewModel)
                    }
                    
                    ProfileInformatics(profileViewModel: profileViewModel)
                    
                    UserViewOptions(profileViewModel: profileViewModel)
                    
                    if profileViewModel.isCurrentUser || profileViewModel.isViewingFriend {
                        switch profileViewModel.selectedTab {
                        case .schedules:
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 10) {
                                    let sortedKeys = Array(profileViewModel.partitionedEvents.keys).sorted(by: <)
                                    ForEach(sortedKeys, id: \.self) { key in
                                        ScheduleEventCards(profileViewModel: profileViewModel, key: key)
                                    }
                                }
                                .padding(.bottom)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                        case 0: ForEach(profileViewModel.currentEvents, id: \.self.id) { event in
                                            if event.event.startTime >= Date.computeTimeSinceStartOfDay(date: Calendar.current.startOfDay(for: Date())) {
                                                
                                                EventCard(event: event, profileViewModel: profileViewModel)
                                            }
                                        }
                                        case 1: ForEach(profileViewModel.invitedEvents, id: \.self.id) { event in
                                            if event.event.startTime >= Date.computeTimeSinceStartOfDay(date: Calendar.current.startOfDay(for: Date())) {
                                                
                                                EventCard(event: event, profileViewModel: profileViewModel)
                                            }
                                        }
                                        case 2: ForEach(profileViewModel.pastEvents, id: \.self.id) { EventCard(event: $0, profileViewModel: profileViewModel) }
                                        default: EmptyView()
                                        }
                                    }
                                    .padding(.bottom)
                                    .frame(maxHeight: .infinity)
                                }
                                .padding(.horizontal, 25)
                                .layoutPriority(1)
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                        case .activity:
                            ScrollView(.vertical, showsIndicators: false) {
                                Text("Activity")
                                    .padding(.bottom)
                            }
                        }
                    } else {
                        Text("Add \(profileViewModel.profileUser.displayName) as a friend first!")
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
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
                .zIndex(1)
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
        .navigationBarBackButtonHidden(true)
        .task {
            if profileViewModel.shouldReloadData {
                await profileViewModel.loadProfileData()
            }
        }
        .toolbar(profileViewModel.showSaveChangesModal || profileViewModel.showAddFriendModal ? .hidden : .visible, for: .tabBar)
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
//        .onChange(of: pickerItem) {
//            Task {
//                if let imageData = try await pickerItem?.loadTransferable(type: Data.self) {
//                    profileViewModel.selectedImage = UIImage(data: imageData)
//                }
//            }
//        }
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

