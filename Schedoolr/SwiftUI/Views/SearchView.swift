//
//  SearchView.swift
//  Schedoolr
//
//  Created by David Medina on 1/16/25.
//

import SwiftUI

struct UserSearchCell: View {
   
    let currentUser: User
    let user: User

    var body: some View {
       NavigationLink(destination: ProfileView(currentUser: currentUser, profileUserId: user.id)) {
           HStack(spacing: 18) {
               AsyncImage(url: URL(string: user.profileImage)) { image in
                   image
                       .font(.system(size: 35))
               } placeholder: {
                   // Show while loading or if image fails to load
                   Image(systemName: "person.circle.fill")
                       .foregroundColor(.gray)
                       .font(.system(size: 35))
               }
               .clipShape(Circle())
               Text(user.username)
                   .font(.system(size: 18))
           }
           .frame(maxWidth: .infinity, alignment: .leading)
           .clipShape(RoundedRectangle(cornerRadius: 12))
           .padding()
           .padding(.horizontal)
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
                    }

                    TextField("Search friends", text: $searchViewModel.searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                            
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
                    Spacer(minLength: 10)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 5) {
                            ForEach (searchViewModel.searchResults) { user in
                                UserSearchCell(currentUser: searchViewModel.currentUser, user: user)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .environmentObject(searchViewModel)
            .padding(.horizontal)
        }
    }
}
