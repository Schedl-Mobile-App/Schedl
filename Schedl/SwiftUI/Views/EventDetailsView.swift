//
//  Untitled.swift
//  Schedl
//
//  Created by David Medina on 7/21/25.
//

import SwiftUI

struct EventDetailsView: View {
    @StateObject private var eventViewModel: EventViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var hideTabbar = true
    @State var showMapSheet: Bool = false
    @State private var isExpanded = false
    let initialVisibleCount = 2
    @Binding var shouldReloadData: Bool
    
    var formattedDate: String {
        guard let event = eventViewModel.selectedEvent?.event else { return "" }
        let eventDate = Date(timeIntervalSince1970: event.startDate)
        return eventDate.formatted(date: .complete, time: .omitted)
    }
    
    
//    private var formattedDate: String {
//        guard let event = eventViewModel.selectedEvent?.event else { return "Date unavailable" }
//        let dateObj = Date(timeIntervalSince1970: event.startDate)
//        return dateObj.formatted(date: ., time: .omitted)
//    }
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(timeObj)
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    init(event: RecurringEvents, currentUser: User, shouldReloadData: Binding<Bool>) {
        _eventViewModel = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, selectedEvent: event))
        _shouldReloadData = Binding(projectedValue: shouldReloadData)
    }
    
    var body: some View {
        
        ZStack {
            if let selectedEvent = eventViewModel.selectedEvent {
                Color(hex: Int(selectedEvent.event.color, radix: 16)!)
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                // card component for the event details
                VStack(alignment: .leading, spacing: 25) {
                    
                    ZStack(alignment: .leading) {
                        Button(action: {
                            hideTabbar.toggle()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.bold)
                                .imageScale(.large)
                                .labelStyle(.iconOnly)
                                .foregroundStyle(Color.primary)
                        }
                        Text("Event Details")
                            .foregroundStyle(Color(hex: 0x333333))
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding([.top, .horizontal])
                    
                    Spacer()
                        .frame(height: 30)
                                        
                    VStack(alignment: .leading, spacing: 25) {
                        ZStack(alignment: .topLeading) {
                            Text(selectedEvent.event.title)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                                .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.65, alignment: .leading)
                                .padding(.top, 30)
                                                        
                            NavigationLink(destination: {
                                EditEventView(eventViewModel: eventViewModel)
                            }) {
                                Circle()
                                    .fill(Color(hex: Int(selectedEvent.event.color, radix: 16)!).opacity(0.5))
                                    .overlay {
                                        if eventViewModel.userCanEdit {
                                            Image("pencilIcon")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else {
                                            Image("eyeIcon")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                    }
                                    .containerRelativeFrame(.vertical) { height, axis in
                                        return height * 0.075
                                    }
                            }
                            .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.875, alignment: .trailing)
                            .padding(.top, 15)
                            .disabled(!eventViewModel.userCanEdit)
                        }
                        
                        if !selectedEvent.event.notes.isEmpty {
                            // area for any event notes
                            VStack(alignment: .leading, spacing: 15) {
                                Text("\(selectedEvent.event.notes)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .tracking(0.1)
                                    .foregroundStyle(Color(hex: 0x333333))
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: 0x666666))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 0.75)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: 0x666666))
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.75)
                        }
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 25) {
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    Text("Event Date")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    HStack(alignment: .center, spacing: 15) {
                                        Image(systemName: "calendar")
                                            .imageScale(.large)
                                            .fontWeight(.semibold)
                                        Text("\(formattedDate)")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color(hex: 0x333333))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Time")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    HStack(alignment: .center, spacing: 15) {
                                        Image(systemName: "calendar")
                                            .imageScale(.large)
                                            .fontWeight(.semibold)
                                        let formattedStartTime = returnTimeFormatted(timeObj: selectedEvent.event.startTime)
                                        let formattedEndTime = returnTimeFormatted(timeObj: selectedEvent.event.endTime)
                                        Text("\(formattedStartTime) → \(formattedEndTime)")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color(hex: 0x333333))
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Location")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(-0.25)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(alignment: .top, spacing: 15) {
                                            Image(systemName: "mappin")
                                                .imageScale(.large)
                                                .fontWeight(.bold)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(selectedEvent.event.locationName)")
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .fontDesign(.monospaced)
                                                    .tracking(-0.25)
                                                    .foregroundStyle(Color(hex: 0x333333))
                                                Text("\(selectedEvent.event.locationAddress)")
                                                    .font(.footnote)
                                                    .fontWeight(.bold)
                                                    .fontDesign(.monospaced)
                                                    .tracking(0.1)
                                                    .foregroundStyle(Color.gray)
                                            }
                                        }
                                        
                                        Button(action: {
                                            showMapSheet.toggle()
                                        }) {
                                            HStack {
                                                Text("More Details →")
                                            }
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .foregroundStyle(Color(hex: Int(selectedEvent.event.color, radix: 16)!))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .center) {
                                        Text("Invited Users")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color(hex: 0x333333))
                                        Spacer()
                                        Text("(\(selectedEvent.event.taggedUsers.count))")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .fontDesign(.monospaced)
                                            .tracking(-0.25)
                                            .foregroundStyle(Color(hex: 0x333333))
                                    }
                                    
                                    if !selectedEvent.event.taggedUsers.isEmpty {
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(Array(eventViewModel.invitedUsersForEvent.enumerated()), id: \.element.id) { index, user in
                                                if isExpanded || index < initialVisibleCount {
                                                    InvitedUserRow(user: user)
                                                        .transition(.asymmetric(
                                                            insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: -10)),
                                                            removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 10))
                                                        ))
                                                        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isExpanded)
                                                }
                                            }
                                            
                                            if selectedEvent.event.taggedUsers.count > initialVisibleCount {
                                                Button(action: {
                                                    withAnimation(.smooth(duration: 0.3)) {
                                                        isExpanded.toggle()
                                                    }
                                                }) {
                                                    HStack {
                                                        Text(isExpanded ? "Show Less" : "Show \(selectedEvent.event.taggedUsers.count - initialVisibleCount) More")
                                                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                                            .imageScale(.medium)
                                                    }
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                    .fontDesign(.monospaced)
                                                    .foregroundStyle(Color(hex: Int(selectedEvent.event.color, radix: 16)!))
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                }
                                                .padding(.top, 5)
                                            }
                                        }
                                        
                                        
                                    } else {
                                        Text("No users have been invited to this event.")
                                            .font(.system(size: 14, design: .monospaced))
                                            .foregroundStyle(Color.gray)
                                            .padding(.vertical, 10)
                                    }
                                }
                                .animation(.smooth(duration: 0.3), value: isExpanded)
                                
                            }
                        }
                        .defaultScrollAnchor(.top, for: .initialOffset)
                        .defaultScrollAnchor(.bottom, for: .sizeChanges)
                    }
                    .padding(.horizontal)
                    .background {
                        Image("customBackground")
                            .resizable()
                            .scaledToFill()
                            .containerRelativeFrame(.vertical) { height, axis in
                                return height + 175
                            }
                            .padding(.top, 230)
                            .ignoresSafeArea(edges: .bottom)
                    }
                }
                .fullScreenCover(isPresented: $showMapSheet) {
                    NavigationView {
                        SelectedLocationView(desiredPlacemark: MTPlacemark(name: selectedEvent.event.locationName, address: selectedEvent.event.locationAddress, latitude: selectedEvent.event.latitude, longitude: selectedEvent.event.longitude))
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showMapSheet = false
                                    }
                                }
                            }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await eventViewModel.fetchEventData()
        }
        .onAppear {
            shouldReloadData = false
        }
        .onDisappear {
            shouldReloadData = true
        }
        .toolbar(hideTabbar ? .hidden : .visible, for: .tabBar)
    }
}

struct InvitedUserRow: View {
    let user: User

    private var initials: String {
        let nameParts = user.displayName.components(separatedBy: " ")
        let firstInitial = nameParts[0].first?.uppercased() ?? "J"
        let lastInitial = nameParts.count > 1 ? nameParts[1].first?.uppercased() ?? "D" : ""
        let result = firstInitial + lastInitial
        return result.isEmpty ? "?" : result
    }
    
    private var firstName: String {
        let nameParts = user.displayName.components(separatedBy: " ")
        return nameParts[0]
    }
    
    private var lastInitial: String {
        let nameParts = user.displayName.components(separatedBy: " ")
        guard nameParts.count > 1, let lastNameInitial = nameParts[1].first?.uppercased() else { return "" }
        return lastNameInitial + "."
    }

    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                .background(Circle().fill(Color.clear))
                .frame(width: 39.75, height: 39.75)
                .overlay {
                    AsyncImage(url: URL(string: user.profileImage)) { image in
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
                                Text("\(initials)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .multilineTextAlignment(.center)
                            }
                    }
                }

            VStack(alignment: .leading) {
                Text("\(firstName) \(lastInitial)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                Text("@\(user.username)")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color.gray)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}


#if DEBUG
import SwiftUI

private let mockUser = User(
    id: "mock_user_id",
    username: "mockuser",
    email: "mockuser@email.com",
    displayName: "Mock User",
    profileImage: "pic1",
    creationDate: Date().timeIntervalSince1970
)

private let mockFriend1 = User(
    id: "friend_1_id",
    username: "alice",
    email: "alice@email.com",
    displayName: "Alice Johnson",
    profileImage: "pic2",
    creationDate: Date().timeIntervalSince1970
)

private let mockFriend2 = User(
    id: "friend_2_id",
    username: "bob",
    email: "bob@email.com",
    displayName: "Bob Smith",
    profileImage: "pic3",
    creationDate: Date().timeIntervalSince1970
)

private let mockFriend3 = User(
    id: "friend_3_id",
    username: "carla",
    email: "carla@email.com",
    displayName: "Carla Rivera",
    profileImage: "pic4",
    creationDate: Date().timeIntervalSince1970
)

private let mockFriend4 = User(
    id: "friend_4_id",
    username: "david",
    email: "david@email.com",
    displayName: "David Lee",
    profileImage: "pic5",
    creationDate: Date().timeIntervalSince1970
)

private let mockFriend5 = User(
    id: "friend_5_id",
    username: "emily",
    email: "emily@email.com",
    displayName: "Emily Clark",
    profileImage: "pic6",
    creationDate: Date().timeIntervalSince1970
)

private let mockEvent = Event(
    id: "mock_event_id",
    userId: mockUser.id,
    scheduleId: "mock_schedule_id",
    title: "Digital Systems Lecture Summer 1 2025",
    startDate: Date().timeIntervalSince1970,
    startTime: 9 * 3600, // 9:00 AM in seconds
    endTime: 10 * 3600, // 10:00 AM in seconds
    creationDate: Date().timeIntervalSince1970,
    locationName: "Gold's Gym",
    locationAddress: "7301 Burnet Rd Ste 300A Austin, TX 78757 United States",
    latitude: 37.7749,
    longitude: -122.4194,
    taggedUsers: [mockFriend1.id, mockFriend2.id, mockFriend3.id, mockFriend4.id, mockFriend5.id],
    color: "7C6181",
    notes: "Print out the chapter slides before class"
)

private let mockRecurringEvent = RecurringEvents(
    date: Date().timeIntervalSince1970,
    event: mockEvent
)

struct EventDetailsView_Previews: PreviewProvider {
    @State static var shouldReloadData = false
    static var previews: some View {
        EventDetailsView(event: mockRecurringEvent, currentUser: mockUser, shouldReloadData: $shouldReloadData)
    }
}
#endif
