//
//  NotificationsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

import Kingfisher

struct ThumbnailProfileImageView: View {
    
    @State private var imageLoadingError = false
    var profileImage: String
    var displayName: String
    
    var body: some View {
        if !imageLoadingError {
            KFImage.url(URL(string: profileImage))
                .placeholder {
                    ProgressView()
                }
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .onProgress { receivedSize, totalSize in  }
                .onSuccess { result in  }
                .onFailure { _ in
                    self.imageLoadingError = true
                }
                .resizable() // Makes the image resizable
                .scaledToFill() // Fills the frame, preventing distortion
                .frame(width: 55.75, height: 55.75) // Sets a square frame for the circle
                .clipShape(Circle()) // Clips the view into a circle shape
                .alignmentGuide(.listRowSeparatorLeading) {
                                    $0[.leading]
                                }
        } else {
            Circle()
                .strokeBorder(Color("ButtonColors"), lineWidth: 1.75)
                .background(Color.clear)
                .frame(width: 55.75, height: 55.75)
                .overlay {
                    // Show while loading or if image fails to load
                    Circle()
                        .fill(Color("SectionalColors"))
                        .frame(width: 54, height: 54)
                        .overlay {
                            Text("\(displayName.first?.uppercased() ?? "J")\(displayName.last?.uppercased() ?? "D")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .multilineTextAlignment(.center)
                        }
                }
        }
    }
}

struct FriendRequestNotificationView: View {
    
    var friendRequest: FriendRequest
    
    var fromUser: User {
        return User(id: friendRequest.fromUserId, email: nil, displayName: friendRequest.senderName, username: nil, profileImage: friendRequest.senderProfileImage, numOfEvents: nil, numOfFriends: nil, numOfPosts: nil)
    }
    
    var body: some View {
        NavigationLink(value: NotificationDestination.profileView(fromUser), label: {
            HStack(spacing: 15) {
                ThumbnailProfileImageView(profileImage: friendRequest.senderProfileImage, displayName: friendRequest.senderName)
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(friendRequest.senderName) sent you a friend request.")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.10)
                        .foregroundStyle(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .alignmentGuide(.listRowSeparatorTrailing) {
                        $0[.trailing]
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        })
    }
}

struct EventInviteNotificationView: View {
    
    var eventInvite: EventInvite
    
    var body: some View {
        NavigationLink(value: NotificationDestination.eventDetails, label: {
            HStack(spacing: 15) {
                ThumbnailProfileImageView(profileImage: eventInvite.senderProfileImage, displayName: eventInvite.senderName)
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(eventInvite.senderName) sent you an event invite. Click here to see the event.")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .alignmentGuide(.listRowSeparatorTrailing) {
                        $0[.trailing]
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        })
    }
}

struct BlendInviteNotificationView: View {
    
    var blendInvite: BlendInvite
    
    var body: some View {
        NavigationLink(value: NotificationDestination.blendDetails, label: {
            HStack(spacing: 15) {
                ThumbnailProfileImageView(profileImage: blendInvite.senderProfileImage, displayName: blendInvite.senderName)
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(blendInvite.senderName) sent you an blend invite. Click here to see the blend.")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .alignmentGuide(.listRowSeparatorTrailing) {
                        $0[.trailing]
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        })
    }
}

struct NotificationCell: View {
    
    let notification: Notification
    
    var body: some View {
        switch notification.notificationPayload {
        case .friendRequest(let friendRequest):
            FriendRequestNotificationView(friendRequest: friendRequest)
            
        case .eventInvite(let eventInvite):
            EventInviteNotificationView(eventInvite: eventInvite)
            
        case .blendInvite(let blendInvite):
            BlendInviteNotificationView(blendInvite: blendInvite)
            
        case .unknown:
            EmptyView()
        }
    }
}

enum NotificationDestination: Hashable {
    case profileView(User)
    case eventDetails
    case blendDetails
}

struct NotificationsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var notificationViewModel: NotificationViewModel
    
    init(currentUser: User) {
        _notificationViewModel = StateObject(wrappedValue: NotificationViewModel(currentUser: currentUser))
    }
    
    func formattedDayString(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    func delete(at offsets: IndexSet) {
        notificationViewModel.notifications.remove(atOffsets: offsets)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if notificationViewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let error = notificationViewModel.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if notificationViewModel.notifications.isEmpty {
                Text("You have no new notifications.")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                List {
                    ForEach(notificationViewModel.notifications, id: \.id) { notification in
                        if notificationViewModel.notifications.first == notification {
                            NotificationCell(notification: notification)
                                .listRowSeparator(.hidden, edges: .top)
                                .listRowBackground(Color.clear)
                        } else {
                            NotificationCell(notification: notification)
                                .listRowBackground(Color.clear)
                            
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
                    await notificationViewModel.fetchNotifications()
                }
            }
        }
        .navigationDestination(for: NotificationDestination.self) { destination in
            switch destination {
            case .profileView(let user):
                ProfileView(currentUser: notificationViewModel.currentUser, profileUser: user, preferBackButton: true)
            case .eventDetails:
                EmptyView()
            case .blendDetails:
                EmptyView()
            }
        }
        .task {
            await notificationViewModel.fetchNotifications()
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .subtitle) {
                    Text("Notifications")
                        .foregroundStyle(Color("PrimaryText"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                }
            } else {
                ToolbarItem(placement: .title) {
                    Text("Notifications")
                        .foregroundStyle(Color("PrimaryText"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                }
            }
        }
    }
}

