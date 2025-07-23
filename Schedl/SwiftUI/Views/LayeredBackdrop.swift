//
//  Untitled.swift
//  Schedl
//
//  Created by David Medina on 7/21/25.
//

import SwiftUI

//extension UIColor {
//
//    func modified(withAdditionalHue hue: CGFloat, additionalSaturation: CGFloat, additionalBrightness: CGFloat) -> UIColor {
//
//        var currentHue: CGFloat = 0.0
//        var currentSaturation: CGFloat = 0.0
//        var currentBrigthness: CGFloat = 0.0
//        var currentAlpha: CGFloat = 0.0
//
//        if self.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha){
//            return UIColor(hue: currentHue + hue,
//                           saturation: currentSaturation + additionalSaturation,
//                           brightness: currentBrigthness + additionalBrightness,
//                           alpha: currentAlpha)
//        } else {
//            return self
//        }
//    }
//}

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}


extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

struct EventDetailsView: View {
    @StateObject private var eventViewModel: EventViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var hideTabbar = true
    @State var showMapSheet: Bool = false
    @State private var isExpanded = false
    let initialVisibleCount = 2
    @Binding var shouldReloadData: Bool
    
    
    private var formattedDate: String {
        guard let event = eventViewModel.selectedEvent?.event else { return "Date unavailable" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date(timeIntervalSince1970: event.startDate))
    }
    
    private func returnTimeFormatted() -> String {
        guard let event = eventViewModel.selectedEvent?.event else { return "Time unavailable" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date.convertHourAndMinuteToDate(time: event.startTime))
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
                
                VStack(spacing: 15) {
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
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .bottom, spacing: 10) {
                            Text("July")
                                .font(.system(size: 46, weight: .semibold))
                                .foregroundStyle(Color(hex: Int(selectedEvent.event.color, radix: 16)!).opacity(0.5))
                            Text("22")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(Color(hex: Int(selectedEvent.event.color, radix: 16)!).opacity(0.5))
                        }
                        Text("Tuesday")
                            .font(.system(size: 40, weight: .medium, design: .monospaced))
                            .tracking(-0.25)
                            .foregroundStyle(Color(hex: Int(selectedEvent.event.color, radix: 16)!).opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // card component for the event details
                ZStack(alignment: .topLeading) {
                    Image("customBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: UIScreen.current?.bounds.width ?? .infinity)
                        .ignoresSafeArea(edges: .bottom)
                    
                    VStack(alignment: .leading, spacing: 40) {
                        
                        HStack(alignment: .top) {
                            Text(selectedEvent.event.title)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                                .frame(maxWidth: (UIScreen.current?.bounds.width ?? .infinity) * 0.65, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            NavigationLink(destination: {
                                EditEventView(eventViewModel: eventViewModel)
                            }) {
                                Circle()
                                    .fill(Color(hex: Int(selectedEvent.event.color, radix: 16)!).opacity(0.5))
                                    .frame(width: 55, height: 55)
                                    .overlay {
                                        if eventViewModel.userCanEdit {
                                            Image("pencilIcon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25)
                                        } else {
                                            Image("eyeIcon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                        }
                                            
                                    }
                            }
                            .padding([.leading], 25)
                            .offset(y: -15)
                            .disabled(!eventViewModel.userCanEdit)
                        }
                        
                        
                        // Creator Name
                        Text("Created by:  \(eventViewModel.eventCreatorName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Date and Time
                        Text(formattedDate)
                            .font(.body)
                        Text(returnTimeFormatted())
                            .font(.body)
                        
                        // Location
                        VStack(alignment: .leading) {
                            Text("Location:")
                                .fontWeight(.semibold)
                            Text(selectedEvent.event.locationName)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .onTapGesture {
                            showMapSheet = true
                        }
                        
//                        // Invited Users
//                        if !selectedEvent.event.taggedUsers.isEmpty {
//                            VStack(alignment: .leading) {
//                                Text("Invited Users:")
//                                    .fontWeight(.semibold)
//                                
//                                let displayedUsers = isExpanded ?  : Array(selectedEvent.event.taggedUsers.prefix(initialVisibleCount))
//                                ForEach(displayedUsers, id: \.self) { user in
//                                    Text(user)
//                                }
//                                
//                                if invitedUsers.count > initialVisibleCount {
//                                    Button(action: {
//                                        isExpanded.toggle()
//                                    }) {
//                                        Text(isExpanded ? "Show Less" : "Show More")
//                                            .font(.footnote)
//                                            .foregroundColor(.blue)
//                                    }
//                                }
//                            }
//                        } else {
//                            Text("No invited users")
//                                .foregroundColor(.secondary)
//                        }
                        
                        // Notes
                        if !selectedEvent.event.notes.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Notes:")
                                    .fontWeight(.semibold)
                                Text(selectedEvent.event.notes)
                                    .font(.body)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal)
                    .offset(y: 60)
                }
                .offset(y: 175)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
//        .task {
//            await eventViewModel.fetchEventData()
//        }
        .onAppear {
            shouldReloadData = false
        }
        .onDisappear {
            shouldReloadData = true
        }
        .toolbar(hideTabbar ? .hidden : .visible, for: .tabBar)
        .toolbarBackground(.white, for: .tabBar)
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
                Text(user.displayName)
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

private let mockEvent = Event(
    id: "mock_event_id",
    userId: mockUser.id,
    scheduleId: "mock_schedule_id",
    title: "Going to the Gym",
    startDate: Date().timeIntervalSince1970,
    startTime: 9 * 3600, // 9:00 AM in seconds
    endTime: 10 * 3600, // 10:00 AM in seconds
    creationDate: Date().timeIntervalSince1970,
    locationName: "Mock Gym",
    locationAddress: "123 Main St",
    latitude: 37.7749,
    longitude: -122.4194,
    taggedUsers: ["Alice", "Bob"],
    color: "7C6181",
    notes: "Bring water and gym shoes."
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
