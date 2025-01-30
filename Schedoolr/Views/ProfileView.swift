//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI

struct UserTabbedSchedulesView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        if viewModel.profileUser != nil {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.schedules?.title ?? "")
                                .fontWeight(.medium)
                            Text(viewModel.schedules?.userId ?? "")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchTabInfo()
                }
            }
        }
    }
}

struct UserTabbedPostsView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        if !(viewModel.posts?.isEmpty ?? true) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.posts ?? []) { post in
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .fontWeight(.medium)
                                Text(post.description)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchTabInfo()
                }
            }
        } else {
            Text("You haven't made any posts yet...")
        }
    }
}

struct UserInfoView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @EnvironmentObject var userObj: AuthService
        
    var body: some View {
        
        Image(viewModel.profileUser?.profileImage ?? "avatar")
            .resizable()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.top, -90)
        
        VStack(spacing: 0) {
            Text(viewModel.profileUser?.username ?? "")
                .font(.title2)
                .bold()
        }
        
        if viewModel.isCurrentUser {
            NavigationLink(destination: FriendsView()) {
                HStack {
                    // Follower avatars
                    HStack(spacing: -8) {
                        ForEach(0..<min(viewModel.numOfFriends(), 5), id: \.self) { index in
                            Image(systemName: "avatar")
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                    }
                    
                    Text("\(viewModel.numOfFriends()) Friends")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
        } else if !(userObj.currentUser?.friendIds.contains(viewModel.profileUser?.id ?? "") ?? false){
            Button(action: {
                if let user = userObj.currentUser {
                    Task {
                        await viewModel.sendFriendRequest(toUserName: viewModel.profileUser?.username ?? "", fromUserObj: user)
                    }
                }
            }, label: {
                Label("Send Friend Request", systemImage: "person.fill.checkmark.rtl")
            })
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
}

struct ProfileTabbedView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                VStack(spacing: 0) {
                    Text(tab.title)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .onTapGesture {
                            viewModel.selectedTab = tab
                        }
                    
                    // Active indicator
                    if tab == viewModel.selectedTab {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 2)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 2)
                    }
                }
            }
        }
    }
}

struct ProfileView: View {
    
    @EnvironmentObject var authService: AuthService
    @StateObject var scheduleViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(userid: String) {
        _scheduleViewModel = StateObject(wrappedValue: ProfileViewModel(
            userid: userid
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Backdrop gradient with lines effect
            ZStack(alignment: .top) {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.4, blue: 0.5).opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                HStack(spacing: 0) {
                    ForEach(0..<8) { _ in
                        Rectangle()
                            .fill(Color.cyan.opacity(0.05))
                    }
                }
                
                if !scheduleViewModel.isCurrentUser {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .medium))
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(Color.primary)
                                .padding(.vertical, 55)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 200)
            
            ZStack(alignment: .top) {
                Circle()
                    .trim(from: 0.5, to: 1)
                    .frame(width: UIScreen.main.bounds.width * 2)
                    .offset(y: -75)
                    .foregroundColor(Color(.systemBackground))
                    .zIndex(1)

                
                // Profile content
                VStack(spacing: 16) {
                    UserInfoView()
                    ProfileTabbedView()
                    switch scheduleViewModel.selectedTab {
                    case .schedules:
                        UserTabbedSchedulesView()
                    case .posts:
                        UserTabbedPostsView()
                    case .tagged:
                        Text("Tagged Posts Section")
                    case .likes:
                        Text("Liked Posts Section")
                    }
                }
                .environmentObject(scheduleViewModel)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .padding(.horizontal)
                .zIndex(2)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea()
        .onAppear() {
            if let user = authService.currentUser {
                scheduleViewModel.checkIfCurrentUser(user: user)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ProfileView(userid: "1")
        .environmentObject(AuthService())
        .environmentObject(ProfileViewModel(userid: "2"))
}
