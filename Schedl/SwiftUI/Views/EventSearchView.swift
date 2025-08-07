//
//  EventSearchView.swift
//  Schedl
//
//  Created by David Medina on 6/26/25.
//

import SwiftUI

enum EventSearchFilter: CaseIterable {
    case title, location, invited, all
    
    var filterTypeName: String {
        switch self {
        case .title:
            "Title"
        case .location:
            "Location"
        case .invited:
            "Invited Users"
        case .all:
            "All"
        }
    }
    
    var searchFilterName: String {
        switch self {
        case .title:
            "Event Title"
        case .location:
            "Event Location"
        case .invited:
            "Invited Users"
        case .all:
            ""
        }
    }
}

struct EventSearchView: View {
    
    
    @EnvironmentObject var tabBarState: TabBarState
    @StateObject var searchViewModel: SearchViewModel
    @State var scheduleEvents: [RecurringEvents]
    @Environment(\.dismiss) var dismiss
    @State var selectedFilter: EventSearchFilter = .title
    @State var shouldNavigate: Bool = false
    @State var selectedEvent: RecurringEvents?
    @Binding var shouldReloadData: Bool
    
    @FocusState var isFocused: Bool
    
    init(currentUser: User, scheduleEvents: [RecurringEvents], shouldReloadData: Binding<Bool>) {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(currentUser: currentUser))
        _scheduleEvents = State(initialValue: scheduleEvents)
        _shouldReloadData = Binding(projectedValue: shouldReloadData)
    }
    
    var filteredEvents: [RecurringEvents] {
        if searchViewModel.searchText.isEmpty {
            return scheduleEvents
        } else {
            switch selectedFilter {
            case .title:
                let filteredResults = scheduleEvents.filter { event in
                    let startsWith = event.event.title.lowercased().hasPrefix(searchViewModel.searchText.lowercased())
                    let endsWith = event.event.title.lowercased().hasSuffix(searchViewModel.searchText.lowercased())
                    
                    return startsWith || endsWith
                }
                
                return filteredResults
            case .location:
                let filteredResults = scheduleEvents.filter { event in
                    let startsWith = event.event.locationName.lowercased().hasPrefix(searchViewModel.searchText.lowercased()) || event.event.locationAddress.lowercased().hasPrefix(searchViewModel.searchText.lowercased())
                    let endsWith = event.event.locationName.lowercased().hasSuffix(searchViewModel.searchText.lowercased()) ||
                        event.event.locationAddress.lowercased().hasSuffix(searchViewModel.searchText.lowercased())
                    
                    return startsWith || endsWith
                }
                
                return filteredResults
            case .invited:
                Task {
                    searchViewModel.debounceEventSearch()
                    
                    let filteredResults = scheduleEvents.filter { $0.event.taggedUsers.count > 0 }.filter { event in
                        event.event.taggedUsers.contains(searchViewModel.matchedUsers)
                    }
                    
                    return filteredResults
                }
            case .all:
                return scheduleEvents
            }
        }
        
        return scheduleEvents
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Button {}
                    label : {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .imageScale(.medium)
                    }
                    
                    TextField("Search by \(selectedFilter.searchFilterName)", text: $searchViewModel.searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .autocorrectionDisabled(true)
                        .focused($isFocused)
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
                .frame(maxWidth: .infinity, alignment: .top)
                
                HStack {
                    ForEach(EventSearchFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            Text(filter.filterTypeName)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Divider()
                            .foregroundStyle(Color(hex: 0xc0b8b2))
                            .frame(maxWidth: 1.75, maxHeight: 35)
                            .background(Color(hex: 0xc0b8b2))
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.12))
                        .stroke(Color.black, lineWidth: 1)
                }
                
                ScrollView {
                    ForEach(filteredEvents, id: \.id) { event in
                        EventCard(event: event, navigateToEventDetails: $shouldNavigate, selectedEvent: $selectedEvent)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            .navigationTitle("Search for Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                if let selectedEvent = selectedEvent {
                    EventDetailsView(event: selectedEvent, currentUser: searchViewModel.currentUser, shouldReloadData: $shouldReloadData).environmentObject(tabBarState)
                }
            }
        }
    }
}

enum EventSearchOptions {
    case title, location, invited, all
}

