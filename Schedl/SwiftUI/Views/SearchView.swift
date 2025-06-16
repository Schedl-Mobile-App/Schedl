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
                   .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                   .background(Color.clear)
                   .frame(width: 53.75, height: 53.75)
                   .overlay {
                       AsyncImage(url: URL(string: user.profileImage)) { image in
                           image
                               .resizable()
                               .scaledToFill()
                               .frame(width: 52, height: 52)
                               .clipShape(Circle())
                       } placeholder: {
                           // Show while loading or if image fails to load
                           Circle()
                               .fill(Color(hex: 0xe0dad5))
                               .frame(width: 52, height: 52)
                               .overlay {
                                   Text("\(user.displayName.first?.uppercased() ?? "J")\(user.displayName.last?.uppercased() ?? "D")")
                                       .font(.title3)
                                       .fontWeight(.bold)
                                       .fontDesign(.monospaced)
                                       .tracking(-0.25)
                                       .foregroundStyle(Color(hex: 0x333333))
                                       .multilineTextAlignment(.center)
                               }
                       }
                   }
               
               VStack(alignment: .leading) {
                   let numOfPosts = searchViewModel.userInfo[user.id]?.numOfPosts ?? 0
                   let numOfFriends = searchViewModel.userInfo[user.id]?.numOfFriends ?? 0
                   Text("\(user.displayName)")
                       .font(.subheadline)
                       .fontWeight(.bold)
                       .fontDesign(.monospaced)
                       .tracking(-0.10)
                       .foregroundStyle(Color(hex: 0x333333))
                       .multilineTextAlignment(.leading)
                   HStack(spacing: 0) {
                       Text("@")
                           .font(.footnote)
                           .foregroundStyle(Color(.systemGray))
                           .multilineTextAlignment(.leading)
                       Text("\(user.username)")
                           .font(.footnote)
                           .fontWeight(.medium)
                           .fontDesign(.monospaced)
                           .tracking(-0.25)
                           .foregroundStyle(Color(.systemGray))
                           .multilineTextAlignment(.leading)
                   }
                   Text("\(numOfFriends) friends | \(numOfPosts) posts")
                       .font(.caption)
                       .fontWeight(.medium)
                       .fontDesign(.monospaced)
                       .tracking(-0.25)
                       .fixedSize()
                       .foregroundStyle(Color(.systemGray))
                       .multilineTextAlignment(.leading)
               }
               .fixedSize(horizontal: true, vertical: false)
               
               Spacer()
               
               let isFriend = searchViewModel.userInfo[user.id]?.isFriend ?? false
               Button(action: {}) {
                   Text(isFriend ? "Friends" : "Add")
                       .font(.footnote)
                       .fontWeight(.bold)
                       .fontDesign(.monospaced)
                       .tracking(-0.25)
                       .fixedSize()
                       .foregroundColor(isFriend ? Color(.black) : Color(hex: 0xf7f4f2))
                       .padding(.vertical, 6)
                       .padding(.horizontal, 24)
                       .frame(minHeight: 44)
                       .background(
                           Capsule()
                            .fill(isFriend ? Color.black.opacity(0.1) : Color(hex: 0x3C859E))
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
    @FocusState var isFocused: Bool?
    
    init(currentUser: User) {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(currentUser: currentUser))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0xf7f4f2)
                    .ignoresSafeArea()
                VStack(spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Button {}
                        label : {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                                .imageScale(.medium)
                        }
                        
                        TextField("Search friends", text: $searchViewModel.searchText)
                            .focused($isFocused, equals: true)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .autocorrectionDisabled(true)
                        
                        Spacer()
                        
                        Button("Cancel", action: {
                            searchViewModel.searchText = ""
                        })
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x3C859E))
                        .opacity(!searchViewModel.searchText.isEmpty ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: searchViewModel.searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
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
                        }
                        .frame(maxWidth: .infinity)
                        .scrollDismissesKeyboard(.immediately)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .onTapGesture {
                isFocused = nil
            }
            .environmentObject(searchViewModel)
        }
    }
}
