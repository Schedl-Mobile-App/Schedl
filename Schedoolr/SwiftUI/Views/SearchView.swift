//
//  SearchView.swift
//  Schedoolr
//
//  Created by David Medina on 1/16/25.
//

import SwiftUI

struct UserSearchCell: View {
   
    @EnvironmentObject var searchViewModel: SearchViewModel
    let currentUser: User
    let user: User

    var body: some View {
        NavigationLink(destination: ProfileView(currentUser: currentUser, profileUser: user)
            .toolbar(.visible, for: .tabBar)
        ) {
           HStack(spacing: 15) {
               Circle()
                   .strokeBorder(Color(hex: 0x6d8a96), lineWidth: 1.25)
                   .background(Color.clear)
                   .frame(width: 59.5, height: 59.5)
                   .overlay {
                       AsyncImage(url: URL(string: user.profileImage)) { image in
                           image
                               .resizable()
                               .scaledToFill()
                               .frame(width: 58.25, height: 58.25)
                               .clipShape(Circle())
                       } placeholder: {
                           // Show while loading or if image fails to load
                           Circle()
                               .fill(Color(hex: 0xe0dad5))
                               .frame(width: 58.25, height: 58.25)
                               .overlay {
                                   Text("\(user.displayName.first?.uppercased() ?? "J")\(user.displayName.last?.uppercased() ?? "D")")
                                       .font(.system(size: 24, weight: .bold, design: .monospaced))
                                       .foregroundStyle(Color(hex: 0x333333))
                                       .multilineTextAlignment(.center)
                               }
                       }
                   }
               
               VStack(alignment: .leading) {
                   let numOfPosts = searchViewModel.userInfo[user.id]?.numOfPosts ?? 0
                   let numOfFriends = searchViewModel.userInfo[user.id]?.numOfFriends ?? 0
                   Text("\(user.displayName)")
                       .font(.system(size: 18, weight: .bold, design: .monospaced))
                       .foregroundStyle(Color(hex: 0x333333))
                       .multilineTextAlignment(.leading)
                   Text("\(user.username)")
                       .font(.system(size: 14, weight: .medium, design: .monospaced))
                       .foregroundStyle(Color(hex: 0x333333))
                       .multilineTextAlignment(.leading)
                   Text("\(numOfFriends) friends | \(numOfPosts) posts")
                       .font(.system(size: 12, weight: .medium, design: .monospaced))
                       .fixedSize()
                       .foregroundStyle(Color(hex: 0x666666))
                       .multilineTextAlignment(.leading)
               }
               
               Spacer()
               
               let isFriend = searchViewModel.userInfo[user.id]?.isFriend ?? false
               Button(action: {}) {
                   Text(isFriend ? "Friends" : "Add")
                       .font(.system(size: 16, weight: .medium, design: .monospaced))
                       .foregroundColor(Color(hex: 0xf7f4f2))
                       .padding(.vertical, 6)
                       .padding(.horizontal, 24)
                       .frame(minHeight: 44)
                       .background(
                           Capsule()
                               .fill(Color(hex: 0x6d8a96))
                       )
                       .contentShape(Capsule())
               }
               .accessibilityLabel(isFriend ? "Remove friend" : "Add friend")
           }
           .frame(maxWidth: .infinity, alignment: .leading)
           .clipShape(RoundedRectangle(cornerRadius: 12))
           .padding()
       }
    }
}

struct SearchView: View {
    @StateObject var searchViewModel: SearchViewModel
    
    init(currentUser: User) {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(currentUser: currentUser))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 10) {
                    Button {}
                        label : {
                       Image(systemName: "magnifyingglass")
                           .foregroundStyle(.gray)
                           .font(.system(size: 16))
                    }

                    TextField("Search friends", text: $searchViewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                    
                    Spacer()
                    
                    Button("Cancel", action: {
                        searchViewModel.searchText = ""
                    })
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x6d8a96))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                            
                if searchViewModel.isLoading {
                    Spacer()
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if let error = searchViewModel.errorMessage {
                    Spacer()
                    Text("\(error)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if searchViewModel.searchResults.isEmpty {
                    Spacer()
                    Text("Search for your friends using their unique username!")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 5) {
                            Divider()
                                .background(Color(hex: 0xc0b8b2))
                                .frame(maxWidth: .infinity, maxHeight: 1.25)
                            ForEach (searchViewModel.searchResults) { user in
                                UserSearchCell(currentUser: searchViewModel.currentUser, user: user)
                                Divider()
                                    .background(Color(hex: 0xc0b8b2))
                                    .frame(maxWidth: .infinity, maxHeight: 1.25)
                            }
                        }
                        .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }
            .background(Color(hex: 0xf7f4f2))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .environmentObject(searchViewModel)
        }
    }
}
