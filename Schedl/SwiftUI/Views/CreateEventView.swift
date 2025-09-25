//
//  PopUpView 2.swift
//  calendarTest
//
//  Created by David Medina on 12/4/24.
//

import SwiftUI
import Kingfisher

struct CreateEventView: View {
    
    @StateObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) var dismiss
    
    @FocusState var isFocused: EventInfoFields?
    
    init(currentUser: User, currentScheduleId: String) {
        _eventViewModel = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, currentScheduleId: currentScheduleId))
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Fill out the details below to create your event!")
                        .font(.body)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("PrimaryText"))
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 0) {
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
                                AddInvitedUsers(currentUser: eventViewModel.currentUser, selectedFriends: $eventViewModel.selectedFriends)
                            }
                        
                        // view for event notes input
                        EventNotesView(notes: $eventViewModel.notes, notesError: $eventViewModel.notesError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, isFocused: $isFocused)
                        
                        // view for event color selection
                        EventColorView(eventColor: $eventViewModel.eventColor)
                    }
                    
                    Button(action: {
                        Task {
                            await eventViewModel.createEvent()
                            if eventViewModel.shouldDismiss {
                                dismiss()
                            }
                        }
                    }, label: {
                        Text("Create Event")
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColors"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 25)
                .simultaneousGesture(TapGesture().onEnded {
                    withAnimation {
                        isFocused = nil
                        eventViewModel.resetErrors()
                        if eventViewModel.hasTriedSubmitting {
                            eventViewModel.hasTriedSubmitting = false
                        }
                    }
                })
            }
            .defaultScrollAnchor(.top, for: .initialOffset)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Event")
                    .foregroundStyle(Color.white)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
        }
    }
}

struct AddInvitedUsers: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var vm: FriendViewModel
    @Binding var selectedFriends: [User]
        
    init(currentUser: User, selectedFriends: Binding<[User]>) {
        _vm = StateObject(wrappedValue: FriendViewModel(currentUser: currentUser))
        _selectedFriends = Binding(projectedValue: selectedFriends)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    FriendsLoadingView()
                } else if let error = vm.errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color("SecondaryText"))
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if vm.friends.isEmpty {
                    Text("No friends found. Add your first friend by clicking the Search icon below!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color("SecondaryText"))
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    List {
                        Section(content: {
                            ForEach(vm.friends, id: \.id) { friend in
                                Button(action: {
                                    withAnimation {
                                        if isContained(friend.id) {
                                            selectedFriends.removeAll { $0.id == friend.id }
                                        } else {
                                            selectedFriends.append(friend)
                                        }
                                    }
                                }, label: {
                                    InvitedUserCell(friend: friend, isAvailable: true)
                                        .listRowBackground(Color.clear)
//                                        .listRowBackground {
//                                            isContained(id: friend.id) ?
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(Color("BackgroundColor"), style: .continuous) :
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(Color.clear)
//                                        }
                                })
                            }
                        }, header: {
                            EmptyView()
                        })
                        .listSectionSeparator(.hidden, edges: .top)
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        withAnimation {
                            selectedFriends.removeAll()
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .toolbarBackground(Color.blue)
        .presentationDetents([.medium, .large])
        .task {
            await vm.fetchFriends()
        }
        .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for available friends")
    }
    
    func isContained(_ id: String) -> Bool {
        return selectedFriends.contains(where: { $0.id == id })
    }
    
    func isAvailable(_ id: String) -> Bool {
        return vm.availabilityList.contains(where: { $0.userId == id })
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
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
            
                TextField("", text: titleBinding, prompt:
                            Text("Event Title")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color("SecondaryText"))
                                .tracking(-0.25),
                          axis: .vertical)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color("PrimaryText"))
                .tracking(-0.25)
                .focused(isFocused, equals: .title)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .onChange(of: title) { _, newValue in
                    guard let newValue = newValue else { return }
                    guard isFocused.wrappedValue == .title else { return }
                    guard newValue.contains("\n") else { return }
                    isFocused.wrappedValue = nil
                    title = newValue.replacing("\n", with: "")
                }
                
                Spacer()
                Button(action: {
                    withAnimation {
                        title = nil
                    }
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("IconColors"))
                }
                .opacity(title == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: title)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && title == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 0) {
                    Text("Event Title")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor"))
                        .offset(y: -9)
                        .padding(.leading, 16)
                }
                .opacity(title != nil || isFocused.wrappedValue == .title ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue == .title || title != nil)
            }

            Text(titleError.isEmpty ? " " : titleError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(titleError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: titleError.isEmpty)
        }
        .padding(.top, 10)
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
    
    var abbreviatedDayList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var completeDayList: [String] = ["Sunday", "Tuesday", "Wednesday", "Thursday", "Saturday", "Monday", "Friday"]
    
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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(eventDateText)
                    .fontWeight(eventDate == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(eventDate == nil ? Color("SecondaryText") : Color("PrimaryText"))
                    .tracking(-0.25)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Button("Edit", action: {
                        showDatePicker.toggle()
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("ButtonColors"))
                    .hidden(eventDate == nil)
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .imageScale(.large)
                            .foregroundStyle(Color("IconColors"))
                    }
                    .hidden(eventDate != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && eventDate == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
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
                    .padding()
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Clear") {
                                eventDate = nil
                                showDatePicker = false
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
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
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Event Date")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -9) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(eventDate != nil ? 1 : 0) // Show label only when floating
                .animation(.easeInOut(duration: 0.2), value: eventDate)
            }
            
            Text(startDateError.isEmpty ? " " : startDateError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(startDateError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: startDateError.isEmpty)
        }
        .padding(.top, 10)
        
        if eventDate != nil {
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    // Wrap the day picker in ViewThatFits
                    ViewThatFits {
                        // Option 1: The original horizontal layout
                        HStack(spacing: 0) {
                            // Your ForEach loop for the days goes here...
                            ForEach(0..<abbreviatedDayList.count, id: \.self) { index in
                                if (index != 0) {
                                    Spacer()
                                }
                                VStack(alignment: .center, spacing: 12) {
                                    Text(abbreviatedDayList[index])
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .font(.footnote)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color("PrimaryText"))
                                    
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
                                            .fill(repeatedDays?.contains(index) == true ? Color("ButtonColors") : Color.gray.opacity(0.2))
                                            .frame(width: 25, height: 25)
                                    }
                                }
                                if (index != abbreviatedDayList.count - 1) {
                                    Spacer()
                                }
                            }
                        }
                        
                        // Option 2: The fallback vertical layout for large text sizes
                        VStack(alignment: .leading, spacing: 15) {
                            // The same ForEach loop, but now inside a VStack
                            ForEach(0..<completeDayList.count, id: \.self) { index in
                                HStack { // Use an HStack here to place the label and button side-by-side
                                    Text(completeDayList[index])
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .font(.footnote)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color("PrimaryText"))
                                    
                                    Spacer()
                                    
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
                                            .fill(repeatedDays?.contains(index) == true ? Color("ButtonColors") : Color.gray.opacity(0.2))
                                            .frame(width: 25, height: 25)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    ViewThatFits {
                        // Option 1: Horizontal layout (without the Spacer)
                        HStack {
                            Text("Repeating Until:")
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .font(.caption)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // This Spacer is removed to allow the HStack to report its true size.
                            
                            // Use a ZStack to conditionally show one of the two buttons.
                            ZStack {
                                Button(action: {
                                    showEndDatePicker.toggle()
                                }) {
                                    // This HStack is for the text and icon
                                    HStack {
                                        Image(systemName: "calendar")
                                            .imageScale(.medium)
                                            .foregroundStyle(Color("IconColors"))
                                        Text(eventEndDateText)
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .fontDesign(.monospaced)
                                            .foregroundStyle(Color("PrimaryText"))
                                            .lineLimit(1)
                                            .tracking(-0.25)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.leading)
                                }
                                .opacity(eventEndDate == nil ? 0 : 1) // Fade in/out for a smoother look
                                
                                Button(action: {
                                    showEndDatePicker.toggle()
                                }) {
                                    // This HStack is for the text and icon
                                    HStack {
                                        Image(systemName: "calendar")
                                            .imageScale(.medium)
                                            .foregroundStyle(Color("IconColors"))
                                        Text("Select Date")
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .font(.caption)
                                            .foregroundStyle(Color("SecondaryText"))
                                            .lineLimit(1)
                                            .tracking(-0.25)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.leading)
                                }
                                .opacity(eventEndDate != nil ? 0 : 1)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        // Option 2: Vertical fallback layout (this will now be used correctly)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeating Until")
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .font(.caption)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                            
                            // Using a ZStack here as well for consistency
                            ZStack(alignment: .leading) {
                                Button(action: {
                                    showEndDatePicker.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .imageScale(.medium)
                                            .foregroundStyle(Color("IconColors"))
                                        Text(eventEndDateText)
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .fontDesign(.monospaced)
                                            .foregroundStyle(Color("PrimaryText"))
                                            .tracking(-0.25)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.leading)
                                }
                                .opacity(eventEndDate == nil ? 0 : 1)
                                
                                Button(action: {
                                    showEndDatePicker.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .imageScale(.medium)
                                            .foregroundStyle(Color("IconColors"))
                                        Text("Select Date")
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .font(.caption)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color("SecondaryText"))
                                    }
                                    .opacity(eventEndDate != nil ? 0 : 1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.clear)
                        .stroke(hasTriedSubmitting && !endDateError.isEmpty ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
                }
                .sheet(isPresented: $showEndDatePicker) {
                    NavigationView {
                        DatePicker("Select End Date",
                                   selection: eventEndDateBinding,
                                   displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding()
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
                .overlay(alignment: .topLeading) {
                    // This HStack creates the label with padding for the background.
                    HStack(spacing: 0) {
                        Text("Recurring Days")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .padding(.horizontal, 4)
                            .background(Color("BackgroundColor")) // This background cuts the border
                            .offset(y: -9) // Move label up or keep it centered
                            .padding(.leading, 16)
                    }
                    .opacity(eventDate != nil ? 1 : 0) // Show label only when floating
                    .animation(.easeInOut(duration: 0.2), value: eventDate)
                }
                
                Text(endDateError.isEmpty ? " " : endDateError)
                    .font(.footnote)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(Color("ErrorTextColor"))
                    .opacity(endDateError.isEmpty ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: endDateError.isEmpty)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.top, 10)
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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(startTimeText)
                    .fontWeight(startTime == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(startTime == nil ? Color("SecondaryText") : Color("PrimaryText"))
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
                    .foregroundStyle(Color("ButtonColors"))
                    .hidden(startTime == nil)
                    
                    Button(action: {
                        showStartTimePicker.toggle()
                    }) {
                        Image(systemName: "clock.badge")
                            .imageScale(.large)
                            .foregroundStyle(Color("IconColors"))
                    }
                    .hidden(startTime != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && startTime == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
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
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Start Time")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -9) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(startTime != nil ? 1 : 0) // Show label only when floating
                .animation(.easeInOut(duration: 0.2), value: startTime)
            }

            Text(startTimeError.isEmpty ? " " : startTimeError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(startTimeError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: startTimeError.isEmpty)
        }
        .padding(.top, 10)
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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(endTimeText)
                    .fontWeight(endTime == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(endTime == nil ? Color("SecondaryText") : Color("PrimaryText"))
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
                    .foregroundStyle(Color("ButtonColors"))
                    .hidden(endTime == nil)
                    
                    Button(action: {
                        showEndTimePicker.toggle()
                    }) {
                        Image(systemName: "clock.badge")
                            .imageScale(.large)
                            .foregroundStyle(Color("IconColors"))
                    }
                    .hidden(endTime != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && endTime == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
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
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("End Time")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -9) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(endTime != nil ? 1 : 0) // Show label only when floating
                .animation(.easeInOut(duration: 0.2), value: endTime)
            }

            Text(endTimeError.isEmpty ? " " : endTimeError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(endTimeError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: endTimeError.isEmpty)
        }
        .padding(.top, 10)
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
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                Text(selectedLocationText)
                    .fontWeight(selectedPlacemark == nil ? .regular : .medium)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(selectedPlacemark == nil ? Color("SecondaryText") : Color("PrimaryText"))
                    .tracking(-0.25)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    Button("Edit", action: {
                        showMapSheet.toggle()
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("ButtonColors"))
                    .hidden(selectedPlacemark == nil)
                    
                    Button(action: {
                        showMapSheet.toggle()
                    }) {
                        Image(systemName: "mappin")
                            .imageScale(.large)
                            .foregroundStyle(Color("IconColors"))
                    }
                    .hidden(selectedPlacemark != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && selectedPlacemark == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .onTapGesture {
                showMapSheet.toggle()
            }
            .fullScreenCover(isPresented: $showMapSheet) {
                NavigationView {
                    LocationView(selectedPlacemark: $selectedPlacemark, showMapSheet: $showMapSheet)
                }
            }
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Location")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -9) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(selectedPlacemark != nil ? 1 : 0) // Show label only when floating
                .animation(.easeInOut(duration: 0.2), value: selectedPlacemark)
            }

            Text(locationError.isEmpty ? " " : locationError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(locationError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: locationError.isEmpty)
        }
        .padding(.top, 10)
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
                            .foregroundStyle(Color("PrimaryText"))
                            .tracking(-0.25)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .imageScale(.medium)
                            .foregroundStyle(Color.white)
                            .padding(7.5)
                            .background {
                                Circle()
                                    .fill(Color("ButtonColors"))
                            }
                    }
                    .padding(.trailing)
                    .padding(.bottom, 10)
                }
            } else {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Spacer()
                            Button("Edit", action: {
                                showInviteUsersSheet.toggle()
                            })
                            .font(.footnote)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color("ButtonColors"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(selectedFriends.enumerated()), id: \.element.id) { index, user in
                                // only show if expanded OR within the first 2 items
                                if showMoreInvitees || index < initialVisibleCount {
                                    HStack {
                                        InvitedUserRow(user: user)
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                selectedFriends.removeAll { $0.id == user.id }
                                            }
                                        }, label: {
                                            Image(systemName: "xmark")
                                                .imageScale(.medium)
                                                .foregroundStyle(Color("IconColors"))
                                        })
                                    }
                                }
                            }
                        }
                        
                        // only show the toggle button when there are more than 2
                        if selectedFriends.count > initialVisibleCount {
                            Button {
                                withAnimation {
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
                                .foregroundStyle(Color("ErrorTextColor"))
                                .padding(.top, 8)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .animation(nil, value: showMoreInvitees)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("TextFieldBorders"), lineWidth: 1)
                    }
                    .overlay(alignment: .topLeading) {
                        // This HStack creates the label with padding for the background.
                        HStack(spacing: 0) {
                            Text("Invited Friends")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .padding(.horizontal, 4)
                                .background(Color("BackgroundColor")) // This background cuts the border
                                .offset(y: -9) // Move label up or keep it centered
                                .padding(.leading, 16)
                        }
                    }

                    Text(" ")
                        .font(.footnote)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("ErrorTextColor"))
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: selectedFriends.isEmpty)
        .padding(.top, 10)
    }
}

struct InvitedUserCell: View {
    
    let friend: User
    let isAvailable: Bool
    @State private var imageLoadingError = false
    
    var body: some View {
            HStack(alignment: .center, spacing: 10) {
                if !imageLoadingError {
                    KFImage.url(URL(string: friend.profileImage))
                        .placeholder {
                            ProgressView()
                        }
                        .loadDiskFileSynchronously()
                        .fade(duration: 0.25)
                        .onProgress { receivedSize, totalSize in  }
                        .onSuccess { result in  }
                        .onFailure { _ in
                            self.imageLoadingError = true
                        }
                        .resizable() // Makes the image resizable
                        .scaledToFill() // Fills the frame, preventing distortion
                        .frame(width: 55, height: 55) // Sets a square frame for the circle
                        .clipShape(Circle()) // Clips the view into a circle shape
                        .alignmentGuide(.listRowSeparatorLeading) {
                                            $0[.leading]
                                        }
                } else {
                    Circle()
                        .strokeBorder(Color("ButtonColors"), lineWidth: 1.75)
                        .background(Color.clear)
                        .frame(width: 55, height: 55)
                        .overlay {
                            // Show while loading or if image fails to load
                            Circle()
                                .fill(Color("SectionalColors"))
                                .frame(width: 53.25, height: 53.25)
                                .overlay {
                                    Text("\(friend.displayName.first?.uppercased() ?? "J")\(friend.displayName.last?.uppercased() ?? "D")")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color("PrimaryText"))
                                        .multilineTextAlignment(.center)
                                }
                        }
                        .alignmentGuide(.listRowSeparatorLeading) {
                                            $0[.leading]
                                        }
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(friend.displayName)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 0) {
                        Text("@")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color("SecondaryText"))
                            .multilineTextAlignment(.leading)
                        Text("\(friend.username)")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .tracking(1.05)
                            .foregroundStyle(Color("SecondaryText"))
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    if !isAvailable {
                        Text("Not available")
                            .font(.footnote)
                            .foregroundStyle(Color("ErrorTextColor"))
                            .fontDesign(.rounded)
                            .tracking(1.05)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 6)
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
        VStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 0) {
            
                TextField("", text: notesBinding, prompt:
                          Text("Add Notes")
                              .font(.subheadline)
                              .fontDesign(.monospaced)
                              .foregroundStyle(Color("SecondaryText"))
                              .tracking(-0.25),
                          axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .focused(isFocused, equals: .description)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .onChange(of: notes) { _, newValue in
                        guard let newValue = newValue else { return }
                        guard isFocused.wrappedValue == .description else { return }
                        guard newValue.contains("\n") else { return }
                        isFocused.wrappedValue = nil
                        notes = newValue.replacing("\n", with: "")
                    }
                
                Spacer()
                Button(action: {
                    notes = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("ScheduleButtonColors"))
                }
                .opacity(notes == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: notes)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && !notesError.isEmpty ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Event Notes")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -9) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(notes != nil || isFocused.wrappedValue == .description ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: notes)
            }

            Text(notesError.isEmpty ? " " : notesError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.red)
                .opacity(notesError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: notesError.isEmpty)
        }
        .padding(.top, 10)
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
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if eventColor == nil {
                    
                    Image(systemName: "paintbrush")
                        .foregroundColor(Color("IconColors"))
                        .imageScale(.large)
                } else {
                    
                    HStack(alignment: .center, spacing: 3) {
                        Image(systemName: "paintbrush")
                            .foregroundColor(Color("IconColors"))
                            .imageScale(.large)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(eventColor ?? Color.clear)
                            .frame(maxWidth: 55, maxHeight: 25)
                    }
                }
            }
            .padding(.trailing)
            .padding(.vertical, 10)
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: eventColorBinding)
        }
    }
}

