//
//  PopUpView 2.swift
//  calendarTest
//
//  Created by David Medina on 12/4/24.
//

import SwiftUI

private let mockUser = User(
    id: "mock-id",
    username: "mockuser",
    email: "mock@email.com",
    displayName: "Mock User",
    profileImage: "https://example.com/mock-profile.png",
    creationDate: Date().timeIntervalSince1970
)

struct CreateEventView: View {
    
    @EnvironmentObject var tabBarState: TabBarState
    
    @StateObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var shouldReloadData: Bool
    
    @FocusState var isFocused: EventInfoFields?
    
    init(currentUser: User, shouldReloadData: Binding<Bool>) {
        _eventViewModel = StateObject(wrappedValue: EventViewModel(currentUser: currentUser))
        _shouldReloadData = Binding(projectedValue: shouldReloadData)
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
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
                    
                    
                    Text("Create Event")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding([.horizontal, .top])
                .frame(maxWidth: .infinity)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Fill out the details below to create your event!")
                            .font(.body)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: 0x333333))
                            .padding(.vertical, 8)
                        
                        // view for event title input
                        EventTitleView(title: $eventViewModel.title, isFocused: $isFocused, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, titleError: $eventViewModel.titleError)
                        
                        // view for event date and recurring days seletion
                        EventDateView(eventDate: $eventViewModel.eventDate, eventEndDate: $eventViewModel.eventEndDate, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, startDateError: $eventViewModel.startDateError, endDateError: $eventViewModel.endDateError, repeatedDays: $eventViewModel.repeatedDays)
                        
                        // view for start time selection
                        EventStartTimeView(startTime: $eventViewModel.startTime, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, startTimeError: $eventViewModel.startTimeError)
                        
                        // view for end time selection
                        EventEndTimeView(endTime: $eventViewModel.endTime, endTimeError: $eventViewModel.endTimeError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting)
                        
                        // view for location selection
                        EventLocationView(selectedPlacemark: $eventViewModel.selectedPlacemark, locationError: $eventViewModel.locationError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $eventViewModel.selectedFriends, showInviteUsersSheet: $eventViewModel.showInviteUsersSheet)
                            .sheet(isPresented: $eventViewModel.showInviteUsersSheet) {
                                AddInvitedUsers(eventViewModel: eventViewModel)
                            }
                        
                        // view for event notes input
                        EventNotesView(notes: $eventViewModel.notes, notesError: $eventViewModel.notesError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, isFocused: $isFocused)
                        
                        // view for event color selection
                        EventColorView(eventColor: $eventViewModel.eventColor)
                        
                        Button(action: {
                            Task {
                                await eventViewModel.createEvent()
                                if eventViewModel.shouldDismiss {
                                    shouldReloadData = true
                                    dismiss()
                                }
                            }
                        }, label: {
                            Text("Create Event")
                                .foregroundColor(Color(hex: 0xf7f4f2))
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(0.1)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: 0x3C859E))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical, 8)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical)
                    .padding(.horizontal, 25)
                    .simultaneousGesture(TapGesture().onEnded {
                        isFocused = nil
                        if eventViewModel.hasTriedSubmitting {
                            eventViewModel.hasTriedSubmitting = false
                        }
                    })
                }
                .defaultScrollAnchor(.top, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isFocused = nil
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            shouldReloadData = false
            tabBarState.hideTabbar = true
        }
        .onDisappear {
            shouldReloadData = true
        }
        .toolbar(tabBarState.hideTabbar ? .hidden : .visible, for: .tabBar)
    }
}

struct AddInvitedUsers: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var eventViewModel: EventViewModel
    @State var searchText: String = ""
    @FocusState var isSearching: Bool?
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return eventViewModel.userFriends
        } else {
            let filteredResults = eventViewModel.userFriends.filter { user in
                let startsWith = user.displayName.lowercased().hasPrefix(searchText.lowercased())
                let endsWith = user.displayName.lowercased().hasSuffix(searchText.lowercased())
                
                return startsWith || endsWith
            }
            
            return filteredResults
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if eventViewModel.isLoading {
                    VStack(spacing: 0) {
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
                                .disabled(true)
                            
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
                                                
                        FriendsLoadingView()
                    }
                } else if let error = eventViewModel.errorMessage {
                    VStack(spacing: 0) {
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
                                .disabled(true)
                            
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
                        
                        Spacer()
                        
                        Text(error)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(-0.25)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else if eventViewModel.userFriends.isEmpty {
                    VStack(spacing: 0) {
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
                                .disabled(true)
                            
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
                                      
                        Spacer()
                        
                        Text("No friends found. Add your first friend by clicking the Search icon below!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(-0.25)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
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
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 20) {
                                ForEach(filteredUsers, id: \.self.id) { friend in
                                    InvitedUserCell(friend: friend, selectedFriends: $eventViewModel.selectedFriends, availableFriends: eventViewModel.availabilityList)
                                }
                            }
                            .padding(.vertical)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                    .onTapGesture {
                        isSearching = nil
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            await eventViewModel.fetchFriends()
        }
    }
}

struct EventTitleView: View {
    
    @Binding var title: String?
    var titleBinding: Binding<String> {
        Binding(
            get: { title ?? "" },
            set: { newValue in
                title = newValue.isEmpty ? nil : newValue
            }
        )
    }
    var isFocused: FocusState<EventInfoFields?>.Binding
    @Binding var hasTriedSubmitting: Bool
    @Binding var titleError: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top, spacing: 0) {
            
                TextField("Event Title", text: titleBinding, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused, equals: .title)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    title = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(title == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && title == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Event Title")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -10)
                .opacity(isFocused.wrappedValue == .title || title != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(titleError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !titleError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !titleError.isEmpty ? 8 : 0)
    }
}

struct EventDateView: View {
    
    @Binding var eventDate: Date?
    @Binding var eventEndDate: Date?
    @Binding var hasTriedSubmitting: Bool
    @State var showDatePicker: Bool = false
    @State var showEndDatePicker: Bool = false
    @Binding var startDateError: String
    @Binding var endDateError: String
    @Binding var repeatedDays: Set<Int>?
    
    var dayList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var eventDateBinding: Binding<Date> {
        Binding(
            get: { eventDate ?? Calendar.current.startOfDay(for: Date()) },
            set: { selectedDate in
                eventDate = selectedDate
            }
        )
    }
    var eventEndDateBinding: Binding<Date> {
        Binding(
            get: { eventEndDate ?? Calendar.current.startOfDay(for: Date()) },
            set: { selectedDate in
                eventEndDate = selectedDate
            }
        )
    }
    
    var eventDateText: String {
        if let date = eventDate {
            return date.formatted(date: .long, time: .omitted)
        }
        return "Event Date"
    }
    var eventEndDateText: String {
        if let date = eventEndDate {
            return date.formatted(date: .long, time: .omitted)
        }
        return "Select Date"
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                Text(eventDateText)
                    .fontWeight(eventDate == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(eventDate == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                    .tracking(0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Button("Edit", action: {
                        showDatePicker.toggle()
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .hidden(eventDate == nil)
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .imageScale(.large)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    .hidden(eventDate != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && eventDate == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            .onTapGesture {
                showDatePicker.toggle()
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationView {
                    DatePicker("Select Event Date",
                               selection: eventDateBinding,
                               displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding(0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Clear") {
                                eventDate = nil
                                showDatePicker = false
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
                .onAppear {
                    if eventDate == nil {
                        eventDate = Calendar.current.startOfDay(for: Date())
                    }
                }
            }
            
            GeometryReader { geometry in
                HStack {
                    Spacer()
                        .frame(width: 4)
                    Text("Event Date")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .opacity(eventDate != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: eventDate)
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -geometry.size.height * CGFloat(0.15))
                .hidden(eventDate == nil)
                
                Text(startDateError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !startDateError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !startDateError.isEmpty ? 8 : 0)
        
        if eventDate != nil {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 15) {
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(0..<dayList.count, id: \.self) { index in
                            Spacer()
                            VStack(alignment: .center, spacing: 12) {
                                Text(dayList[index])
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .font(.footnote)
                                    .tracking(0.1)
                                    .foregroundStyle(Color(hex: 0x333333))
                                
                                Button(action: {
                                    var currentDays = repeatedDays ?? Set<Int>()
                                        
                                        // 2. Perform the toggle logic on the local variable
                                        if currentDays.contains(index) {
                                            currentDays.remove(index)
                                        } else {
                                            currentDays.insert(index)
                                        }
                                        
                                        // 3. Assign the modified set back to the @State variable to trigger a UI update
                                        repeatedDays = currentDays
                                }) {
                                    RoundedRectangle(cornerRadius: 5)
                                            // 4. Safely check for containment without force unwrapping
                                            .fill(repeatedDays?.contains(index) == true ? Color(hex: 0x3C859E) : Color.gray.opacity(0.2))
                                            .frame(width: 25, height: 25)
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("Repeating Until")
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .font(.caption)
                            .tracking(0.1)
                            .foregroundStyle(Color(hex: 0x333333))
                        Spacer()
                        ZStack(alignment: .trailing) {
                            Button(action: {
                                showEndDatePicker.toggle()
                            }) {
                                Text(eventEndDateText)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .tracking(-0.25)
                                Image(systemName: "calendar")
                                    .imageScale(.medium)
                                    .foregroundStyle(Color(hex: 0x333333))
                            }
                            .hidden(eventEndDate == nil)
                            
                            Button(action: {
                                showEndDatePicker.toggle()
                            }) {
                                Text("Select Date")
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .font(.caption)
                                    .tracking(0.1)
                                    .foregroundStyle(Color.gray)
                                Image(systemName: "calendar")
                                    .imageScale(.medium)
                                    .foregroundStyle(Color(hex: 0x333333))
                            }
                            .hidden(eventEndDate != nil)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.clear)
                        .stroke(hasTriedSubmitting && !endDateError.isEmpty ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
                }
                .sheet(isPresented: $showEndDatePicker) {
                    NavigationView {
                        DatePicker("Select End Date",
                                   selection: eventEndDateBinding,
                                   displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .navigationTitle("Select End Date")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Clear") {
                                    eventEndDate = nil
                                    showEndDatePicker = false
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showEndDatePicker = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium])
                    .onAppear {
                        if eventEndDate == nil {
                            eventEndDate = Calendar.current.startOfDay(for: Date())
                        }
                    }
                }
                
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                            .frame(width: 4)
                        Text("Recurring Days")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                        Spacer()
                            .frame(width: 4)
                    }
                    .opacity(eventDate != nil ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: eventDate)
                    .background {
                        Color(hex: 0xf7f4f2)
                    }
                    .padding(.leading)
                    .offset(y: -10)
                    .hidden(eventDate == nil)
                    
                    Text(endDateError)
                        .font(.footnote)
                        .padding(.leading)
                        .offset(y: geometry.size.height * CGFloat(1.025))
                        .foregroundStyle(.red)
                        .opacity(hasTriedSubmitting && !endDateError.isEmpty ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.vertical, 8)
            .padding(.bottom, hasTriedSubmitting && !endDateError.isEmpty ? 8 : 0)
        }
    }
}

struct EventStartTimeView: View {
    
    @Binding var startTime: Date?
    @Binding var hasTriedSubmitting: Bool
    @Binding var startTimeError: String
    @State var showStartTimePicker: Bool = false
    
    var startTimeBinding: Binding<Date> {
        Binding(
            get: { startTime ?? Date.now },
            set: { selectedTime in
                startTime = selectedTime
            }
        )
    }
    var startTimeText: String {
        if let date = startTime {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return "Start Time"
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                Text(startTimeText)
                    .fontWeight(startTime == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(startTime == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                    .tracking(-0.25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Button("Edit", action: {
                        showStartTimePicker.toggle()
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .hidden(startTime == nil)
                    
                    Button(action: {
                        showStartTimePicker.toggle()
                    }) {
                        Image(systemName: "clock.badge")
                            .imageScale(.large)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    .hidden(startTime != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && startTime == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            .onTapGesture {
                showStartTimePicker.toggle()
            }
            .sheet(isPresented: $showStartTimePicker) {
                NavigationView {
                    DatePicker("",
                              selection: startTimeBinding,
                              displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .navigationTitle("Select Start Time")
                        .navigationBarTitleDisplayMode(.inline)
                        .labelsHidden()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Clear") {
                                    startTime = nil
                                    showStartTimePicker = false
                                }
                            }

                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showStartTimePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
                .onAppear {
                    if startTime == nil {
                        startTime = Date.now
                    }
                }
            }
            
            GeometryReader { geometry in
                HStack {
                    Spacer()
                        .frame(width: 4)
                    Text("Start Time")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .opacity(startTime != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: startTime)
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -geometry.size.height * CGFloat(0.15))
                .hidden(startTime == nil)
                
                Text(startTimeError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !startTimeError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !startTimeError.isEmpty ? 8 : 0)
    }
}

struct EventEndTimeView: View {
    
    @Binding var endTime: Date?
    @Binding var endTimeError: String
    @State var showEndTimePicker: Bool = false
    @Binding var hasTriedSubmitting: Bool
    
    var endTimeBinding: Binding<Date> {
        Binding(
            get: { endTime ?? Date.now },
            set: { selectedTime in
                endTime = selectedTime
            }
        )
    }
    var endTimeText: String {
        if let date = endTime {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return "End Time"
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                Text(endTimeText)
                    .fontWeight(endTime == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(endTime == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                    .tracking(-0.25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Button("Edit", action: {
                        showEndTimePicker.toggle()
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .hidden(endTime == nil)
                    
                    Button(action: {
                        showEndTimePicker.toggle()
                    }) {
                        Image(systemName: "clock.badge")
                            .imageScale(.large)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    .hidden(endTime != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && endTime == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            .onTapGesture {
                showEndTimePicker.toggle()
            }
            .sheet(isPresented: $showEndTimePicker) {
                NavigationView {
                    DatePicker("",
                              selection: endTimeBinding,
                              displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .navigationTitle("Select Start Time")
                        .navigationBarTitleDisplayMode(.inline)
                        .labelsHidden()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Clear") {
                                    endTime = nil
                                    showEndTimePicker = false
                                }
                            }

                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showEndTimePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
                .onAppear {
                    if endTime == nil {
                        endTime = Date.now
                    }
                }
            }
            
            GeometryReader { geometry in
                HStack {
                    Spacer()
                        .frame(width: 4)
                    Text("End Time")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .opacity(endTime != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: endTime)
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -geometry.size.height * CGFloat(0.15))
                .hidden(endTime == nil)
                
                Text(endTimeError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !endTimeError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !endTimeError.isEmpty ? 8 : 0)
    }
}

struct EventLocationView: View {
    
    @Binding var selectedPlacemark: MTPlacemark?
    @Binding var locationError: String
    @State var showMapSheet: Bool = false
    @Binding var hasTriedSubmitting: Bool
    
    var selectedLocationText: String {
        if let location = selectedPlacemark {
            return location.name
        }
        return "Add Location"
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            HStack(spacing: 0) {
                Text(selectedLocationText)
                    .fontWeight(selectedPlacemark == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(selectedPlacemark == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                    .tracking(-0.25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Button("Edit", action: {
                        showMapSheet.toggle()
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .hidden(selectedPlacemark == nil)
                    
                    Button(action: {
                        showMapSheet.toggle()
                    }) {
                        Image(systemName: "mappin")
                            .imageScale(.large)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                    .hidden(selectedPlacemark != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && selectedPlacemark == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            .onTapGesture {
                showMapSheet.toggle()
            }
            .fullScreenCover(isPresented: $showMapSheet) {
                NavigationView {
                    LocationView(selectedPlacemark: $selectedPlacemark, showMapSheet: $showMapSheet)
                }
            }
            
            GeometryReader { geometry in
                HStack {
                    Spacer()
                        .frame(width: 4)
                    Text("Location")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .opacity(selectedPlacemark != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: selectedPlacemark)
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -geometry.size.height * CGFloat(0.15))
                .hidden(selectedPlacemark == nil)
                
                Text(locationError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !locationError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !locationError.isEmpty ? 4 : 0)
    }
}

struct EventInviteesView: View {
    
    @Binding var selectedFriends: [User]
    @Binding var showInviteUsersSheet: Bool
    @State var showMoreInvitees = false
    
    var initialVisibleCount = 2
    
    var body: some View {
        Group {
            if selectedFriends.isEmpty {
                Button(action: {
                    showInviteUsersSheet.toggle()
                }) {
                    HStack(spacing: 0) {
                        Text("Invite Friends to Your Event?")
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: 0x333333))
                            .tracking(-0.25)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .imageScale(.medium)
                            .foregroundStyle(Color.white)
                            .padding(7.5)
                            .background {
                                Circle()
                                    .fill(Color(hex: 0x3C859E))
                            }
                    }
                }
                .padding(.trailing)
                .padding(.vertical, 8)
            } else {
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Spacer()
                            Button("Edit", action: {
                                showInviteUsersSheet.toggle()
                            })
                            .font(.footnote)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: 0x3C859E))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(selectedFriends.enumerated()), id: \.element.id) { index, user in
                                // only show if expanded OR within the first 2 items
                                if showMoreInvitees || index < initialVisibleCount {
                                    HStack {
                                        InvitedUserRow(user: user)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                        Spacer()
                                        Button {
                                            selectedFriends.removeAll { $0.id == user.id }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .imageScale(.medium)
                                                .foregroundStyle(Color(hex: 0x333333))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // only show the toggle button when there are more than 2
                        if selectedFriends.count > initialVisibleCount {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showMoreInvitees.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(showMoreInvitees
                                         ? "Show Less"
                                         : "Show \(selectedFriends.count - initialVisibleCount) More")
                                    Image(systemName: showMoreInvitees
                                          ? "chevron.up.circle.fill"
                                          : "chevron.down.circle.fill")
                                    .imageScale(.medium)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color(hex: 0x3C859E))
                                .padding(.top, 8)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .animation(nil, value: showMoreInvitees)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                    
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                                .frame(width: 4)
                            Text("Invited Friends")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                            Spacer()
                                .frame(width: 4)
                        }
                        .opacity(!selectedFriends.isEmpty ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedFriends.isEmpty)
                        .background {
                            Color(hex: 0xf7f4f2)
                        }
                        .padding(.leading)
                        .offset(y: -10)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: selectedFriends.isEmpty)
        .padding(.vertical, 8)
    }
}

struct InvitedUserCell: View {
    
    let friend: User
    @Binding var selectedFriends: [User]
    var availableFriends: [FriendAvailability]? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                .background(Color.clear)
                .frame(width: 40.75, height: 40.75)
                .overlay {
                    AsyncImage(url: URL(string: friend.profileImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 39, height: 39)
                            .clipShape(Circle())
                    } placeholder: {
                        // Show while loading or if image fails to load
                        Circle()
                            .fill(Color(hex: 0xe0dad5))
                            .frame(width: 39, height: 39)
                            .overlay {
                                Text("\(friend.displayName.first?.uppercased() ?? "J")\(friend.displayName.last?.uppercased() ?? "D")")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .multilineTextAlignment(.center)
                            }
                    }
                }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("\(friend.displayName)")
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
                    Text("\(friend.username)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .tracking(1.05)
                        .foregroundStyle(Color.black.opacity(0.50))
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            if let availableFriends = availableFriends, availableFriends.first(where: { $0.userId == friend.id })?.available == false {
                Text("Not available")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fontDesign(.rounded)
                    .tracking(1.05)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            } else {
                Button {
                    if selectedFriends.contains(where: { $0.id == friend.id }) {
                        selectedFriends.removeAll { $0.id == friend.id }
                    } else {
                        selectedFriends.append(friend)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                selectedFriends.contains(friend)
                                ? Color(hex: 0x3C859E)
                                : Color.clear
                            )
                        Circle()
                            .strokeBorder(Color(hex: 0x333333), lineWidth: 1.5)
                    }
                    .frame(width: 25, height: 25)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct EventNotesView: View {
    
    @Binding var notes: String?
    @Binding var notesError: String
    
    var notesBinding: Binding<String> {
        Binding(
            get: { notes ?? "" },
            set: { newValue in
                notes = newValue.isEmpty ? nil : newValue
            }
        )
    }
    var notesText: String {
        if let eventNotes = notes {
            return eventNotes
        }
        return "Add Notes"
    }
    
    @Binding var hasTriedSubmitting: Bool
    var isFocused: FocusState<EventInfoFields?>.Binding
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            HStack(alignment: .top, spacing: 0) {
            
                TextField("Add Notes", text: notesBinding, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused, equals: .description)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    notes = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(notes == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && !notesError.isEmpty ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Event Notes")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -10)
                .opacity(isFocused.wrappedValue == .description || notes != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(notesError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !notesError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !notesError.isEmpty ? 4 : 0)
    }
}

struct EventColorView: View {
    
    @Binding var eventColor: Color?
    @State var showColorPicker: Bool = false
    
    var eventColorBinding: Binding<Color> {
        Binding(
            get: { eventColor ?? .blue},
            set: { newColor in
                eventColor = newColor
            }
        )
    }
    
    var body: some View {
        Button(action: {
            showColorPicker.toggle()
        }) {
            HStack(alignment: .center, spacing: 0) {
                Text(eventColor == nil ? "Choose a Color For Your Event?" : "Selected Event Color:")
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(-0.25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if eventColor == nil {
                    
                    Image(systemName: "paintbrush")
                        .foregroundColor(Color(hex: 0x333333))
                        .imageScale(.large)
                } else {
                    
                    HStack(alignment: .center, spacing: 3) {
                        Image(systemName: "paintbrush")
                            .foregroundColor(Color(hex: 0x333333))
                            .imageScale(.large)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(eventColor ?? Color.clear)
                            .frame(maxWidth: 55, maxHeight: 25)
                    }
                }
            }
        }
        .padding(.trailing)
        .padding(.vertical, 8)
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: eventColorBinding)
        }
    }
}


#Preview {
    @Previewable @State var reload = false
    return CreateEventView(currentUser: mockUser, shouldReloadData: .constant(false))
}
