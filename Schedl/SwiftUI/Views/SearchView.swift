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
        NavigationLink(destination: ProfileView(currentUser: currentUser, profileUser: user)) {
           HStack(spacing: 15) {
               Circle()
                   .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                   .background(Color.clear)
                   .frame(width: 55.75, height: 55.75)
                   .overlay {
                       AsyncImage(url: URL(string: user.profileImage)) { image in
                           image
                               .resizable()
                               .scaledToFill()
                               .frame(width: 54, height: 54)
                               .clipShape(Circle())
                       } placeholder: {
                           // Show while loading or if image fails to load
                           Circle()
                               .fill(Color(hex: 0xe0dad5))
                               .frame(width: 54, height: 54)
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
               
               VStack(alignment: .leading, spacing: 1) {
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
                           .fontWeight(.medium)
                           .fontDesign(.rounded)
                           .foregroundStyle(Color.black.opacity(0.50))
                           .multilineTextAlignment(.leading)
                       Text("\(user.username)")
                           .font(.footnote)
                           .fontWeight(.medium)
                           .fontDesign(.rounded)
                           .tracking(1.05)
                           .foregroundStyle(Color.black.opacity(0.50))
                           .multilineTextAlignment(.leading)
                   }
                   Text("\(numOfFriends) friends | \(numOfPosts) posts")
                       .font(.footnote)
                       .fontWeight(.medium)
                       .fontDesign(.monospaced)
                       .tracking(-0.25)
                       .fixedSize()
                       .foregroundStyle(Color(hex: 0x333333))
                       .multilineTextAlignment(.leading)
               }
               .fixedSize(horizontal: true, vertical: false)
           }
           .frame(maxWidth: .infinity, alignment: .leading)
           .clipShape(RoundedRectangle(cornerRadius: 12))
           .padding(.horizontal)
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
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .foregroundStyle(Color(hex: 0x333333))
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        
                        Spacer()
                        
                        Button("Clear", action: {
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
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if searchViewModel.isLoading {
                        FriendsLoadingView()
                            .padding(.bottom, 1)
                    } else if let error = searchViewModel.errorMessage {
                        Spacer()
                        Text("\(error)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .foregroundStyle(Color(hex: 0x666666))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    } else if searchViewModel.searchResults.isEmpty {
                        Spacer()
                        Text("Search for your friends using their unique username!")
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
                            LazyVStack(spacing: 25) {
                                ForEach (searchViewModel.searchResults) { user in
                                    UserSearchCell(currentUser: searchViewModel.currentUser, user: user)
                                }
                            }
                            .padding(.vertical)
                        }
                        .scrollDismissesKeyboard(.immediately)
                    }
                    
                }
                .padding(.bottom, 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .onTapGesture {
                isFocused = nil
            }
            .environmentObject(searchViewModel)
        }
    }
}
