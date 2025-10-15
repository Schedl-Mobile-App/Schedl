//
//  SearchView.swift
//  Schedoolr
//
//  Created by David Medina on 1/16/25.
//

import SwiftUI
import Kingfisher

struct UserCell: View {
    
    let user: User
    @State private var imageLoadingError = false

    var body: some View {
        HStack(spacing: 15) {
            ThumbnailProfileImageView(profileImage: user.profileImage, displayName: user.displayName)
                .alignmentGuide(.listRowSeparatorLeading) {
                    $0[.leading]
                }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("\(user.displayName)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color("PrimaryText"))
                    .multilineTextAlignment(.leading)
                HStack(spacing: 0) {
                    Text("@")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color("SecondaryText"))
                        .multilineTextAlignment(.leading)
                    Text("\(user.username)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .tracking(1.05)
                        .foregroundStyle(Color("SecondaryText"))
                        .multilineTextAlignment(.leading)
                }
//                Text("\(user.numOfFriends) friends | \(user.numOfPosts) posts")
//                    .font(.footnote)
//                    .fontWeight(.medium)
//                    .fontDesign(.monospaced)
//                    .tracking(-0.25)
//                    .foregroundStyle(Color("PrimaryText"))
//                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .alignmentGuide(.listRowSeparatorTrailing) {
                    $0[.trailing]
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RecentSearches {
    static private let key = "recent_searches"
    static private let maxCount = 10
    
    static func save(_ searchedUser: User) {
        var searches = getRecentSearches()
        
        // Remove if already exists (to move to front)
        searches.removeAll { $0.id == searchedUser.id }
        
        // Add to front
        searches.insert(searchedUser, at: 0)
        
        // Limit count
        if searches.count > maxCount {
            searches = Array(searches.prefix(maxCount))
        }
        
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(searches) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: key)
    }
    
    static func delete(at offsets: IndexSet) {
        var searches = getRecentSearches()
        
        searches.remove(atOffsets: offsets)
        
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(searches) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: key)
    }
    
    static func getRecentSearches() -> [User] {
        let decoder = JSONDecoder()
        
        if let encodedData = UserDefaults.standard.data(forKey: key) {
            guard let recentSearches = try? decoder.decode([User].self, from: encodedData) else {
                return []
            }
            
            return recentSearches
        }
        
        return []
    }
    
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct SearchView: View {
    
    @Environment(\.router) var coordinator: Router
    @StateObject var vm: SearchViewModel
    @Namespace private var namespace
    
    init(currentUser: User) {
        _vm = StateObject(wrappedValue: SearchViewModel(currentUser: currentUser))
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            if vm.isLoading {
                FriendsLoadingView(showSearchTitle: true)
            } else if let error = vm.errorMessage {
                Text("\(error)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if vm.isSearching && vm.searchText.isEmpty {
                if vm.recentSearches.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(Color("ScheduleButtonColors"))
                        VStack {
                            Text("No Recent Searches")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("SecondaryText"))
                            Text("Your recent searches will\nappear here")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        Section(content: {
                            ForEach(vm.recentSearches, id: \.id) { user in
                                Button(action: {
                                    coordinator.push(page: .profile(currentUser: vm.currentUser, profileUser: user, preferBackButton: true, namespace: namespace))
                                }, label: {
                                    UserCell(user: user)
                                        .matchedTransitionSource(id: "zoom", in: namespace)
                                })
                            }
                            .onDelete(perform: vm.delete)
                            
                        }, header: {
                            HStack(alignment: .center) {
                                Text("Recently Searched")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(Color("PrimaryText"))
                                
                                Spacer()
                                
                                Button(action: {
                                    vm.showClearSearchesAlert = true
                                }) {
                                    Text("Clear")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(Color("ErrorTextColor"))
                                }
                                .alert("Clear Searches", isPresented: $vm.showClearSearchesAlert) {
                                    Button("Clear Searches", role: .destructive) {
                                        withAnimation {
                                            vm.recentSearches.removeAll()
                                        }
                                        RecentSearches.clearAll()
                                    }
                                    Button("Cancel", role: .cancel) {
                                        vm.showClearSearchesAlert = false
                                    }
                                } message: {
                                    Text("Clearing your searches will remove your search history from this device.")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        })
                        .listSectionSeparator(.hidden, edges: .top)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .listRowBackground(Color("BackgroundColor"))
                    .scrollDismissesKeyboard(.immediately)
                }
            } else if vm.searchResults != nil && vm.searchResults!.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(Color("ScheduleButtonColors"))
                    VStack {
                        Text("No Results for \"\(vm.searchText)\"")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("SecondaryText"))
                        Text("Check the spelling or\ntry a new search.")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if !vm.isSearching {
                Text("Search for your friends using their unique username!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if let searchResults = vm.searchResults {
                List {
                    Section(content: {
                        ForEach(searchResults, id: \.id) { user in
                            Button(action: {
                                vm.recentSearches.append(user)
                                RecentSearches.save(user)
                                coordinator.push(page: .profile(currentUser: vm.currentUser, profileUser: user, preferBackButton: true, namespace: namespace))
                            }, label: {
                                UserCell(user: user)
                                    .matchedTransitionSource(id: "zoom", in: namespace)
                            })
                        }
                    }, header: {
                        EmptyView()
                    })
                    .listSectionSeparator(.hidden, edges: .top)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .listRowBackground(Color("BackgroundColor"))
                .listSectionSpacing(0)
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .task {
            vm.recentSearches = RecentSearches.getRecentSearches()
        }
        .onChange(of: vm.searchText) {
            vm.debounceSearch()
        }
        .searchable(text: $vm.searchText, isPresented: $vm.isSearching, prompt: Text("Search"))
        .modifier(SearchViewModifier())
    }
}

struct SearchViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationTitle("Search")
                .toolbarTitleDisplayMode(.inlineLarge)
        } else {
            content
                .navigationTitle("Search")
                .toolbarTitleDisplayMode(.inlineLarge)
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Text("Search")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            .fixedSize(horizontal: true, vertical: false)
//                    }
//                }
        }
    }
}

