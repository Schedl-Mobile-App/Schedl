//
//  SearchView.swift
//  Schedoolr
//
//  Created by David Medina on 1/16/25.
//

import SwiftUI

struct UserSearchCell: View {
   
   let user: User
   
   var body: some View {
       NavigationLink(destination: ProfileView(userid: user.id)) {
           HStack(spacing: 18) {
               AsyncImage(url: URL(string: user.profileImage ?? "")) { image in
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
    @StateObject var viewModel: SearchViewModel = SearchViewModel()
    @EnvironmentObject var userObj: AuthService

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 10) {
                    Button {}
                        label : {
                       Image(systemName: "magnifyingglass")
                           .foregroundStyle(.gray)
                    }

                    TextField("Search friends", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                            
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text("\(error)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if viewModel.searchResults.isEmpty {
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
                            ForEach (viewModel.searchResults) { user in
                                UserSearchCell(user: user)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .environmentObject(viewModel)
            .padding(.horizontal)
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(AuthService())
}
