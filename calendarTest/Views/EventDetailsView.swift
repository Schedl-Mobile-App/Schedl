//
//  ScheduleEventView.swift
//  calendarTest
//
//  Created by David Medina on 12/16/24.
//

import SwiftUI

struct EventDetailsView: View {
    
    @EnvironmentObject private var viewModel: ScheduleViewModel
    @EnvironmentObject private var userObj: AuthService
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.selectedEvent?.title ?? "No Title")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(viewModel.selectedEvent?.description ?? "No Description")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
            Button(action: {
                createPost()
            }) {
                Text("Create Post")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        .cornerRadius(10)
        .shadow(radius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .transition(.scale)
        .zIndex(1)
    }
    
    private func createPost() {
        let postObj = Post(
            id: UUID().uuidString,
            title: viewModel.selectedEvent?.title ?? "No Title",
            description: viewModel.selectedEvent?.description ?? "No Description",
            creationDate: Date().timeIntervalSince1970
        )
        if let user = userObj.currentUser {
            viewModel.createPost(postObj: postObj, userId: user.id, friendIds: user.friendIds)
            isShowing = false
        }
    }
}
