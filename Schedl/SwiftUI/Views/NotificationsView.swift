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
        HStack(spacing: 10) {
            // sender profile image
            Circle()
                .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                .background(Color.clear)
                .frame(width: 56.75, height: 56.75)
                .overlay {
                    Group {
                        switch notification.notificationPayload {
                        case .friendRequest(let friendRequest):
                            AsyncImage(url: URL(string: friendRequest.senderProfileImage)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color(hex: 0xe0dad5))
                                    .frame(width: 55, height: 55)
                                    .overlay {
                                        let splitName = friendRequest.senderName.split(separator: " ")
                                        Text("\(splitName[0].first?.uppercased() ?? "")\(splitName[0].first?.uppercased() ?? "")")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color(hex: 0x333333))
                                            .multilineTextAlignment(.center)
                                    }
                            }
                        case .eventInvite(let eventInvite):
                            AsyncImage(url: URL(string: eventInvite.senderProfileImage)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color(hex: 0xe0dad5))
                                    .frame(width: 55, height: 55)
                                    .overlay {
                                        let splitName = eventInvite.senderName.split(separator: " ")
                                        Text("\(splitName[0].first?.uppercased() ?? "")\(splitName[0].first?.uppercased() ?? "")")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color(hex: 0x333333))
                                            .multilineTextAlignment(.center)
                                    }
                            }
                        }
                    }
                }
            
            // notification description
            VStack(alignment: .leading, spacing: 12) {
                switch notification.notificationPayload {
                case .friendRequest(let fr):
                    Text("\(fr.senderName) sent you a friend request!")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            Task {
                                await notificationViewModel.handleNotificationResponse(
                                    id: notification.id,
                                    responseStatus: false
                                )
                            }
                        }) {
                            Text("Decline")
                                .font(.footnote)
                                .fontWeight(.heavy)
                                .fontDesign(.monospaced)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(hex: 0x333333))
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(
                                     RoundedRectangle(cornerRadius: 5)
                                         .fill(Color.black.opacity(0.1))
                                         .stroke(Color(hex: 0x666666), lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            Task {
                                await notificationViewModel.handleNotificationResponse(
                                    id: notification.id,
                                    responseStatus: true
                                )
                            }
                        }) {
                            Text("Accept")
                                .font(.footnote)
                                .fontWeight(.heavy)
                                .fontDesign(.monospaced)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(hex: 0xf7f4f2))
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(
                                     RoundedRectangle(cornerRadius: 5)
                                         .fill(Color(hex: 0x3C859E))
                                         .stroke(Color(hex: 0x666666), lineWidth: 1)
                                )
                        }
                    }
                case .eventInvite(let ev):
                    Text("\(ev.senderName) invited you to an event!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        Task {
                            await notificationViewModel.handleNotificationResponse(
                                id: notification.id,
                                responseStatus: true
                            )
                        }
                    }) {
                        Text("View Event")
                            .font(.footnote)
                            .fontWeight(.heavy)
                            .fontDesign(.monospaced)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: 0xf7f4f2))
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 35)
                            .background(
                                 RoundedRectangle(cornerRadius: 15)
                                     .fill(Color(hex: 0x3C859E))
                                     .stroke(Color(hex: 0x666666), lineWidth: 1)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding([.top, .horizontal])
    }
}


struct NotificationsView: View {
    @StateObject var notificationViewModel: NotificationViewModel
    @State var showTabBar: Bool = false
    @Environment(\.dismiss) var dismiss
    
    init(currentUser: User) {
        _notificationViewModel = StateObject(wrappedValue: NotificationViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .leading) {
                    Button(action: {
                        showTabBar.toggle()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    
                    
                    Text("Notifications")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                
                if notificationViewModel.isLoading {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                } else if let error = notificationViewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if notificationViewModel.notifications.isEmpty {
                    Spacer()
                    Text("You have no new notifications.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        Text("Today")
                            .foregroundStyle(Color(hex: 0x333333))
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        LazyVStack(spacing: 16) {
                            ForEach(notificationViewModel.notifications) { notification in
                                NotificationCell(notificationViewModel: notificationViewModel, notification: notification)
                                Divider()
                                    .background(Color(hex: 0xc0b8b2))
                                    .frame(maxWidth: .infinity, maxHeight: 1.25)
                            }
                        }
                        .onChange(of: notificationViewModel.notifications) {
                            print("LazyVStack now has \(notificationViewModel.notifications.count) items")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .task {
                await notificationViewModel.fetchNotifications()
            }
            .onAppear{
                notificationViewModel.setupNotificationObserver()
            }
            .onDisappear {
                notificationViewModel.removeNotificationObserver()
            }
            .onChange(of: notificationViewModel.notifications) {
                print("Capturing the changes in the view")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
