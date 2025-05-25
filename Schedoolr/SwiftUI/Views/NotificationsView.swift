//
//  NotificationsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct RequestCell: View {
    
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    let request: FriendRequest
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(.gray)
                )
            
            // Name
            Text(request.senderName)
                .font(.headline)
            
            Spacer()
            
            // Accept/Decline Buttons
            HStack(spacing: 8) {
                Button(action: {
                    Task {
                        await notificationViewModel.handleFriendRequestResponse(requestId: request.id, accepted: true)
                    }
                }) {
                    Text("Accept")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(width: 80)
                
                Button(action: {
                    Task {
                        await notificationViewModel.handleFriendRequestResponse(requestId: request.id, accepted: false)
                    }
                }) {
                    Text("Decline")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(width: 80)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct NotificationsView: View {
    @StateObject var notificationViewModel: NotificationViewModel
    @State var showTabbar: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    init(currentUser: User) {
        _notificationViewModel = StateObject(wrappedValue: NotificationViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Button(action: {
                        showTabbar.toggle()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.primary)
                    }
                    Text("Notifications")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 25, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Friend Request List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(notificationViewModel.friendRequests) { request in
                            RequestCell(request: request)
                        }
                        .padding()
                    }
                }
            }
        }
        .environmentObject(notificationViewModel)
        .navigationBarBackButtonHidden(true)
        .toolbar(showTabbar ? .visible : .hidden, for: .tabBar)
        .onAppear{
            Task {
                await notificationViewModel.fetchFriendRequests()
            }
        }
    }
}
