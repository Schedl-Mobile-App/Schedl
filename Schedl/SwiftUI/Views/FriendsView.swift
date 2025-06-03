//
//  FriendsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct FriendCell: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    let currentUser: User
    let userToDisplay: User
    
    var body: some View {
        NavigationLink(destination: ProfileView(currentUser: currentUser, profileUser: userToDisplay)) {
           HStack(spacing: 15) {
               Circle()
                   .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                   .background(Color.clear)
                   .frame(width: 59.75, height: 59.75)
                   .overlay {
                       AsyncImage(url: URL(string: userToDisplay.profileImage)) { image in
                           image
                               .resizable()
                               .scaledToFill()
                               .frame(width: 58, height: 58)
                               .clipShape(Circle())
                       } placeholder: {
                           // Show while loading or if image fails to load
                           Circle()
                               .fill(Color(hex: 0xe0dad5))
                               .frame(width: 58, height: 58)
                               .overlay {
                                   Text("\(userToDisplay.displayName.first?.uppercased() ?? "J")\(userToDisplay.displayName.last?.uppercased() ?? "D")")
                                       .font(.system(size: 24, weight: .bold, design: .monospaced))
                                       .foregroundStyle(Color(hex: 0x333333))
                                       .multilineTextAlignment(.center)
                               }
                       }
                   }
               
               VStack(alignment: .leading) {
                   let numOfPosts = profileViewModel.friendsInfoDict[userToDisplay.id]?.numOfPosts ?? 0
                   let numOfFriends = profileViewModel.friendsInfoDict[userToDisplay.id]?.numOfFriends ?? 0
                   Text("\(userToDisplay.displayName)")
                       .font(.system(size: 16, weight: .bold, design: .monospaced))
                       .foregroundStyle(Color(hex: 0x333333))
                       .multilineTextAlignment(.leading)
                   Text("\(userToDisplay.username)")
                       .font(.system(size: 14, weight: .medium, design: .monospaced))
                       .foregroundStyle(Color(hex: 0x333333))
                       .multilineTextAlignment(.leading)
                   Text("\(numOfFriends) friends | \(numOfPosts) posts")
                       .font(.system(size: 12, weight: .medium, design: .monospaced))
                       .foregroundStyle(Color(hex: 0x666666))
                       .multilineTextAlignment(.leading)
               }
               .fixedSize(horizontal: true, vertical: false)

           }
           .frame(maxWidth: .infinity, alignment: .leading)
           .clipShape(RoundedRectangle(cornerRadius: 12))
           .padding()
       }
    }
}

struct FriendsView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
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
                
                ScrollView {
                   VStack(spacing: 12) {
                       if profileViewModel.isLoading {
                           Text("Loading...")
                       } else if let error = profileViewModel.errorMessage {
                           Text(error)
                       } else if profileViewModel.friends.count > 0 {
                           LazyVStack(spacing: 5) {
                               Divider()
                                   .background(Color(hex: 0xc0b8b2))
                                   .frame(maxWidth: .infinity, maxHeight: 1.25)
                               ForEach(profileViewModel.friends.indices, id: \.self) { index in
                                   FriendCell(currentUser: profileViewModel.currentUser, userToDisplay: profileViewModel.friends[index])
                                   Divider()
                                       .background(Color(hex: 0xc0b8b2))
                                       .frame(maxWidth: .infinity, maxHeight: 1.25)
                               }
                           }
                       } else {
                           Text("No friends yet")
                       }
                   }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            Task {
                await profileViewModel.fetchFriends()
                await profileViewModel.fetchFriendsInfo(userId: profileViewModel.profileUser.id)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
