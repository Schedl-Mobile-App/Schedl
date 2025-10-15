//
//  ConditionalSearchBar.swift
//  Schedl
//
//  Created by David Medina on 10/1/25.
//

import SwiftUI
import Foundation

struct CustomSearchView: View {
    
    @Environment(\.router) var coordinator: Router
    
    @State private var searchText = ""
    @Binding var showSearchView: Bool
    var isFocused: FocusState<Bool>.Binding
    
    var scheduleId: String
    var events: [EventOccurrence]
    
    var filteredEvents: [EventOccurrence] = []
    
    func returnTimeFormatted(_ time: Int) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(TimeInterval(time))
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    func matches(_ query: String, in targets: [String]) -> Bool {
        guard !query.isEmpty else { return true }
        return targets.contains { target in
            target.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        ZStack {
            if searchText.isEmpty == false, events.isEmpty == false {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                List {
                    Section(content: {
                        ForEach(1..<50) { _ in
                            ForEach(events, id: \.id) { event in
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading) {
                                        Text(event.event.title)
                                            .font(.headline)
                                        Text("Austin, TX")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(returnTimeFormatted(event.event.startTime))
                                            .font(.callout)
                                        
                                        Text(returnTimeFormatted(event.event.endTime))
                                            .font(.callout)
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }, header: {
                        HStack {
                            Text("Header")
                                .font(.headline)
                        }
                    })
                    .listSectionSeparator(.visible, edges: .top)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                
                
            } else if searchText.isEmpty == false, events.isEmpty {
                Color(.systemBackground)
                    .ignoresSafeArea()
            
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(Color("ScheduleButtonColors"))
                    VStack {
                        Text("No Results for \"\(searchText)\"")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("SecondaryText"))
                        Text("Check the spelling or\ntry a new search.")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .allowsHitTesting(true)
        .safeAreaInset(edge: .top, alignment: .center) {
            if #available(iOS 26.0, *) {
                CapsuleEventSearchView(searchText: $searchText, showSearchView: $showSearchView, isFocused: isFocused)
                    .background(.ultraThickMaterial)
            } else {
                NativeSearchView(searchText: $searchText, showSearchView: $showSearchView, isFocused: isFocused)
                    .background(.ultraThickMaterial)
            }
        }
    }
}

#Preview {
    @Previewable @State var showSearch = false
    @Previewable @State var hideToolbar = false

    let mockUser = User(
        id: "user_preview_1",
        email: "jane@example.com",
        displayName: "David Medina",
        username: "djay0628",
        profileImage: "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FEklrnJ8NRuVjWl8vpoAiJUwyNsk1%2FprofileImages%2Fprofile_87907532-2551-479F-8153-24B8092D2504.jpg?alt=media&token=000e42ff-e566-4964-a424-016f81da818e",
        numOfEvents: 12,
        numOfFriends: 5,
        numOfPosts: 3
    )
    
    let mockUser2 = User(
        id: "user_preview_2",
        email: "jane@example.com",
        displayName: "Gerimeel Rivas",
        username: "geriwax",
        profileImage:
            "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FUNbmCWPIRFM8c9tmNz2gBNlNHGz1%2FprofileImages%2Fprofile_81EDEAE0-5EA9-4195-ABE1-76D168C25222.jpg?alt=media&token=df052ad0-5a78-4c57-9120-fc05284914ea",
        numOfEvents: 12,
        numOfFriends: 5,
        numOfPosts: 3
    )

    let startOfDay = Calendar.current.startOfDay(for: Date())
    let mockStartTime: Int = 9 * 60   // 9:00 AM
    let mockEndTime: Int = 11 * 60    // 11:00 AM
    
    let location = MTPlacemark(name: "Cafe Luna", address: "123 Main St, Austin, TX", latitude: 30.2672, longitude: -97.7431)
    
    let invitedUsers = [InvitedUser(userId: "user_preview_2", status: "pending"), InvitedUser(userId: "user_preview_1", status: "accepted")]

    let mockEvent = Event(
        id: "evt_preview_1",
        ownerId: mockUser.id,
        title: "CodePath Meeting iOS102",
        startDate: startOfDay,
        startTime: mockStartTime,
        endTime: mockEndTime,
        location: location,
        color: "3C859E",
        invitedUsers: invitedUsers
    )

    // Wrap in RecurringEvents for the details view
    let mockEventOccurence = EventOccurrence(recurringDate: startOfDay, event: mockEvent)
    
    ZStack {
        NavigationStack {
            Color.red
                .ignoresSafeArea(edges: [.bottom, .top])
                .onTapGesture {
                    withAnimation {
                        showSearch.toggle()
                    }
                }
        }
        .toolbar(hideToolbar ? .hidden : .visible, for: .tabBar)
        
        // Move the search view outside NavigationStack
            Color.black.opacity(showSearch ? 0.05 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(true)
            
            GeometryReader { geometry in
//                CustomSearchView(showSearchView: .constant(true), scheduleId: "1", events: [])
//                    .offset(y: showSearch ? 0 : -geometry.size.height)
//                    .opacity(showSearch ? 1 : 0)
            }
            .ignoresSafeArea()
    }
}

struct NativeSearchView: View {
    
    @Binding var searchText: String
    @Binding var showSearchView: Bool
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center) {
                Button(action: {
                    isFocused.wrappedValue = false
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .imageScale(.medium)
                }
                
                TextField("Search Events", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
                    .focused(isFocused)
                    .onSubmit {
                        isFocused.wrappedValue = false
                    }
                
                Spacer()
                
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18))
                }
                .symbolVariant(.circle.fill)
                .foregroundStyle(Color("BackgroundColor"), .gray)
                .opacity(searchText.isEmpty ? 0 : 1)
                .animation(.interpolatingSpring(duration: 0.3), value: searchText.isEmpty)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background{
                RoundedRectangle(cornerRadius: 12, style: .circular)
                    .fill(.gray.opacity(0.15))
            }
                
            Button(action: {
                withAnimation {
                    showSearchView = false
                    searchText = ""
                }
            }) {
                Text("Cancel")
                    .foregroundStyle(.primary)
            }
            .transition(.scale.combined(with: .opacity))
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
        .frame(height: 75, alignment: .bottom)
        .padding(.horizontal)
        .padding(.vertical)
    }
}

@available(iOS 26.0, *)
struct CapsuleEventSearchView: View {
    
    @Binding var searchText: String
    @Binding var showSearchView: Bool
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            HStack(alignment: .center) {
                Button(action: {
                    isFocused.wrappedValue = false
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .imageScale(.medium)
                }
                
                TextField("Search Events", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))
                    .focused(isFocused)
                    .onSubmit {
                        isFocused.wrappedValue = false
                    }
                
                Spacer()
                
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18))
                }
                .symbolVariant(.circle.fill)
                .foregroundStyle(Color("BackgroundColor"), .gray)
                .opacity(searchText.isEmpty ? 0 : 1)
                .animation(.interpolatingSpring(duration: 0.3), value: searchText.isEmpty)
            }
            .padding(13)
            .frame(maxWidth: .infinity)
            .background{
                Capsule()
                    .fill(Color("SearchBarBackground"))
                    .glassEffect(.regular, in: .capsule)
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSearchView = false
                    searchText = ""
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .padding(13)
                    .foregroundStyle(Color("SecondaryText"))
                    .background {
                        Circle()
                            .fill(Color("SearchBarBackground"))
                            .glassEffect(.clear, in: .circle)
                    }
            }
            .transition(.scale.combined(with: .opacity))
        }
        .frame(height: 85, alignment: .bottom)
        .padding(.horizontal)
        .padding(.vertical)
    }
}
