//
//  PopUpView 2.swift
//  calendarTest
//
//  Created by David Medina on 12/4/24.
//

import SwiftUI
import Kingfisher

struct CreateEventView: View {
    
    @StateObject var vm: EventViewModel
    @Environment(\.dismiss) var dismiss
    
    @FocusState var isFocused: EventInfoFields?
    
    init(currentUser: User, currentScheduleId: String?) {
        _vm = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, currentScheduleId: currentScheduleId))
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Fill out the details below to create your event!")
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("PrimaryText"))
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 0) {
                        
                        // Picker for selecting a schedule by id
                        // Bridge selection to a String? id so Picker can infer SelectionValue
                        let selectedScheduleIdBinding: Binding<String?> = Binding(
                            get: { vm.selectedSchedule?.id },
                            set: { newId in
                                // Update the view model's selectedSchedule based on the id
                                if let id = newId, let match = vm.schedules.first(where: { $0.id == id }) {
                                    vm.selectedSchedule = match
                                } else {
                                    vm.selectedSchedule = nil
                                }
                            }
                        )
                        
                        Section {
                            Picker("Schedule", selection: selectedScheduleIdBinding) {
                                // Provide a placeholder option when nothing is selected
                                Text("None").tag(String?.none)
                                ForEach(vm.schedules, id: \.id) { schedule in
                                    // Use a readable property for the label; fallback to id if needed
                                    Text(schedule.title)
                                        .tag(Optional(schedule.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .task {
                                await vm.fetchSchedules()
                            }
                        }
                        
                        // view for event title input
                        EventTitleView(title: $vm.title, isFocused: $isFocused, hasTriedSubmitting: $vm.hasTriedSubmitting, titleError: $vm.titleError)
                        
                        // view for event date and recurring days seletion
                        EventDateView(eventDate: $vm.startDate, recurrence: $vm.recurrence, hasTriedSubmitting: vm.hasTriedSubmitting, startDateError: vm.startDateError, recurrenceError: vm.recurrenceError)
                        
                        EventStartTimeView(startTime: $vm.startTime, hasTriedSubmitting: vm.hasTriedSubmitting, startTimeError: vm.startTimeError)
                        
                        EventEndTimeView(endTime: $vm.endTime, endTimeError: vm.endTimeError, hasTriedSubmitting: vm.hasTriedSubmitting)
                        
                        // view for location selection
                        EventLocationView(selectedPlacemark: $vm.selectedPlacemark, locationError: vm.locationError, hasTriedSubmitting: vm.hasTriedSubmitting)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $vm.selectedFriends, currentUser: vm.currentUser)
                        
                        // view for event notes input
                        EventNotesView(notes: $vm.notes, notesError: vm.notesError, hasTriedSubmitting: vm.hasTriedSubmitting, isFocused: $isFocused)
                        
                        // view for event color selection
                        EventColorView(eventColor: $vm.eventColor)
                    }
                    
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            Task {
                                await vm.createEvent()
                            }
                        }, label: {
                            Text("Create Event")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .lineLimit(1)
                                .padding()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        })
                        .glassEffect(.regular.tint(Color("ButtonColors")).interactive(), in: .capsule)
                        
                    } else {
                        Button(action: {
                            Task {
                                await vm.createEvent()
                            }
                        }, label: {
                            Text("Create Event")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .lineLimit(1)
                                .padding()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.borderless)
                        .background(Color("ButtonColors"), in: .capsule)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 25)
                .simultaneousGesture(TapGesture().onEnded {
                    withAnimation {
                        isFocused = nil
                        vm.resetErrors()
                        if vm.hasTriedSubmitting {
                            vm.hasTriedSubmitting = false
                        }
                    }
                })
            }
            .defaultScrollAnchor(.top, for: .initialOffset)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let mockUser = MockUserFactory.createUser()
    
    CreateEventView(currentUser: mockUser, currentScheduleId: nil)
}

struct AddInvitedUsers: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var vm: FriendViewModel
    @Binding var selectedFriends: [User]
        
    init(currentUser: User, selectedFriends: Binding<[User]>) {
        _vm = StateObject(wrappedValue: FriendViewModel(profileUser: currentUser))
        _selectedFriends = selectedFriends
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
                                })
                                .listRowBackground(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedFriends.contains(where: { $0.id == friend.id }) ? Color("BackgroundColor") : Color.clear,
                                                lineWidth: 2
                                            )
                                            .background(Color.clear)
                                    )
                                
                            }
                        }, header: {
                            EmptyView()
                        })
                        .listSectionSeparator(.hidden, edges: .top)
                    }
                    .listStyle(.plain)
                    .listRowBackground(Color("BackgroundColor"))
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
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                }
                .opacity(title == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: title)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(Color("TextFieldBorders"))
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

struct DatePickerView: View {
    
    @Environment(\.router) var coordinator: Router
    @Binding var date: Date?
    
    var dateBinding: Binding<Date> {
        Binding(
            get: { date ?? Calendar.current.startOfDay(for: Date()) },
            set: { selectedDate in
                date = selectedDate
            }
        )
    }
    
    var body: some View {
        NavigationView {
            DatePicker("Select Date",
                       selection: dateBinding,
                       displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        date = nil
                        coordinator.dismissSheet()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        coordinator.dismissSheet()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            if date == nil {
                date = Calendar.current.startOfDay(for: Date())
            }
            print("in on eappear of date picker view")
        }
    }
}

struct EventDateView: View {
    
    @Environment(\.router) var coordinator: Router
    
    @Binding var eventDate: Date?
    @Binding var recurrence: RecurrenceRule?
    
    var hasTriedSubmitting: Bool
    var startDateError: String
    var recurrenceError: String
    
    var abbreviatedDayList: [String] = Calendar.current.shortWeekdaySymbols
    var completeDayList: [String] = Calendar.current.weekdaySymbols
    
    var eventDateText: String {
        if let date = eventDate {
            return date.formatted(date: .long, time: .omitted)
        }
        return "Event Date"
    }
    var eventEndDateText: String {
        if let recurrence = recurrence {
            guard let date = recurrence.endDate else { return "" }
            return date.formatted(date: .long, time: .omitted)
        }
        return "Select Date"
    }
    
    var endDateBinding: Binding<Date?> {
        Binding(
            get: { recurrence?.endDate },
            set: { newValue in
                if recurrence == nil {
                    recurrence = RecurrenceRule(endDate: newValue)
                } else {
                    recurrence?.endDate = newValue
                }
            }
        )
    }
    
    var repeatingDays: Set<Int> {
        recurrence?.repeatingDays ?? []
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
                        coordinator.present(sheet: .eventDate(date: $eventDate))
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.red)
                    .hidden(eventDate == nil)
                    
                    Button(action: {
                        coordinator.present(sheet: .eventDate(date: $eventDate))
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.red)
                            .symbolEffect(.wiggle, value: hasTriedSubmitting && eventDate == nil)
                    }
                    .hidden(eventDate != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(Color("TextFieldBorders"))
//                    .stroke(hasTriedSubmitting && eventDate == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
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
                            ForEach(Array(abbreviatedDayList.enumerated()), id: \.offset) { pair in
                                if (pair.offset != 0) {
                                    Spacer()
                                }
                                VStack(alignment: .center, spacing: 12) {
                                    Text(pair.element)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .font(.footnote)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color("PrimaryText"))
                                    
                                    Button(action: {
                                        var updated = recurrence?.repeatingDays ?? []
                                        if updated.contains(pair.offset) {
                                            updated.remove(pair.offset)
                                        } else {
                                            updated.insert(pair.offset)
                                        }
                                        if recurrence == nil {
                                            recurrence = RecurrenceRule(repeatingDays: updated)
                                        } else {
                                            recurrence?.repeatingDays = updated
                                        }
                                    }, label: {
                                        Image(systemName: repeatingDays.contains(pair.offset) ? "checkmark.square" : "square")
                                            .imageScale(.large)
                                            .contentTransition(.symbolEffect(.replace))
                                            .foregroundStyle(repeatingDays.contains(pair.offset) ? .green : .secondary)
                                    })
                                }
                                if (pair.offset != abbreviatedDayList.count - 1) {
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
                                        var updated = recurrence?.repeatingDays ?? []
                                        if updated.contains(index) {
                                            updated.remove(index)
                                        } else {
                                            updated.insert(index)
                                        }
                                        if recurrence == nil {
                                            recurrence = RecurrenceRule(repeatingDays: updated)
                                        } else {
                                            recurrence?.repeatingDays = updated
                                        }
                                    }, label: {
                                        Image(systemName: repeatingDays.contains(index) ? "checkmark.square" : "square")
                                            .imageScale(.large)
                                            .contentTransition(.symbolEffect(.replace))
                                            .foregroundStyle(repeatingDays.contains(index) ? .green : .secondary)
                                    })
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
                                    coordinator.present(sheet: .eventDate(date: endDateBinding))
                                }) {
                                    // This HStack is for the text and icon
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                            .imageScale(.medium)
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(Color("IconColors"))
                                            .symbolEffect(.wiggle, value: hasTriedSubmitting && recurrence?.endDate == nil)
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
                                .opacity(recurrence?.endDate == nil ? 0 : 1) // Fade in/out for a smoother look
                                
                                Button(action: {
                                    coordinator.present(sheet: .eventDate(date: endDateBinding))
                                }) {
                                    // This HStack is for the text and icon
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                            .imageScale(.medium)
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(.red)
                                            .symbolEffect(.wiggle, value: hasTriedSubmitting && recurrence?.endDate == nil)
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
                                .opacity(recurrence?.endDate != nil ? 0 : 1)
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
                                    coordinator.present(sheet: .eventDate(date: endDateBinding))
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
                                .opacity(recurrence?.endDate == nil ? 0 : 1)
                                
                                Button(action: {
                                    coordinator.present(sheet: .eventDate(date: endDateBinding))
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
                                    .opacity(recurrence?.endDate != nil ? 0 : 1)
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
                        .stroke(Color("TextFieldBorders"))
                }
                .overlay(alignment: .topLeading) {
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
                
                Text(recurrenceError.isEmpty ? " " : recurrenceError)
                    .font(.footnote)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(Color("ErrorTextColor"))
                    .opacity(recurrenceError.isEmpty ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: recurrenceError.isEmpty)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.top, 10)
        }
    }
}

struct TimePickerView: View {
    
    @Environment(\.router) var coordinator: Router
    @Binding var time: Date?
    
    var timeBinding: Binding<Date> {
        Binding(
            get: { time ?? Date.now },
            set: { selectedTime in
                time = selectedTime
            }
        )
    }
    
    var body: some View {
        NavigationView {
            DatePicker("",
                      selection: timeBinding,
                      displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
                .navigationTitle("Select Start Time")
                .navigationBarTitleDisplayMode(.inline)
                .labelsHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Clear") {
                            time = nil
                            coordinator.dismissSheet()
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            coordinator.dismissSheet()
                        }
                    }
                }
        }
        .presentationDetents([.medium])
        .onAppear {
            if time == nil {
                time = Date.now
            }
        }
    }
}

struct EventStartTimeView: View {
    
    @Environment(\.router) var coordinator: Router
    @Binding var startTime: Date?
    var hasTriedSubmitting: Bool
    var startTimeError: String
    
    
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
                        coordinator.present(sheet: .eventTime(time: $startTime))
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.blue)
                    .hidden(startTime == nil)
                    
                    Button(action: {
                        coordinator.present(sheet: .eventTime(time: $startTime))
                    }) {
                        Image(systemName: "clock.badge")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .symbolEffect(.wiggle, value: hasTriedSubmitting && startTime == nil)
                    }
                    .hidden(startTime != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(Color("TextFieldBorders"))
//                    .stroke(hasTriedSubmitting && startTime == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
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
    
    @Environment(\.router) var coordinator: Router
    
    @Binding var endTime: Date?
    var endTimeError: String
    var hasTriedSubmitting: Bool
    
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
                        coordinator.present(sheet: .eventTime(time: $endTime))
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.orange)
                    .hidden(endTime == nil)
                    
                    Button(action: {
                        coordinator.present(sheet: .eventTime(time: $endTime))
                    }) {
                        Image(systemName: "clock.badge")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.orange)
                            .symbolEffect(.wiggle, value: hasTriedSubmitting && endTime == nil)
                    }
                    .hidden(endTime != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(Color("TextFieldBorders"))
//                    .stroke(hasTriedSubmitting && endTime == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
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
    
    @Environment(\.router) var coordinator: Router
    @Binding var selectedPlacemark: MTPlacemark?
    var locationError: String
    var hasTriedSubmitting: Bool
    
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
                        coordinator.present(cover: .location(selectedPlacemark: $selectedPlacemark))
                    })
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.red)
                    .hidden(selectedPlacemark == nil)
                    
                    Button(action: {
                        coordinator.present(cover: .location(selectedPlacemark: $selectedPlacemark))
                    }) {
                        Image(systemName: "mappin.and.ellipse")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.red)
                            .symbolEffect(.wiggle, value: hasTriedSubmitting && selectedPlacemark == nil)
                    }
                    .hidden(selectedPlacemark != nil)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(Color("TextFieldBorders"))
//                    .stroke(hasTriedSubmitting && selectedPlacemark == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
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
    
    @Environment(\.router) var coordinator: Router
    @Binding var selectedFriends: [User]
    @State var showMoreInvitees = false
    @State private var editMode = false
    
    var currentUser: User
    var initialVisibleCount = 2
    
    var body: some View {
        Group {
            if selectedFriends.isEmpty {
                Button(action: {
                    coordinator.present(sheet: .invitedUsers(currentUser: currentUser, selectedFriends: $selectedFriends))
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
                        
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.green)
                    }
                    .padding(.trailing)
                    .padding(.bottom, 10)
                }
            } else {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header with title and add button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    editMode.toggle()
                                }
                            }, label: {
                                Text(editMode ? "Done" : "Edit")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(.blue)
                                    .padding()
                            })
                            .buttonStyle(.plain)
                        }
                        
                        List {
                            ForEach(selectedFriends) { user in
                                InvitedUserRow(user: user)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                withAnimation {
                                    selectedFriends.remove(atOffsets: indexSet)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .environment(\.editMode, .constant(editMode ? .active : .inactive))
                        .scrollIndicators(.hidden)
                        .scrollBounceBehavior(.basedOnSize)
                        .frame(height: CGFloat(min(selectedFriends.count, 4)) * 55)
                        
                        Button(action: {
                            coordinator.present(sheet: .invitedUsers(currentUser: currentUser, selectedFriends: $selectedFriends))
                        }, label: {
                            Text("Add")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .foregroundStyle(.green)
                                .padding()
                        })
                        .buttonStyle(.plain)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("TextFieldBorders"), lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 0) {
                        Text("Invited Friends")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .padding(.horizontal, 4)
                            .background(Color("BackgroundColor"))
                            .offset(y: -9)
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
                        .fontDesign(.rounded)
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
    var notesError: String
    
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
    
    var hasTriedSubmitting: Bool
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
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
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
                .opacity(notes != nil || ((notes?.isEmpty) == nil) || isFocused.wrappedValue == .description ? 1 : 0)
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
    
    @Environment(\.router) var coordinator: Router
    @Binding var eventColor: Color?
    
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
            coordinator.present(sheet: .color(color: eventColorBinding))
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
                        .foregroundStyle(
                            .linearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                        )
                        .imageScale(.large)
                } else {
                    
                    HStack(alignment: .center, spacing: 3) {
                        Image(systemName: "paintbrush")
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
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
    }
}

