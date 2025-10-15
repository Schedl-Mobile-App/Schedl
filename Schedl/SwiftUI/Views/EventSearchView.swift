//
//  EventSearchView.swift
//  Schedl
//
//  Created by David Medina on 6/26/25.
//

import SwiftUI

enum EventSearchFilter: CaseIterable {
    case title, location, invited
    
    var filterTypeName: String {
        switch self {
        case .title:
            "title"
        case .location:
            "location"
        case .invited:
            "invited users"
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
        }
    }
}

struct EventSearchView: View {
    
    @Environment(\.router) var coordinator: Router
//    @StateObject var searchViewModel: SearchViewModel
//    var scheduleEvents: [RecurringEvents]
    @Environment(\.dismiss) var dismiss
    @State var selectedFilter: EventSearchFilter = .title
    
    @FocusState var isFocused: Bool
    
    init(currentUser: User) {
//        _searchViewModel = StateObject(wrappedValue: SearchViewModel(currentUser: currentUser))
//        self.scheduleEvents = scheduleEvents
    }
    
//    var filteredEvents: [Double : [RecurringEvents]] {
//        if searchViewModel.searchText.isEmpty {
//            let rawGroups = Dictionary(
//                grouping: scheduleEvents,
//                by: \.date,
//            )
//            return rawGroups.mapValues { recurringEvent in
//                recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
//            }
//        } else {
//            switch selectedFilter {
//            case .title:
//                let filteredResults = scheduleEvents.filter { event in
//                    let startsWith = event.event.title.lowercased().hasPrefix(searchViewModel.searchText.lowercased())
//                    let endsWith = event.event.title.lowercased().hasSuffix(searchViewModel.searchText.lowercased())
//                    
//                    return startsWith || endsWith
//                }
//                
//                let rawGroups = Dictionary(
//                    grouping: filteredResults,
//                    by: \.date,
//                )
//                return rawGroups.mapValues { recurringEvent in
//                    recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
//                }
//                
//            case .location:
//                let filteredResults = scheduleEvents.filter { event in
//                    let startsWith = event.event.location.name.lowercased().hasPrefix(searchViewModel.searchText.lowercased()) || event.event.location.address.lowercased().hasPrefix(searchViewModel.searchText.lowercased())
//                    let endsWith = event.event.location.name.lowercased().hasSuffix(searchViewModel.searchText.lowercased()) ||
//                        event.event.location.address.lowercased().hasSuffix(searchViewModel.searchText.lowercased())
//                    
//                    return startsWith || endsWith
//                }
//                
//                let rawGroups = Dictionary(
//                    grouping: filteredResults,
//                    by: \.date,
//                )
//                return rawGroups.mapValues { recurringEvent in
//                    recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
//                }
//                
//            case .invited:
//                let rawGroups = Dictionary(
//                    grouping: scheduleEvents,
//                    by: \.date,
//                )
//                return rawGroups.mapValues { recurringEvent in
//                    recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
//                }
////                Task {
////                    searchViewModel.debounceEventSearch()
////                    
////                    let filteredResults = scheduleEvents.filter { event in
////                        // Now, check if the taggedUsers array contains any element
////                        // where its userId is present in our fast lookup Set.
////                        event.event.invitedUsers.contains { invitedUser in
////                            searchViewModel.matchedUsers.contains(invitedUser.userId)
////                        }
////                    }
////                                        
////                    let rawGroups = Dictionary(
////                        grouping: filteredResults,
////                        by: \.date,
////                    )
////                    return rawGroups.mapValues { recurringEvent in
////                        recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
////                    }
////                }
//            }
//        }
//        
////        let rawGroups = Dictionary(
////            grouping: scheduleEvents,
////            by: \.date,
////        )
////        return rawGroups.mapValues { recurringEvent in
////            recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
////        }
//    }
    
//    var centerDateIndex: Int {
//        let sortedKeys = Array(filteredEvents.keys).sorted(by: <)
//        let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
//        guard let index = sortedKeys.firstIndex(where: { $0 == currentDay }) else { return sortedKeys.count }
//        return index
//    }
    
    @State var selectedIndex = 0
    
    var body: some View {
        NavigationStack {
//            VStack {
//                Picker("", selection: $selectedFilter) {
//                    ForEach(EventSearchFilter.allCases, id: \.self) { filter in
//                        Text(filter.filterTypeName.localizedCapitalized)
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 0) {
//                            let sortedKeys = Array(filteredEvents.keys).sorted(by: <)
//                            ForEach(sortedKeys, id: \.self) { key in
//                                let recurringEvents: [RecurringEvents] = filteredEvents[key]!
                                // Convert Double to Date for display
//                                let date = Date(timeIntervalSince1970: key)
                                
                                // Header
//                                Section(header: SearchSectionHeaderView(date: date)) {
//                                    VStack(spacing: 8) {
//                            ForEach(scheduleEvents) { event in
//                                EventCard(event: event)
//                                    .allowsHitTesting(false)
//                            }
//                                    }
//                                }
//                            }
                        }
                    }
//                    .onAppear {
//                        let sortedKeys = Array(filteredEvents.keys).sorted(by: <)
//                        let todayTimestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
//                        if let todayKey = sortedKeys.first(where: { $0 >= todayTimestamp }) {
//                            proxy.scrollTo(todayKey, anchor: .top)
//                        }
//                    }
                    .scrollIndicators(.hidden)
                }
                .scrollDismissesKeyboard(.immediately)
//            }
            .padding(.horizontal)
            .navigationTitle("Search for Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.60), .large])
//        .searchable(text: $searchViewModel.searchText, prompt: "Search events by \(selectedFilter.filterTypeName)")
    }
}

enum EventSearchOptions {
    case title, location, invited, all
}

struct SearchSectionHeaderView: View {
    
    func formattedDayString(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    var date: Date
    
    var body: some View {
        HStack {
            Text(formattedDayString(from: date))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical)
    }
}

