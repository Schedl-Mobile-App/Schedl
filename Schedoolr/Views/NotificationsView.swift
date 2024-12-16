//
//  NotificationsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct NotificationsView: View {
    @Binding var isShowing: Bool
    @StateObject var viewModel: NotificationViewModel = NotificationViewModel()
    @EnvironmentObject var userModel: AuthService
    
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
   
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Friend Requests")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { isShowing.toggle() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.title2)
                    }
                }
                .padding()
                
                Divider()
                
                // Friend Request List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if let requests = viewModel.incomingFriendRequests {
                            ForEach(requests) { request in
                                requestCell(request: request)
                            }
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                        }
                    }
                    .padding()
                }
                .onAppear{
                    if let user = userModel.currentUser {
                        viewModel.showFriendRequests(requestIds: user.requestIds)
                    }
                }
                .onChange(of: userModel.currentUser?.requestIds) { newRequestIds in
                    if let requestIds = newRequestIds {
                        viewModel.showFriendRequests(requestIds: requestIds)
                    }
                }
            }
        }
        .environmentObject(userModel)
    }
        
    private func requestCell(request: FriendRequests) -> some View {
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
                    if let user = userModel.currentUser {
                        viewModel.handleFriendRequestResponse(requestId: user.requestIds[0], response: true)
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
                    if let user = userModel.currentUser {
                        viewModel.handleFriendRequestResponse(requestId: user.requestIds[0], response: false)
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
