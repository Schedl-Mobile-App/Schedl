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
    
    lazy var size: CGSize = profileViewModel.currentUser.username.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
    
    init(currentUser: User, profileUser: User) {
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(currentUser: currentUser, profileUser: profileUser))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                ZStack {
                    Text("Profile")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: 0x333333))
                        .tracking(0.001)
                    
                    if profileViewModel.isCurrentUser {
                        HStack {
                            Button(action: {
                                if profileViewModel.isEditingProfile {
                                    profileViewModel.triggerSaveChanges.toggle()
                                }
                                profileViewModel.isEditingProfile.toggle()
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
                    }
                }
                
                VStack(spacing: 8) {
                    UserProfileImage()
                    UserDisplayName()
                }
                
                ProfileInformatics()
                
                UserViewOptions()
                
                ForEach(Array(profileViewModel.partitionedEvents.keys), id: \.self) { key in
                    ScheduleEventCards(key: key)
                }
                                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .padding(.vertical)
            
            if profileViewModel.triggerSaveChanges {
                SaveChangesForm()
            }
        }
        .background(Color(hex: 0xf7f4f2))
        .environmentObject(profileViewModel)
        .onAppear {
            Task {
                await profileViewModel.fetchUserSchedule()
                await profileViewModel.partionEventsByDay()
            }
        }
    }
}

struct EventCard: View {
    
    let event: Event
    
    var body: some View {
        let dateObj = Date.convertTimeSince1970ToDate(time: event.startTime)
        let secs = Date.computeTimeSinceStartOfDay(date: dateObj)
        let hours = Int(secs) / 3600
        let minutes = Int(secs) % 3600 / 60
        let ampm = Int(secs) >= 43200 ? "PM" : "AM"

        HStack {
          Text(event.title)
          Text("\(hours):\(String(format: "%02d", minutes)) \(ampm)")
        }
    }
}

struct SaveChangesForm: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color(hex: 0xe0dad5))
                    .frame(maxWidth: 150, maxHeight: 150, alignment: .center)
                    .overlay {
                        VStack(alignment: .center, spacing: 20) {
                            Text("Would you like to save these changes?")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                            HStack {
                                Button(action: {
                                    profileViewModel.triggerSaveChanges.toggle()
                                }) {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color(hex: 0x333333))
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .cornerRadius(15)
                                .foregroundStyle(Color(hex: 0xe0dad5))
                                
                                Button(action: {
                                    Task {
                                        await profileViewModel.updateUserProfile()
                                        profileViewModel.triggerSaveChanges.toggle()
                                    }
                                }) {
                                    Text("Save")
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color(hex: 0xf7f4f2))
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .cornerRadius(15)
                                .foregroundStyle(Color(hex: 0x6d8a96))
                            }
                        }
                    }
            }
            .background(Color.gray.opacity(0.2))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
        }
        .zIndex(999)
    }
}

struct ProfileInformatics: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0xe0dad5))
            .cornerRadius(15)
            .overlay {
                HStack {
                    VStack(alignment: .center, spacing: 6) {
                        Text("126")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Friends")
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
                        Text("8")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Schedules")
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
                        Text("42")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Events")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.01)
                            .fixedSize()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
            .padding(.horizontal, 50)
    }
}

struct UserViewOptions: View {
    
    var utilities = ["My Schedule", "Events", "Activity"]
    @State var selectedUtility = 1
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: 0xe0dad5))
                .cornerRadius(30)
            
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: 0x6d8a96))
                    .frame(width: proxy.size.width / CGFloat(utilities.count))
                    .offset(x: CGFloat(proxy.size.width / CGFloat(utilities.count)) * CGFloat(selectedUtility))
                    .animation(.bouncy, value: selectedUtility)
            }
            
            HStack {
                ForEach(utilities.indices, id: \.self) { index in
                    Text(utilities[index])
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundStyle(selectedUtility == index ? Color(hex: 0xf7f4f2) : Color(hex: 0x666666))
                        .tracking(0.001)
                        .fixedSize()
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            selectedUtility = index
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
    
    var body: some View {
            
        // 1) Pull out all your date/event logic up front:
        let events = profileViewModel.partitionedEvents[key] ?? []
        let todayStart = Date.convertCurrentDateToTimeInterval(date: Date())
        let tomorrowStart = todayStart + 86400
        let blockDate = Date(timeIntervalSince1970: key)
        let dayText: String = {
        if key == todayStart     { return "Today" }
        if key == tomorrowStart  { return "Tomorrow" }
        let wd = Calendar.current.component(.weekday, from: blockDate)
        return weekdays[wd]
        }()
        let monthIdx = Calendar.current.component(.month, from: blockDate) - 1
        let monthName = months[monthIdx]
        let dayOfMonth = Calendar.current.component(.day, from: blockDate)

        // 2) Now your view is just plain SwiftUI:
        Rectangle()
        .fill(Color(hex: 0xe0dad5))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .overlay {
          HStack(spacing: 12) {
            Divider()
              .frame(width: 3)
              .background(Color(hex: 0xc0b8b2))

            VStack(spacing: 8) {
              Text(dayText)
                .font(.headline)

                ForEach(events, id: \.id) { event in
                    Text("\(event.title)")
                }
            }

            VStack {
              Text("\(monthName) \(dayOfMonth)")
            }
          }
          .padding(.vertical, 8)
        }
        
    }
}

struct UserProfileImage: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var pickerItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color(hex: 0x6d8a96), lineWidth: 1.5)
                .frame(width: 112.5, height: 112.5)
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
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .resizable()
                                .scaledToFit()
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
