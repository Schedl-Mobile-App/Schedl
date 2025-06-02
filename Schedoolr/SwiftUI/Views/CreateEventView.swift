//
//  PopUpView 2.swift
//  calendarTest
//
//  Created by David Medina on 12/4/24.
//

import SwiftUI

struct CreateEventView: View {
    @State private var title: String = ""
    @State private var selectedDate: Date?
    @State private var showDatePicker: Bool = false
    @State private var showStartTimePicker: Bool = false
    @State private var showEndTimePicker: Bool = false
    @State private var showInviteUsersSheet: Bool = false
    @State private var showMapSheet: Bool = false
    var components = DateComponents(hour: Calendar.current.component(.hour, from: Date()), minute: Calendar.current.component(.minute, from: Date()))
    @State var eventStartTime: Date?
    @State var eventEndTime: Date?
    @State var taggedUsers: [String] = []
    @State var selectedPlacemark: MTPlacemark?
    @State var eventColor: Color?
    @State var dayList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @Environment(\.presentationMode) var presentationMode
    @FocusState var isFocused: EventInfoFields?
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    
    private var eventDateText: String {
        if let date = selectedDate {
            return date.formatted(date: .long, time: .omitted)
        }
        return ""
    }
    
    private var startTimeText: String {
        if let date = eventStartTime {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return ""
    }
    
    private var endTimeText: String {
        if let date = eventEndTime {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return ""
    }
    
    private var selectedLocationItem: MTPlacemark {
        if let location = selectedPlacemark {
            return location
        }
        return MTPlacemark(name: "", address: "", latitude: 0, longitude: 0)
    }
    
    private var selectedColor: String {
        if let color = eventColor {
            return color.toHex()!
        }
        // default blue color of the app
        return "3C859E"
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                HStack(spacing: 12) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.primary)
                    }
                    Text("Create New Event")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.system(size: 24, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 30) {
                        Text("Fill out the details below to create your event!")
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .tracking(0.1)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: 0x333333))
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack() {
                                        TextField("Event Title", text: $title)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                                            .foregroundStyle(Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .focused($isFocused, equals: .title)
                                            .autocorrectionDisabled(true)
                                        Spacer()
                                        Button(action: {
                                            title = ""
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color(hex: 0x333333))
                                        }
                                        .hidden(title.isEmpty)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Event Title")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .title || !title.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(eventDateText.isEmpty ? "Event Date" : eventDateText)
                                            .fontWeight(eventDateText.isEmpty ? .regular : .medium)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(eventDateText.isEmpty ? .secondary : Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            HStack(spacing: 8) {
                                                if selectedDate != nil {
                                                    Button("Edit", action: {
                                                        showDatePicker.toggle()
                                                    })
                                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(Color(hex: 0x3C859E))
                                                } else {
                                                    Button(action: {
                                                        showDatePicker.toggle()
                                                    }) {
                                                        Image(systemName: "calendar")
                                                            .font(.system(size: 20))
                                                            .foregroundStyle(Color(hex: 0x333333))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    showDatePicker.toggle()
                                }
                                .sheet(isPresented: $showDatePicker) {
                                    NavigationView {
                                        DatePicker("Select Event Date",
                                                  selection: Binding(
                                                    get: { selectedDate ?? Date() },
                                                    set: { newDate in
                                                        selectedDate = newDate
                                                        isFocused = .date
                                                    }
                                                  ),
                                                  displayedComponents: [.date])
                                            .datePickerStyle(.graphical)
                                            .navigationTitle("Select Date")
                                            .navigationBarTitleDisplayMode(.inline)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarTrailing) {
                                                    Button("Done") {
                                                        showDatePicker = false
                                                    }
                                                }
                                            }
                                    }
                                    .presentationDetents([.medium])
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Event Date")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .date || selectedDate != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(startTimeText.isEmpty ? "Start Time" : startTimeText)
                                            .fontWeight(startTimeText.isEmpty ? .light : .medium)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(startTimeText.isEmpty ? .secondary : Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            HStack(spacing: 8) {
                                                if eventStartTime != nil {
                                                    Button("Edit", action: {
                                                        showStartTimePicker.toggle()
                                                    })
                                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(Color(hex: 0x3C859E))
                                                } else {
                                                    Button(action: {
                                                        showStartTimePicker.toggle()
                                                    }) {
                                                        Image(systemName: "clock.badge")
                                                            .font(.system(size: 20))
                                                            .foregroundStyle(Color(hex: 0x333333))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    showStartTimePicker.toggle()
                                }
                                .sheet(isPresented: $showStartTimePicker) {
                                    NavigationView {
                                        DatePicker("",
                                                  selection: Binding(
                                                    get: { eventStartTime ?? Date() },
                                                    set: { newTime in
                                                        eventStartTime = newTime
                                                        isFocused = .startTime
                                                    }
                                                  ),
                                                  displayedComponents: [.hourAndMinute])
                                            .datePickerStyle(.wheel)
                                            .navigationTitle("Select Start Time")
                                            .navigationBarTitleDisplayMode(.inline)
                                            .labelsHidden()
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarTrailing) {
                                                    Button("Done") {
                                                        showStartTimePicker = false
                                                    }
                                                }
                                            }
                                    }
                                    .presentationDetents([.medium])
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Start Time")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .startTime || eventStartTime != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(endTimeText.isEmpty ? "End Time" : endTimeText)
                                            .fontWeight(endTimeText.isEmpty ? .light : .medium)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(endTimeText.isEmpty ? .secondary : Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            HStack(spacing: 8) {
                                                if eventEndTime != nil {
                                                    Button("Edit", action: {
                                                        showEndTimePicker.toggle()
                                                    })
                                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(Color(hex: 0x3C859E))
                                                } else {
                                                    Button(action: {
                                                        showEndTimePicker.toggle()
                                                    }) {
                                                        Image(systemName: "clock.badge")
                                                            .font(.system(size: 20))
                                                            .foregroundStyle(Color(hex: 0x333333))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    showEndTimePicker.toggle()
                                }
                                .sheet(isPresented: $showEndTimePicker) {
                                    NavigationView {
                                        DatePicker("",
                                                  selection: Binding(
                                                    get: { eventEndTime ?? Date() },
                                                    set: { newTime in
                                                        eventEndTime = newTime
                                                        isFocused = .endTime
                                                    }
                                                  ),
                                                  displayedComponents: [.hourAndMinute])
                                            .datePickerStyle(.wheel)
                                            .navigationTitle("Select End Time")
                                            .navigationBarTitleDisplayMode(.inline)
                                            .labelsHidden()
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarTrailing) {
                                                    Button("Done") {
                                                        showEndTimePicker = false
                                                    }
                                                }
                                            }
                                    }
                                    .presentationDetents([.medium])
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("End Time")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .endTime || eventEndTime != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(selectedLocationItem.name.isEmpty ? "Add Location" : selectedLocationItem.name)
                                            .fontWeight(.light)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            HStack(spacing: 8) {
                                                if !selectedLocationItem.name.isEmpty {
                                                    Button("Edit", action: {
                                                        showMapSheet.toggle()
                                                    })
                                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(Color(hex: 0x3C859E))
                                                } else {
                                                    Button(action: {
                                                        showMapSheet.toggle()
                                                        isFocused = .location
                                                    }) {
                                                        Image(systemName: "mappin")
                                                            .font(.system(size: 20))
                                                            .foregroundStyle(Color(hex: 0x333333))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    showMapSheet.toggle()
                                    isFocused = .location
                                }
                                .fullScreenCover(isPresented: $showMapSheet, onDismiss: {
                                    print("Location selected: \(selectedPlacemark?.name ?? "None")")
                                }) {
                                    NavigationView {
                                        LocationView(selectedPlacemark: $selectedPlacemark)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button("Cancel") {
                                                        selectedPlacemark = nil // Clear selection if cancelled
                                                        showMapSheet = false
                                                    }
                                                }
                                                ToolbarItem(placement: .navigationBarTrailing) {
                                                    Button("Done") {
                                                        showMapSheet = false
                                                    }
                                                    .disabled(selectedPlacemark == nil)
                                                }
                                            }
                                    }
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Location")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(!selectedLocationItem.name.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(taggedUsers.isEmpty ? "Invite Users" : "")
                                            .fontWeight(.light)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            HStack(spacing: 8) {
                                                if !taggedUsers.isEmpty {
                                                    Button("Edit", action: {
                                                        showInviteUsersSheet.toggle()
                                                    })
                                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(Color(hex: 0x3C859E))
                                                } else {
                                                    Button(action: {
                                                        showInviteUsersSheet.toggle()
                                                    }) {
                                                        Image(systemName: "person.badge.plus")
                                                            .font(.system(size: 20))
                                                            .foregroundStyle(Color(hex: 0x333333))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    showInviteUsersSheet.toggle()
                                }
                                .sheet(isPresented: $showInviteUsersSheet) {
                                    NavigationView {
                                        AddInvitedUsers(taggedUsers: $taggedUsers)
                                            .environmentObject(scheduleViewModel)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarTrailing) {
                                                    Button("Done") {
                                                        showInviteUsersSheet = false
                                                    }
                                                }
                                            }
                                    }
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Invited Users")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(!taggedUsers.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        HStack {
                            ColorPicker(
                                "Choose a color",
                                selection: Binding(
                                    get: { eventColor ?? Color(hex: 0x3C859E) },
                                    set: { chosenColor in
                                        eventColor = chosenColor
                                    }
                                )
                            )
                        }
                        
                        Button(action: {
                            Task {
                                if (selectedDate != nil && selectedPlacemark != nil) {
                                    await scheduleViewModel.createEvent(title: title, eventDate: Date.convertCurrentDateToTimeInterval(date: selectedDate ?? Date()), startTime: Date.computeTimeSinceStartOfDay(date: eventStartTime ?? Date()), endTime: Date.computeTimeSinceStartOfDay(date: eventEndTime ?? Date()), location: selectedLocationItem, taggedUsers: taggedUsers, color: selectedColor)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .overlay {
                                    Text("Create Event")
                                        .foregroundColor(Color(hex: 0xf7f4f2))
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                        .tracking(0.1)
                                }
                        }
                        .frame(maxWidth: .infinity, minHeight: 45)
                        .foregroundStyle(Color(hex: 0x3C859E))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 25)
                .defaultScrollAnchor(.top)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    isFocused = nil
                }
                .onChange(of: isFocused, {
                    scheduleViewModel.errorMessage = nil
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AddInvitedUsers: View {
    
    @Binding var taggedUsers: [String]
    @State var searchText: String = ""
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    
    func checkForMatches() {
        print("Do something later")
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            VStack(spacing: 15) {
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .font(.system(size: 16))
                    }
                    
                    TextField("Search friends", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                    
                    Spacer()
                    
                    Button("Clear", action: {
                        searchText = ""
                    })
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x3C859E))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(scheduleViewModel.friends, id: \.self.id) { friend in
                            HStack(spacing: 15) {
                                Circle()
                                    .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                                    .background(Color.clear)
                                    .frame(width: 39.75, height: 39.75)
                                    .overlay {
                                        AsyncImage(url: URL(string: friend.profileImage)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 38, height: 38)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            // Show while loading or if image fails to load
                                            Circle()
                                                .fill(Color(hex: 0xe0dad5))
                                                .frame(width: 38, height: 38)
                                                .overlay {
                                                    Text("\(friend.displayName.first?.uppercased() ?? "J")\(friend.displayName.last?.uppercased() ?? "D")")
                                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                        .foregroundStyle(Color(hex: 0x333333))
                                                        .multilineTextAlignment(.center)
                                                }
                                        }
                                    }
                                
                                VStack(alignment: .leading) {
                                    Text("\(friend.displayName)")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .multilineTextAlignment(.leading)
                                    Text("\(friend.username)")
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .multilineTextAlignment(.leading)
                                }
                                .fixedSize(horizontal: true, vertical: false)
                                
                                Spacer()
                                
                                Button(action: {
                                    if taggedUsers.contains(friend.id) {
                                        taggedUsers.removeAll(where: { $0 == friend.id })
                                    } else {
                                        taggedUsers.append(friend.id)
                                    }
                                }) {
                                    Circle()
                                        .fill(taggedUsers.contains(friend.id) ? Color(hex: 0x3C859E) : Color.clear)
                                        .stroke(Color(hex: 0x333333), lineWidth: 1.5)
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .scrollDismissesKeyboard(.immediately)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            Task {
                await scheduleViewModel.fetchFriends()
            }
        }
    }
}
