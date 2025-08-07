//
//  FriendsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

struct FriendCell: View {
    
    @EnvironmentObject var tabBarState: TabBarState
    
    @ObservedObject var profileViewModel: ProfileViewModel
    let userToDisplay: User
    
    @Binding var selectedUser: User?
    @Binding var shouldNavigate: Bool
    
    var body: some View {
        Button(action: {
            tabBarState.hideTabbar = false
            selectedUser = userToDisplay
            shouldNavigate = true
        }) {
            HStack(spacing: 15) {
                Circle()
                    .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                    .background(Color.clear)
                    .frame(width: 55.75, height: 55.75)
                    .overlay {
                        AsyncImage(url: URL(string: userToDisplay.profileImage)) { image in
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
                                    Text("\(userToDisplay.displayName.first?.uppercased() ?? "J")\(userToDisplay.displayName.last?.uppercased() ?? "D")")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .multilineTextAlignment(.center)
                                }
                        }
                    }
                
                VStack(alignment: .leading) {
                    let numOfPosts = profileViewModel.friendsInfoDict[userToDisplay.id]?.numOfPosts ?? 0
                    let numOfFriends = profileViewModel.friendsInfoDict[userToDisplay.id]?.numOfFriends ?? 0
                    Text("\(userToDisplay.displayName)")
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
                        Text("\(userToDisplay.username)")
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

struct FriendsView: View {
    
    @EnvironmentObject var tabBarState: TabBarState
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @FocusState var isSearching: Bool?
    
    @State var shouldNavigate = false
    @State var selectedUser: User?
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return profileViewModel.friends
        } else {
            let filteredResults = profileViewModel.friends.filter { user in
                let startsWith = user.displayName.lowercased().hasPrefix(searchText.lowercased())
                let endsWith = user.displayName.lowercased().hasSuffix(searchText.lowercased())
                
                return startsWith || endsWith
            }
            
            return filteredResults
        }
    }

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .leading) {
                    Button(action: {
                        tabBarState.hideTabbar = false
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    Text("Friends")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .imageScale(.medium)
                    }
                    
                    TextField("Search friends", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($isSearching, equals: true)
                    
                    Spacer()
                    
                    Button("Clear", action: {
                        searchText = ""
                    })
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .opacity(!searchText.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                
                if profileViewModel.isLoadingFriendView {
                    FriendsLoadingView()
                        .padding(.bottom, 1)
                } else if let error = profileViewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if profileViewModel.friends.count > 0 {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 25) {
                            ForEach(filteredUsers, id: \.id) { user in
                                FriendCell(profileViewModel: profileViewModel, userToDisplay: user, selectedUser: $selectedUser, shouldNavigate: $shouldNavigate)
                            }
                        }
                        .padding(.vertical)
                    }
                    .scrollDismissesKeyboard(.immediately)
                } else {
                    Spacer()
                    Text("You haven't added any friends yet! You can start by searching for friends in the search page.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x666666))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            .padding(.bottom, 0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onTapGesture {
            isSearching = nil
        }
        .task {
            await profileViewModel.loadFriendsData()
        }
        .onAppear {
            tabBarState.hideTabbar = true
            profileViewModel.shouldReloadData = false
        }
        .onDisappear {
            profileViewModel.shouldReloadData = true
        }
        .toolbar(tabBarState.hideTabbar ? .hidden : .visible, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $shouldNavigate) {
            if let user = selectedUser {
                ProfileView(currentUser: profileViewModel.currentUser, profileUser: user)
                    .environmentObject(tabBarState)
            }
        }
    }
}
