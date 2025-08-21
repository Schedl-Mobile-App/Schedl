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
            "Title"
        case .location:
            "Location"
        case .invited:
            "Invited Users"
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
    
    var filteredEvents: [Double : [RecurringEvents]] {
        if searchViewModel.searchText.isEmpty {
            let rawGroups = Dictionary(
                grouping: scheduleEvents,
                by: \.date,
            )
            return rawGroups.mapValues { recurringEvent in
                recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
            }
        } else {
            switch selectedFilter {
            case .title:
                let filteredResults = scheduleEvents.filter { event in
                    let startsWith = event.event.title.lowercased().hasPrefix(searchViewModel.searchText.lowercased())
                    let endsWith = event.event.title.lowercased().hasSuffix(searchViewModel.searchText.lowercased())
                    
                    return startsWith || endsWith
                }
                
                let rawGroups = Dictionary(
                    grouping: filteredResults,
                    by: \.date,
                )
                return rawGroups.mapValues { recurringEvent in
                    recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
                }
                
            case .location:
                let filteredResults = scheduleEvents.filter { event in
                    let startsWith = event.event.locationName.lowercased().hasPrefix(searchViewModel.searchText.lowercased()) || event.event.locationAddress.lowercased().hasPrefix(searchViewModel.searchText.lowercased())
                    let endsWith = event.event.locationName.lowercased().hasSuffix(searchViewModel.searchText.lowercased()) ||
                        event.event.locationAddress.lowercased().hasSuffix(searchViewModel.searchText.lowercased())
                    
                    return startsWith || endsWith
                }
                
                let rawGroups = Dictionary(
                    grouping: filteredResults,
                    by: \.date,
                )
                return rawGroups.mapValues { recurringEvent in
                    recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
                }
                
            case .invited:
                Task {
                    searchViewModel.debounceEventSearch()
                    
                    let filteredResults = scheduleEvents.filter { $0.event.taggedUsers.count > 0 }.filter { event in
                        event.event.taggedUsers.contains(searchViewModel.matchedUsers)
                    }
                                        
                    let rawGroups = Dictionary(
                        grouping: filteredResults,
                        by: \.date,
                    )
                    return rawGroups.mapValues { recurringEvent in
                        recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
                    }
                }
            }
        }
        
        let rawGroups = Dictionary(
            grouping: scheduleEvents,
            by: \.date,
        )
        return rawGroups.mapValues { recurringEvent in
            recurringEvent.sorted { $0.event.startTime < $1.event.startTime }
        }
    }
    
    var centerDateIndex: Int {
        let sortedKeys = Array(filteredEvents.keys).sorted(by: <)
        let currentDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        guard let index = sortedKeys.firstIndex(where: { $0 == currentDay }) else { return sortedKeys.count }
        return index
    }
    
    @State var selectedIndex = 0
    @Namespace private var namespace
    
    var body: some View {
        NavigationView {
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
                
                HStack(spacing: 0) {
                    ForEach(Array(EventSearchFilter.allCases.enumerated()), id: \.offset) { index, filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedFilter = filter
                                selectedIndex = index
                            }
                        }) {
                            Text(filter.filterTypeName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .lineLimit(1)
                                .foregroundColor(selectedIndex == index ? .primary : .secondary)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background {
                                    if selectedIndex == index {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.black.opacity(0.12))
                                            .matchedGeometryEffect(id: "highlight", in: namespace)
                                    }
                                }
                                .contentShape(Rectangle())
                                .padding(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(selectedIndex == index ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 5, pinnedViews: [.sectionHeaders]) {
                            let sortedKeys = Array(filteredEvents.keys).sorted(by: <)
                            ForEach(sortedKeys, id: \.self) { key in
                                let recurringEvents: [RecurringEvents] = filteredEvents[key]!
                                // Convert Double to Date for display
                                let date = Date(timeIntervalSince1970: key)

                                // Header
                                Section(header: SearchSectionHeaderView(date: date)) {
                                    VStack(spacing: 0) {
                                        ForEach(recurringEvents, id: \.id) { event in
                                            EventCard(event: event, navigateToEventDetails: $shouldNavigate, selectedEvent: $selectedEvent)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        let sortedKeys = Array(filteredEvents.keys).sorted(by: <)
                        let todayTimestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
                        if let todayKey = sortedKeys.first(where: { $0 >= todayTimestamp }) {
                            proxy.scrollTo(todayKey, anchor: .top)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Search for Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
            Spacer()
        }
        .padding(.vertical)
        .background(Color.primary
            .colorInvert()
            .opacity(0.75))
    }
}

