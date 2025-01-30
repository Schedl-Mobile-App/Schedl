//
//  NotificationsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel: NotificationViewModel = NotificationViewModel()
    @EnvironmentObject var userModel: AuthService
    @Environment(\.presentationMode) var presentationMode
   
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Button(action: {
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
            .background(Color(.systemBackground))
            
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
            .onChange(of: userModel.currentUser?.requestIds) {
                viewModel.showFriendRequests(requestIds: userModel.currentUser?.requestIds ?? [])
            }
        }
        .environmentObject(userModel)
        .navigationBarBackButtonHidden(true)
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
