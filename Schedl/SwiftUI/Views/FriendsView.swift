//
//  FriendsView.swift
//  calendarTest
//
//  Created by David Medina on 12/12/24.
//

import SwiftUI

class FriendViewModel: ObservableObject {
    var profileUser: User
    private var userService: UserServiceProtocol
    private var eventService: EventServiceProtocol
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @Published var searchText = ""
    @Published var isSearching = false
    
    @Published var friends: [User] = []
    @Published var availabilityList: [FriendAvailability] = []
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return friends
        } else {
            let filteredResults = friends.filter { user in
                let startsWith = user.displayName.lowercased().hasPrefix(searchText.lowercased())
                let endsWith = user.displayName.lowercased().hasSuffix(searchText.lowercased())
                
                return startsWith || endsWith
            }
            
            return filteredResults
        }
    }
    
    init(profileUser: User, userService: UserServiceProtocol = UserService.shared, eventService: EventServiceProtocol = EventService.shared) {
        self.profileUser = profileUser
        self.userService = userService
        self.eventService = eventService
    }
    
    @MainActor
    func fetchFriends() async {
        
        isLoading = true
        errorMessage = nil
        
        do {
            let friends = try await userService.fetchUserFriends(userId: profileUser.id)
            self.friends = friends
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch any friends. Refresh to try again."
            isLoading = false
        }
    }
    
    @MainActor
    func fetchFriendsAvailability(eventDate: Date?, startTime: Date?, endTime: Date?) async {
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            guard let eventDate = eventDate, let startTime = startTime, let endTime = endTime else {
                self.errorMessage = "Please fill out the event date, start time, and end time to check if your friends are available!"
                self.isLoading = false
                return
            }
            
            self.friends = try await userService.fetchUserFriends(userId: profileUser.id)
            
            let normalizedStartTime: Double = floor(Date.computeTimeSinceStartOfDay(date: startTime) / 900.0) * 900.0
            let normalizedEventDate = eventDate.timeIntervalSince1970
            
            self.availabilityList = try await eventService.checkAvailability(userIds: friends.map(\.id), eventDate: normalizedEventDate, startTime: normalizedStartTime, endTime: endTime.timeIntervalSince1970)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch friends availability. Refresh to try again."
            self.isLoading = false
        }
    }
}

struct FriendsView: View {
    
    @Environment(\.router) var coordinator: Router
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm: FriendViewModel
    
    init(profileUser: User) {
        _vm = StateObject(wrappedValue: FriendViewModel(profileUser: profileUser))
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if vm.isLoading {
                FriendsLoadingView()
            } else if let error = vm.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if vm.friends.count > 0 {
                List {
                    if #available(iOS 26.0, *) {
                        if vm.isSearching {
                            Section(content: {
                                ForEach(vm.filteredUsers, id: \.id) { friend in
                                    Button(action: {
                                        coordinator.push(page: .profile(currentUser: vm.profileUser, profileUser: friend, preferBackButton: true))
                                    }, label: {
                                        UserCell(user: friend)
                                            .listRowBackground(Color.clear)
                                    })
                                }
                            }, header: {
                                    HStack {
                                        Text("Friends")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .foregroundStyle(Color("PrimaryText"))
                                        
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                            })
                            .listSectionMargins(.top, -12.5)
                            .listSectionSeparator(.hidden, edges: .top)
                        } else {
                            Section(content: {
                                ForEach(vm.filteredUsers, id: \.id) { friend in
                                    Button(action: {
                                        coordinator.push(page: .profile(currentUser: vm.profileUser, profileUser: friend, preferBackButton: true))
                                    }, label: {
                                        UserCell(user: friend)
                                            .listRowBackground(Color.clear)
                                    })
                                }
                            })
                            .listSectionSeparator(.hidden, edges: .top)
                        }
                    } else {
                        Section(content: {
                            ForEach(vm.filteredUsers, id: \.id) { friend in
                                Button(action: {
                                    coordinator.push(page: .profile(currentUser: vm.profileUser, profileUser: friend, preferBackButton: true))
                                }, label: {
                                    UserCell(user: friend)
                                        .listRowBackground(Color.clear)
                                })
                            }
                        }, header: {
                            EmptyView()
                        })
                        .listSectionSeparator(.hidden, edges: .top)
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.immediately)
                
            } else if !vm.searchText.isEmpty && vm.filteredUsers.isEmpty {
                Text("No friends matching the username entered were found.")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("You haven't added any friends yet!You can start by searching for friendsin the search page.")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .task {
            await vm.fetchFriends()
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Friends")
                    .foregroundStyle(Color("PrimaryText"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
            
            if #available(iOS 26, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
        }
        .modifier(FriendViewModifier(searchText: $vm.searchText, isSearching: $vm.isSearching))
    }
}

struct FriendViewModifier: ViewModifier {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .searchable(text: $searchText, isPresented: $isSearching, prompt: Text("Search Friends"))
        } else {
            content
                .searchable(text: $searchText, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Friends"))
        }
    }
}
