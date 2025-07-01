//
//  PopUpView 2.swift
//  calendarTest
//
//  Created by David Medina on 12/4/24.
//

import SwiftUI

struct CreateEventView: View {
    
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @Environment(\.dismiss) var dismiss
    
    // Binding variables for picker views
    @State var title: String? = nil
    @State var eventDate: Date? = nil
    @State var eventEndDate: Date? = nil
    @State var startTime: Date? = nil
    @State var endTime: Date? = nil
    @State var selectedPlacemark: MTPlacemark? = nil
    @State var notes: String? = nil
    @State var eventColor: Color? = nil
    @State var selectedFriends: [User] = []
    @State var repeatedDays: [String]? = nil
    
    var titleBinding: Binding<String> {
        Binding(
            get: { title ?? "" },
            set: { newValue in
                title = newValue.isEmpty ? nil : newValue
            }
        )
    }
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
    var startTimeBinding: Binding<Date> {
        Binding(
            get: { startTime ?? Date.now },
            set: { selectedTime in
                startTime = selectedTime
            }
        )
    }
    var endTimeBinding: Binding<Date> {
        Binding(
            get: { endTime ?? Date.now },
            set: { selectedTime in
                endTime = selectedTime
            }
        )
    }
    var notesBinding: Binding<String> {
        Binding(
            get: { notes ?? "" },
            set: { newValue in
                notes = newValue.isEmpty ? nil : newValue
            }
        )
    }
    var eventColorBinding: Binding<Color> {
        Binding(
            get: { eventColor ?? .blue},
            set: { newColor in
                eventColor = newColor
            }
        )
    }
    
    var titleText: String {
        if let text = title {
            return text
        }
        return ""
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
    var startTimeText: String {
        if let date = startTime {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return "Start Time"
    }
    var endTimeText: String {
        if let date = endTime {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return "End Time"
    }
    var selectedLocationText: String {
        if let location = selectedPlacemark {
            return location.name
        }
        return "Add Location"
    }
    var selectedColor: String {
        if let color = eventColor {
            return color.toHex()!
        }
        // default Schedl teal color of the event if a user doesn't select one
        return "3C859E"
    }
    var notesText: String {
        if let eventNotes = notes {
            return eventNotes
        }
        return "Add Notes"
    }
    
    @State var titleError: String = ""
    @State var startDateError: String = ""
    @State var endDateError: String = ""
    @State var startTimeError: String = ""
    @State var endTimeError: String = ""
    @State var locationError: String = ""
    
    // Binding values to trigger/dismiss sheets/pickers
    @State var showDatePicker: Bool = false
    @State var showEndDatePicker: Bool = false
    @State var showStartTimePicker: Bool = false
    @State var showEndTimePicker: Bool = false
    @State var showInviteUsersSheet: Bool = false
    @State var showColorPicker: Bool = false
    @State var showMapSheet: Bool = false
    
    @State var showMoreInvitees = false
    @State var hasTriedSubmitting = false
    
    var dayList: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @FocusState var isFocused: EventInfoFields?
    var initialVisibleCount = 2
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                ZStack(alignment: .leading) {
                    Button(action: {
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
                                        TextField("Event Title", text: titleBinding)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                                            .foregroundStyle(Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .focused($isFocused, equals: .title)
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
                                    .padding(.horizontal, 20)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && title == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                            .opacity(isFocused == .title || title != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(titleError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !titleError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(eventDateText)
                                            .fontWeight(eventDate == nil ? .light : .medium)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(eventDate == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            Button("Edit", action: {
                                                showDatePicker.toggle()
                                            })
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
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
                                    .padding(.horizontal, 20)
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
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && eventDate == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                            .opacity(isFocused == .date || eventDate != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(startDateError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !startDateError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        
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
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && !endDateError.isEmpty ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                                
                                Text(endDateError)
                                    .font(.footnote)
                                    .offset(x: 12, y: 120)
                                    .foregroundStyle(.red)
                                    .opacity(hasTriedSubmitting && !endDateError.isEmpty ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(startTimeText)
                                            .fontWeight(startTime == nil ? .light : .medium)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(startTime == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            Button("Edit", action: {
                                                showStartTimePicker.toggle()
                                            })
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
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
                                    .padding(.horizontal, 20)
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
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && !startTimeError.isEmpty ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                            .opacity(isFocused == .startTime || startTime != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(startTimeError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !startTimeError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(endTimeText)
                                            .fontWeight(endTime == nil ? .light : .medium)
                                            .font(.system(size: 15, design: .monospaced))
                                            .foregroundStyle(endTime == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            Button("Edit", action: {
                                                showEndTimePicker.toggle()
                                            })
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
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
                                    .padding(.horizontal, 20)
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
                                            .navigationTitle("Select End Time")
                                            .navigationBarTitleDisplayMode(.inline)
                                            .labelsHidden()
                                            .toolbar {
                                                ToolbarItem(placement: .topBarLeading) {
                                                    Button("Clear") {
                                                        endTime = nil
                                                        showEndTimePicker = false
                                                    }
                                                }
                                                
                                                ToolbarItem(placement: .topBarTrailing) {
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
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && !endTimeError.isEmpty ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                            .opacity(isFocused == .endTime || endTime != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(endTimeError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !endTimeError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    HStack {
                                        Text(selectedLocationText)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .font(.system(size: 15, design: .monospaced))
                                            .tracking(0.1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(selectedPlacemark == nil ? Color(hex: 0xC7C7CD) : Color(hex: 0x333333))
                                        
                                        Spacer()
                                        
                                        ZStack(alignment: .trailing) {
                                            Button("Edit", action: {
                                                showMapSheet.toggle()
                                            })
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
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
                                    .padding(.horizontal, 20)
                                }
                                .onTapGesture {
                                    hasTriedSubmitting = false
                                    showMapSheet.toggle()
                                }
                                .fullScreenCover(isPresented: $showMapSheet) {
                                    NavigationView {
                                        LocationView(selectedPlacemark: $selectedPlacemark)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarLeading) {
                                                    Button("Cancel") {
                                                        selectedPlacemark = nil
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
                                        .stroke(hasTriedSubmitting && selectedPlacemark == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                            .opacity(selectedPlacemark != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(locationError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !locationError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        
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
                                        ZStack(alignment: .trailing) {
                                            Image(systemName: "plus")
                                                .imageScale(.medium)
                                                .foregroundStyle(Color.white)
                                                .background {
                                                    Circle()
                                                        .fill(Color(hex: 0x3C859E))
                                                        .frame(width: 25, height: 25)
                                                }
                                        }
                                    }
                                }
                                .padding(.trailing, 20)
                                .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
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
                                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
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
                                    .opacity(!selectedFriends.isEmpty ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.4), value: selectedFriends.isEmpty)
                        .sheet(isPresented: $showInviteUsersSheet) {
                            AddInvitedUsers(userFriends: $scheduleViewModel.friends, selectedFriends: $selectedFriends, scheduleViewModel: scheduleViewModel)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            HStack(alignment: .top) {
                                TextField(
                                    "Add Notes",
                                    text: notesBinding,
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
                                    notes = nil
                                }) {
                                    Image(systemName: "xmark")
                                        .imageScale(.small)
                                        .foregroundStyle(Color(hex: 0x333333))
                                }
                                .hidden(notes == nil)
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
                            .opacity(isFocused == .description || notes != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        Button(action: {
                            showColorPicker.toggle()
                        }) {
                            HStack(spacing: 0) {
                                Text(eventColor == nil ? "Choose a Color For Your Event?" : "Selected Event Color:")
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .tracking(-0.25)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.9)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ZStack(alignment: .trailing) {
                                    Image(systemName: "paintbrush")
                                        .foregroundColor(Color(hex: 0x333333))
                                        .imageScale(.large)
                                        .hidden(eventColor != nil)
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "paintbrush")
                                            .foregroundColor(Color(hex: 0x333333))
                                            .imageScale(.medium)
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: Int(selectedColor, radix: 16)!))
                                            .frame(width: 50, height: 25)
                                    }
                                    .hidden(eventColor == nil)
                                }
                            }
                            .padding(.trailing)
                            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        }
                        .sheet(isPresented: $showColorPicker) {
                            ColorPickerSheet(selectedColor: eventColorBinding)
                        }
                        
                        Button(action: {
                            titleError = ""
                            startDateError = ""
                            endDateError = ""
                            startTimeError = ""
                            endTimeError = ""
                            locationError = ""
                            
                            var isValid = true
                            
                            if title == nil {
                                titleError = "Title is required"
                                isValid = false
                            }
                            if eventDate == nil {
                                startDateError = "Start date is required"
                                isValid = false
                            }
                            if startTime == nil {
                                startTimeError = "Start time is required"
                                isValid = false
                            }
                            if endTime == nil {
                                endTimeError = "End time is required"
                                isValid = false
                            }
                            if selectedPlacemark == nil {
                                locationError = "Location is required"
                                isValid = false
                            }
                            
                            if let startTime = startTime, let endTime = endTime {
                                if Date.computeTimeSinceStartOfDay(date: endTime) < Date.computeTimeSinceStartOfDay(date: startTime) {
                                    endTimeError = "Invalid time range"
                                    isValid = false
                                } else if Date.computeTimeSinceStartOfDay(date: endTime) > 60 * 60 * 24 {
                                    endTimeError = "End time exceeds current day"
                                    isValid = false
                                }
                            }
                            
                            if repeatedDays != nil {
                                if let startDate = eventDate, let endDate = eventEndDate {
                                    if endDate.timeIntervalSince1970 < startDate.timeIntervalSince1970 {
                                        endDateError = "Invalid end date"
                                        isValid = false
                                    } else if repeatedDays!.isEmpty {
                                        endDateError = "No repeated days have been selected with the end date"
                                        isValid = false
                                    }
                                } else if !repeatedDays!.isEmpty {
                                    endDateError = "End date is required for recurring events"
                                    isValid = false
                                }
                            } else if eventEndDate != nil {
                                endDateError = "No repeated days have been selected with the end date"
                                isValid = false
                            }
                            
                            if !isValid {
                                hasTriedSubmitting = true
                                return
                            }
                            
                            let safeTitle     = title!
                            let safeDate      = eventDate!
                            let safeStart     = startTime!
                            let safeEnd       = endTime!
                            let safeLocation  = selectedPlacemark!
                            let eventNotes = notes ?? ""
                            let endDateAsDouble: Double? = eventEndDate == nil ? nil : eventEndDate!.timeIntervalSince1970
                            
                            Task {
                                await scheduleViewModel.createEvent(title: safeTitle, startDate: safeDate.timeIntervalSince1970, startTime: Date.computeTimeSinceStartOfDay(date: safeStart), endTime: Date.computeTimeSinceStartOfDay(date: safeEnd), location: safeLocation, color: selectedColor, notes: eventNotes, invitedUsers: selectedFriends, endDate: endDateAsDouble, repeatedDays: repeatedDays)
                                dismiss()
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
                    .padding(.vertical)
                    .padding(.horizontal, 25)
                    .simultaneousGesture(TapGesture().onEnded {
                        if hasTriedSubmitting {
                            hasTriedSubmitting = false
                        }
                    })
                }
                .defaultScrollAnchor(.top, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    isFocused = nil
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            scheduleViewModel.shouldReloadData = false
        }
        .onDisappear {
            scheduleViewModel.shouldReloadData = true
        }
    }
}

struct AddInvitedUsers: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var searchText: String = ""
    @Binding var userFriends: [User]
    @Binding var selectedFriends: [User]
    @FocusState var isSearching: Bool?
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return userFriends
        } else {
            let filteredResults = userFriends.filter { user in
                let startsWith = user.displayName.lowercased().hasPrefix(searchText.lowercased())
                let endsWith = user.displayName.lowercased().hasSuffix(searchText.lowercased())
                
                return startsWith || endsWith
            }
            
            return filteredResults
        }
    }
    
    var body: some View {
        NavigationView {
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
                            InvitedUserCell(friend: friend, selectedFriends: $selectedFriends)
                        }
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.immediately)
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
            .onTapGesture {
                isSearching = nil
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            await scheduleViewModel.fetchFriends()
        }
    }
}

struct InvitedUserCell: View {
    
    let friend: User
    @Binding var selectedFriends: [User]
    
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

