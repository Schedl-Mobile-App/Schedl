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
    @State private var selectedEndDate: Date?
    @State private var showDatePicker: Bool = false
    @State private var showEndDatePicker: Bool = false
    @State private var showStartTimePicker: Bool = false
    @State private var showEndTimePicker: Bool = false
    @State private var showInviteUsersSheet: Bool = false
    @State private var showMapSheet: Bool = false
    var components = DateComponents(hour: Calendar.current.component(.hour, from: Date()), minute: Calendar.current.component(.minute, from: Date()))
    @State var repeatedDays: [String]?
    @State var eventStartTime: Date?
    @State var eventEndTime: Date?
    @State var selectedPlacemark: MTPlacemark?
    @State var eventColor: Color?
    @State var eventNotes: String = ""
    @State var dayList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @Environment(\.presentationMode) var presentationMode
    @FocusState var isFocused: EventInfoFields?
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @State var initialVisibleCount = 2
    @State var isExpanded = false
    
    private var eventDateText: String {
        if let date = selectedDate {
            return date.formatted(date: .long, time: .omitted)
        }
        return ""
    }
    
    private var eventEndDateText: String {
        if let date = selectedEndDate {
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
                ZStack(alignment: .leading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .font(.title3)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    
                    
                    Text("Event Details")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(0.1)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                
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
                                            .foregroundStyle(eventDateText.isEmpty ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
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
                                                if selectedDate != nil {
                                                    ToolbarItem(placement: .navigationBarLeading) {
                                                        Button("Clear") {
                                                            selectedDate = nil
                                                            showDatePicker = false
                                                        }
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
                        
                        if !eventDateText.isEmpty {
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
                                                    if repeatedDays == nil {
                                                        repeatedDays = []
                                                    }
                                                    repeatedDays!.contains(String(index)) ? repeatedDays?.removeAll(where: { $0 == String(index) }) : repeatedDays?.append(String(index))
                                                }) {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill((repeatedDays != nil && repeatedDays!.contains(String(index))) ? Color(hex: 0x3C859E) : Color.gray.opacity(0.2))
                                                        .frame(width: 25, height: 25)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    HStack {
                                        Text("Repeating Until")
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .font(.caption)
                                            .tracking(0.1)
                                            .foregroundStyle(Color(hex: 0x333333))
                                        Spacer()
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
                                                .font(.system(size: 20))
                                                .foregroundStyle(Color(hex: 0x333333))
                                        }
                                    }
                                    .sheet(isPresented: $showEndDatePicker) {
                                        NavigationView {
                                            DatePicker("Select End Date",
                                                      selection: Binding(
                                                        get: { selectedEndDate ?? Date() },
                                                        set: { newDate in
                                                            selectedEndDate = newDate
                                                        }
                                                      ),
                                                      displayedComponents: [.date])
                                                .datePickerStyle(.graphical)
                                                .navigationTitle("Select End Date")
                                                .navigationBarTitleDisplayMode(.inline)
                                                .toolbar {
                                                    if selectedEndDate != nil {
                                                        ToolbarItem(placement: .navigationBarLeading) {
                                                            Button("Clear") {
                                                                selectedEndDate = nil
                                                                showEndDatePicker = false
                                                            }
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
                                    }
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: 0xf7f4f2))
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                                
                                HStack {
                                    Spacer(minLength: 8)
                                    Text("Recurring Days")
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
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
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
                                            .foregroundStyle(startTimeText.isEmpty ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
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
                                            .foregroundStyle(endTimeText.isEmpty ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
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
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .font(.system(size: 15, design: .monospaced))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(selectedLocationItem.name.isEmpty ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                                        
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
                        
                        if scheduleViewModel.invitedUsersForEvent.isEmpty || showInviteUsersSheet {
                            Button(action: {
                                showInviteUsersSheet.toggle()
                            }) {
                                HStack(spacing: 0) {
                                    Text("Invite Friends to Your Event?")
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .font(.subheadline)
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundStyle(Color.white)
                                        .background {
                                            Circle()
                                                .fill(Color(hex: 0x3C859E))
                                                .frame(width: 25, height: 25)
                                        }
                                }
                            }
                            .padding(.trailing, 20)
                            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                            .sheet(isPresented: $showInviteUsersSheet) {
                                NavigationView {
                                    AddInvitedUsers(scheduleViewModel: scheduleViewModel)
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Button("Done") {
                                                    showInviteUsersSheet = false
                                                }
                                            }
                                        }
                                }
                            }
                            
                        } else {
                            ZStack(alignment: .topLeading) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Spacer()
                                        Button("Edit", action: {
                                            showInviteUsersSheet.toggle()
                                        })
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x3C859E))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(Array(scheduleViewModel.invitedUsersForEvent.enumerated()), id: \.element.id) { index, user in
                                            if isExpanded || index < initialVisibleCount {
                                                HStack {
                                                    InvitedUserRow(user: user)
                                                        .transition(.asymmetric(
                                                            insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: -10)),
                                                            removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 10))
                                                        ))
                                                        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isExpanded)
                                                    Spacer()
                                                    Button(action: {
                                                        scheduleViewModel.invitedUsersForEvent.removeAll(where: { $0.id == user.id })
                                                    }) {
                                                        Image(systemName: "xmark")
                                                            .font(.system(size: 14))
                                                            .foregroundStyle(Color(hex: 0x333333))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    if scheduleViewModel.invitedUsersForEvent.count > initialVisibleCount {
                                        Button(action: {
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                isExpanded.toggle()
                                            }
                                        }) {
                                            HStack {
                                                Text(isExpanded ? "Show Less" : "Show \(scheduleViewModel.invitedUsersForEvent.count - initialVisibleCount) More")
                                                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                                    .imageScale(.medium)
                                            }
                                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                            .foregroundStyle(Color(hex: 0x3C859E))
                                            .padding(.top)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                                
                                HStack {
                                    Spacer(minLength: 8)
                                    Text("Invited Friends")
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
                                .opacity(!scheduleViewModel.invitedUsersForEvent.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: isFocused)
                            }
                        }
                        
                        ZStack(alignment: .topLeading) {
                            HStack(alignment: .top) {
                                TextField(
                                    "Add Notes",
                                    text: $eventNotes,
                                    axis: .vertical,
                                )
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .font(.system(size: 15))
                                .tracking(0.1)
                                .focused($isFocused, equals: .description)
                                .foregroundStyle(Color(hex: 0x333333))
                                
                                Spacer()
                                Button(action: {
                                    eventNotes = ""
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(hex: 0x333333))
                                }
                                .hidden(eventNotes.isEmpty)
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 20)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            }
                                                                
                            HStack {
                                Spacer(minLength: 8)
                                Text("Event Notes")
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
                            .opacity(isFocused == .description || !eventNotes.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        HStack(spacing: 0) {
                            Text("Choose a Color For Your Event?")
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .font(.subheadline)
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                                .tracking(0.1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { eventColor ?? Color(hex: 0x3C859E) },
                                    set: { chosenColor in
                                        eventColor = chosenColor
                                    }
                                )
                            )
                            .frame(width: 25, height: 25)
                        }
                        .padding(.trailing, 20)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        
                        Button(action: {
                            Task {
                                if (selectedDate != nil && selectedPlacemark != nil && selectedEndDate != nil) {
                                    await scheduleViewModel.createEvent(title: title, startDate: Date.convertCurrentDateToTimeInterval(date: selectedDate ?? Date()), startTime: Date.computeTimeSinceStartOfDay(date: eventStartTime ?? Date()), endTime: Date.computeTimeSinceStartOfDay(date: eventEndTime ?? Date()), location: selectedLocationItem, color: selectedColor, notes: eventNotes, endDate: Date.convertCurrentDateToTimeInterval(date: selectedEndDate ?? Date()), repeatedDays: repeatedDays)
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    await scheduleViewModel.createEvent(title: title, startDate: Date.convertCurrentDateToTimeInterval(date: selectedDate ?? Date()), startTime: Date.computeTimeSinceStartOfDay(date: eventStartTime ?? Date()), endTime: Date.computeTimeSinceStartOfDay(date: eventEndTime ?? Date()), location: selectedLocationItem, color: selectedColor, notes: eventNotes, endDate: nil, repeatedDays: repeatedDays)
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
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundStyle(Color(hex: 0x3C859E))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.2), value: eventDateText)
                }
                .padding(.horizontal, 25)
                .defaultScrollAnchor(.top, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    isFocused = nil
                }
                .onChange(of: isFocused, {
                    scheduleViewModel.errorMessage = nil
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AddInvitedUsers: View {
    
    @State var searchText: String = ""
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    
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
                                    if scheduleViewModel.invitedUsersForEvent.contains(friend) {
                                        scheduleViewModel.invitedUsersForEvent.removeAll(where: { $0.id == friend.id })
                                    } else {
                                        scheduleViewModel.invitedUsersForEvent.append(friend)
                                    }
                                }) {
                                    Circle()
                                        .fill(scheduleViewModel.invitedUsersForEvent.contains(friend) ? Color(hex: 0x3C859E) : Color.clear)
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
