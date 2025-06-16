//
//  NotificationsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct NotificationCell: View {
    let notificationViewModel: NotificationViewModel
    let notification: Notification
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar or icon
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Group {
                        switch notification.notificationPayload {
                        case .friendRequest(let fr):
                            // Show sender's profile image if available
                            if let url = URL(string: fr.senderProfileImage) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.gray)
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.gray)
                            }
                        case .eventInvite:
                            // Use a calendar icon for event invites
                            Image(systemName: "calendar")
                                .foregroundStyle(.gray)
                        }
                    }
                )
            
            // Textual info
            VStack(alignment: .leading, spacing: 4) {
                switch notification.notificationPayload {
                case .friendRequest(let fr):
                    Text("\(fr.senderName) sent you a friend request")
                        .font(.headline)
                case .eventInvite(let ev):
                    Text("\(ev.senderName) invited you to an event")
                        .font(.headline)
                }
                
                // Relative time label
                Text(
                    Date(timeIntervalSince1970: notification.creationDate),
                    style: .relative
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button("Accept") {
                    Task {
                        await notificationViewModel.handleNotificationResponse(
                            id: notification.id,
                            responseStatus: true
                        )
                    }
                }
                .frame(width: 80)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("Decline") {
                    Task {
                        await notificationViewModel.handleNotificationResponse(
                            id: notification.id,
                            responseStatus: false
                        )
                    }
                }
                .frame(width: 80)
                .padding(.vertical, 6)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
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
                        ForEach(notificationViewModel.notifications) { notification in
                            NotificationCell(notificationViewModel: notificationViewModel, notification: notification)
                                .padding()
                        }
                    }
                    .onChange(of: notificationViewModel.notifications) { newArr in
                      print("LazyVStack now has \(newArr.count) items")
                    }
                }
            }
            .task {
                await notificationViewModel.fetchNotifications()
            }
            .onAppear{
                notificationViewModel.setupNotificationObserver()
            }
            .onDisappear {
                notificationViewModel.removeNotificationObserver()
            }
            .onChange(of: notificationViewModel.notifications) { newValue in
                print("Capturing the chnages in the view")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(showTabbar ? .visible : .hidden, for: .tabBar)
    }
}
