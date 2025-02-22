//
//  FriendsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct FriendCell: View {
    let userToDisplay: User
   
    var body: some View {
        NavigationLink(destination: ProfileView(userid: userToDisplay.id)) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: userToDisplay.profileImage ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    // Show while loading or if image fails to load
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .clipShape(Circle())
                .frame(width: 40, height: 40)
                
                Text(userToDisplay.username)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

struct FriendsView: View {
    
    @StateObject var viewModel: FriendsViewModel = FriendsViewModel()
    @EnvironmentObject var userObj: AuthService
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.primary)
                }
                Text("Friends")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 25, weight: .bold))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            
            ScrollView {
               VStack(spacing: 12) {
                   if viewModel.isLoading {
                       Text("Loading...")
                   } else if let error = viewModel.errorMessage {
                       Text(error)
                   } else if !viewModel.friends.isEmpty {
                       ForEach(viewModel.friends) { friend in
                           FriendCell(userToDisplay: friend)
                       }
                   } else {
                       Text("No friends yet")
                   }
               }
            }
        }
        .onAppear {
            if let user = userObj.currentUser {
               viewModel.fetchFriends(friendIds: user.friendIds)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FriendsView()
        .environmentObject(FriendsViewModel())
        .environmentObject(AuthService())
}
