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
    @Environment(\.presentationMode) var presentationMode
    
    lazy var size: CGSize = profileViewModel.currentUser.username.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
    
    init(currentUser: User, profileUser: User) {
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(currentUser: currentUser, profileUser: profileUser))
    }
    
    var body: some View {
        ZStack {
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
                            NavigationLink(destination: NotificationsView(currentUser: profileViewModel.currentUser)) {
                                Image(systemName: "bell")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundStyle(Color(hex: 0x333333))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                        .font(.system(size: 24, weight: .medium))
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(Color.primary)
                                        .accessibilityLabel("Go Back")
                            }
                            Spacer()
                            Button(action: {
                                Task {
                                    profileViewModel.showAddFriendModal.toggle()
                                }
                            }) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(Color.primary)
                                    .accessibilityLabel("Send Friend Request")
                            }
                            .hidden(profileViewModel.isViewingFriend)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    }
                }
                
                VStack(spacing: 8) {
                    UserProfileImage()
                    UserDisplayName()
                }
                
                ProfileInformatics()
                
                UserViewOptions()
                
                if profileViewModel.isCurrentUser || profileViewModel.isViewingFriend {
                    switch profileViewModel.selectedTab {
                    case .schedules:
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack() {
                                let sortedKeys = Array(profileViewModel.partitionedEvents.keys).sorted(by: <)
                                ForEach(sortedKeys, id: \.self) { key in
                                    ScheduleEventCards(key: key)
                                }
                            }
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
                                    case 0: ForEach(profileViewModel.currentEvents) { EventCard(event: $0) }
                                    case 1: ForEach(profileViewModel.invitedEvents) { EventCard(event: $0) }
                                    case 2: ForEach(profileViewModel.pastEvents)    { EventCard(event: $0) }
                                    default: EmptyView()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .padding(.horizontal, 25)
                            .layoutPriority(1)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    case .activity:
                        ScrollView(.vertical, showsIndicators: false) {
                            Text("Activity")
                        }
                    }
                } else {
                    Text("Add \(profileViewModel.profileUser.displayName) as a friend first!")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .padding(.vertical)
            
            if profileViewModel.showAddFriendModal {
                ZStack {
                    Color(.black.opacity(0.7))
                        .ignoresSafeArea()
                    
                    AddFriendModal()
                }
            }
            
            if profileViewModel.showSaveChangesModal {
                ZStack {
                    Color(.black.opacity(0.7))
                        .ignoresSafeArea()
                    
                    SaveChangesForm()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(hex: 0xf7f4f2))
        .environmentObject(profileViewModel)
        .onAppear {
            Task {
                await profileViewModel.loadViewData()
            }
        }
    }
}

struct EventCard: View {
    
    let event: Event
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let hours = Int(timeObj / 3600)
        let minutes = (Double(timeObj / 3600.0) - Double(hours)) * 60
        if hours == 0 {
            return "12:\(String(format: "%02d", Int(minutes))) AM"
        } else if hours == 12 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) PM"
        } else if hours < 11 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) AM"
        } else {
            return "\(Int(hours - 12)):\(String(format: "%02d", Int(minutes))) PM"
        }
    }
    
    var body: some View {
            
        let todayStart = Date.convertCurrentDateToTimeInterval(date: Date())
        let tomorrowStart = todayStart + 86400
        let blockDate = Date(timeIntervalSince1970: event.eventDate)
        let dayText: String = {
            if event.eventDate == todayStart     { return "Today" }
            if event.eventDate == tomorrowStart  { return "Tomorrow" }
            let wd = Calendar.current.component(.weekday, from: blockDate)
            return weekdays[wd-1]
        }()
        let monthIdx = Calendar.current.component(.month, from: blockDate) - 1
        let monthName = months[monthIdx]
        let dayOfMonth = Calendar.current.component(.day, from: blockDate)

        HStack(alignment: .top, spacing: 20) {
            VStack( alignment: .leading, spacing: 8) {
                Text("\(event.title)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .tracking(1.15)
                    .foregroundStyle(Color(hex: 0x333333))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 8) {
//                    Image(systemName: "calendar")
//                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                    Text("📆")
                        .font(.system(size: 14))
                    HStack(spacing: 0) {
                        let formattedTime = returnTimeFormatted(timeObj: event.startTime)
                        Text("\(dayText), \(monthName) \(String(format: "%02d", dayOfMonth)) - ")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .tracking(1.15)
                            .foregroundStyle(Color(hex: 0x666666))

                        Text("\(formattedTime)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .tracking(1.05)
                            .foregroundStyle(Color(hex: 0x666666))
                    }
                }
                
                HStack {
//                    Image(systemName: "mappin")
//                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                    Text("📍")
                        .font(.system(size: 14))
                    
                    Text("Conference Room B")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .tracking(1.15)
                        .foregroundStyle(Color(hex: 0x666666))
                }
                
                Spacer()
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.leading, 20)
        .frame(minHeight: 90)
        .background(
            ZStack(alignment: .leading) {
                Color.white
                
                Color(hex: 0x3C859E)
                    .frame(width: 7)
                    .frame(maxHeight: .infinity)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SaveChangesForm: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Would you like to save these changes?")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
            HStack(alignment: .center, spacing: 15) {
                Button(action: {
                    profileViewModel.showSaveChangesModal.toggle()
                    profileViewModel.isEditingProfile.toggle()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.1))
                }
                
                Button(action: {
                    Task {
                        await profileViewModel.updateUserProfile()
                        profileViewModel.showSaveChangesModal.toggle()
                        profileViewModel.isEditingProfile.toggle()
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: 0xf7f4f2))
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: 0x6d8a96))
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: 0xe0dad5))
        }
        .padding(.horizontal, UIScreen.main.bounds.width * 0.075)
    }
}

struct ProfileInformatics: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0xe0dad5))
            .cornerRadius(15)
            .overlay {
                HStack {
                    NavigationLink(destination: FriendsView().environmentObject(profileViewModel)) {
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(profileViewModel.friends.count)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: 0x333333))
                            Text("Friends")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color(hex: 0x666666))
                                .tracking(0.01)
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 50)
                        .background(Color(hex: 0xc0b8b2))
                    VStack(alignment: .center, spacing: 6) {
                        Text("\(profileViewModel.userEvents.count)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Events")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.01)
                            .fixedSize()
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 50)
                        .background(Color(hex: 0xc0b8b2))
                    
                    VStack(alignment: .center, spacing: 6) {
                        Text("\(profileViewModel.userPosts.count)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Posts")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.01)
                            .fixedSize()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
            }
            .onAppear {
                
            }
            .frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
            .padding(.horizontal, 50)
    }
}

struct UserViewOptions: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
        
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

struct ScheduleEventCards: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    let key: Double
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let todayStart = Date.convertCurrentDateToTimeInterval(date: Date())
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let hours = Int(timeObj / 3600)
        let minutes = (Double(timeObj / 3600.0) - Double(hours)) * 60
        if hours == 0 {
            return "12:\(String(format: "%02d", Int(minutes))) AM"
        } else if hours == 12 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) PM"
        } else if hours < 11 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) AM"
        } else {
            return "\(Int(hours - 12)):\(String(format: "%02d", Int(minutes))) PM"
        }
    }
    
    func eventHasEnded(startTime: Double, date: Double) -> Bool {
        let currentTime = Date.computeTimeSinceStartOfDay(date: Date())
        return startTime < currentTime && date <= todayStart
    }
    
    var body: some View {
        
        let events = profileViewModel.partitionedEvents[key] ?? []
        let tomorrowStart = todayStart + 86400
        let blockDate = Date(timeIntervalSince1970: key)
        let dayText: String = {
        if key == todayStart     { return "Today" }
        if key == tomorrowStart  { return "Tomorrow" }
        let wd = Calendar.current.component(.weekday, from: blockDate)
        return weekdays[wd-1]
        }()
        let monthIdx = Calendar.current.component(.month, from: blockDate) - 1
        let monthName = months[monthIdx]
        let dayOfMonth = Calendar.current.component(.day, from: blockDate)

        HStack(alignment: .top, spacing: 20) {
            LazyVStack( alignment: .leading, spacing: 8) {
                HStack {
                    Text(dayText)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .tracking(0.1)
                        .foregroundStyle(Color(hex: 0x333333))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text("\(monthName) \(String(format: "%02d", dayOfMonth))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: 0x666666))
                        .lineLimit(1)
                }
                
                ForEach(events, id: \.id) { event in
                    HStack(spacing: 12) {
                        let formattedTime = returnTimeFormatted(timeObj: event.startTime)
                        Text("\(event.title)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: 0x333333))
                            .tracking(1.15)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .strikethrough(eventHasEnded(startTime: event.startTime, date: event.eventDate), color: Color(.black))
                        
                        Spacer(minLength: 6)

                        Text("\(formattedTime)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: 0x666666))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .strikethrough(eventHasEnded(startTime: event.startTime, date: event.eventDate), color: Color(.black))
                    }
                }
            }
            .padding(.vertical, 10)
            .fixedSize(horizontal: false, vertical: true)
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
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(minHeight: 80)
        .padding(.horizontal, 25)
    }
}

struct UserProfileImage: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
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
                    } else if profileViewModel.profileUser.profileImage != "" {
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
                        .foregroundStyle(Color(hex: 0x6d8a96))
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
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
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
