//
//  FriendsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct FriendCell: View {
    
    let currentUser: User
    let userToDisplay: User
   
    var body: some View {
        NavigationLink(destination: ProfileView(currentUser: currentUser, profileUser: userToDisplay)) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: userToDisplay.profileImage)) { image in
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
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
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
                   if profileViewModel.isLoading {
                       Text("Loading...")
                   } else if let error = profileViewModel.errorMessage {
                       Text(error)
                   } else if let friends = profileViewModel.friends {
                       ForEach(friends) { friend in
                           FriendCell(currentUser: profileViewModel.currentUser, userToDisplay: friend)
                       }
                   } else {
                       Text("No friends yet")
                   }
               }
            }
        }
        .onAppear {
            Task {
                await profileViewModel.fetchFriends()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
