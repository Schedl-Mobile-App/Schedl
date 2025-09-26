//
//  Untitled.swift
//  Schedl
//
//  Created by David Medina on 7/21/25.
//

import SwiftUI

struct EventDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm: EventViewModel
    
    var body: some View {
        if let event = vm.event {
            ZStack {
                Color(hex: Int(event.event.color, radix: 16)!)
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 65)
                    VStack(alignment: .leading, spacing: 0) {
                        
                        EventDetails_TitleView(vm: vm, userCanEdit: vm.userCanEdit, eventColor: event.event.color, title: event.event.title)
                        
                        EventDetails_NotesView(notes: event.event.notes)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 30) {
                                EventDetails_DateView(eventDate: event.date)
                                
                                EventDetails_TimeView(startTime: event.event.startTime, endTime: event.event.endTime)
                                
                                EventDetails_LocationView(location: event.event.location, eventColor: event.event.color)
                                
                                EventDetails_InvitedUsersView(currentUser: vm.currentUser, invitedUsers: vm.selectedFriends, eventColor: event.event.color)
                            }
                            .padding(.top)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .defaultScrollAnchor(.top, for: .initialOffset)
                        .defaultScrollAnchor(.bottom, for: .sizeChanges)
                    }
                    .padding(.horizontal)
                    .background {
                        Image("customBackground")
                            .resizable()
                            .scaledToFill()
                            .containerRelativeFrame(.vertical) { height, axis in
                                return height + 225
                            }
                            .containerRelativeFrame(.horizontal) { width, axis in
                                return width
                            }
                            .padding(.top, 200)
                            .ignoresSafeArea(edges: .bottom)
                    }
                }
            }
        }
    }
}

struct FullEventDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm: EventViewModel
        
    init(recurringEvent: RecurringEvents, currentUser: User, currentScheduleId: String) {
        _vm = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, event: recurringEvent, currentScheduleId: currentScheduleId))
    }
    
    var body: some View {
        EventDetailsView(vm: vm)
            .task {
                await vm.fetchEventData()
            }
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event Details")
                        .foregroundStyle(Color("PrimaryText"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                }
            }
    }
}

//struct PreviewEventDetailsView: View {
//    
//    @Environment(\.dismiss) var dismiss
//    
//    @StateObject private var vm: EventViewModel
//    
//    init(eventId: String, currentUser: User, currentScheduleId: String) {
//        _vm = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, event: recurringEvent, currentScheduleId: currentScheduleId))
//    }
//    
//    var body: some View {
//        EventDetailsView(vm: vm)
//            .navigationBarBackButtonHidden(false)
//            .task {
//                await vm.fetchEventData()
//            }
//            .onChange(of: vm.shouldDismissToRoot) {
//                dismiss()
//            }
//            .navigationDestination(for: EventDetailsDestinations.self, destination: { destination in
//                switch destination {
//                case .profileView(let user):
//                    ProfileView(currentUser: vm.currentUser, profileUser: user, preferBackButton: true)
//                case .editEventView:
//                    EditEventView(vm: vm)
//                }
//            })
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button(action: {
//                        
//                    }, label: {
//                        Label("Accept", systemImage: "checkmark")
//                    })
//                }
//                
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        
//                    }, label: {
//                        Label("Decline", systemImage: "xmark")
//                    })
//                }
//            }
//    }
//}

struct EventDetails_TitleView: View {
    
    @Environment(\.router) var coordinator: Router
    @ObservedObject var vm: EventViewModel
    
    var userCanEdit: Bool
    var eventColor: String
    var title: String
    
    func stringToColor(_ color: String) -> Color {
        if let hexColor = Int(color, radix: 16) {
            return Color(hex: hexColor)
        }
        
        return .red
    }
        
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.title2)
                .fontWeight(.semibold)
                .fontDesign(.monospaced)
                .foregroundStyle(Color("PrimaryText"))
                .tracking(-0.25)
                .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.65, alignment: .leading)
                .padding(.top)
            
            Button(action: {
                coordinator.push(page: .editEvent(vm: vm))
            }, label: {
                Circle()
                    .fill(stringToColor(eventColor).opacity(0.5))
                    .frame(width: 60, height: 60)
                    .overlay {
                        if userCanEdit {
                            Image("pencilIcon")
                                .resizable()
                                .frame(width: 25, height: 25)
                        } else {
                            Image("eyeIcon")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                    }
            })
            .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.875, alignment: .trailing)
            .disabled(!userCanEdit)
        }
    }
}

struct EventDetails_NotesView: View {
    
    var notes: String
    
    var body: some View {
        if notes.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                Text("\(notes)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color("PrimaryText"))
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("SecondaryText"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("SecondaryText"))
                .frame(maxWidth: .infinity)
                .frame(height: 0.75)
        }
    }
}

struct EventDetails_DateView: View {
    
    var eventDate: Double
    
    var formattedDate: String {
        let eventDate = Date(timeIntervalSince1970: eventDate)
        return eventDate.formatted(date: .complete, time: .omitted)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Event Date")
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(Color("PrimaryText"))
            
            HStack(alignment: .center) {
                Image(systemName: "calendar")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color("IconColors"))
                Text("\(formattedDate)")
                    .monospacedDigit()
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
            }
        }
    }
}

struct EventDetails_TimeView: View {
    
    var startTime: Double
    var endTime: Double
    
    func returnTimeFormatted(_ time: Double) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = startOfDay.addingTimeInterval(time)
        return date.formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time")
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(Color("PrimaryText"))
            
            HStack(alignment: .center) {
                Image(systemName: "clock")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color("IconColors"))
                let formattedStartTime = returnTimeFormatted(startTime)
                let formattedEndTime = returnTimeFormatted(endTime)
                Text("\(formattedStartTime) → \(formattedEndTime)")
                    .monospacedDigit()
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .tracking(-0.25)
                    .foregroundStyle(Color("SecondaryText"))
            }
        }
    }
}

struct EventDetails_LocationView: View {
    
    var location: MTPlacemark
    var eventColor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(Color("PrimaryText"))
            
            HStack(alignment: .top) {
                Image(systemName: "mappin")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color("SecondaryText"))
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(location.name)")
                            .monospacedDigit()
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .tracking(-0.25)
                            .foregroundStyle(Color("SecondaryText"))
                        Text("\(location.address)")
                            .monospacedDigit()
                            .font(.footnote)
                            .fontWeight(.bold)
                            .tracking(-0.25)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Button(action: {
                    }) {
                        HStack {
                            Text("More Details →")
                        }
                        .font(.footnote)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color(hex: Int(eventColor, radix: 16)!))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
    }
}

struct EventDetails_InvitedUsersView: View {
    
    @Environment(\.router) var coordinator: Router
    
    let currentUser: User
    
    var invitedUsers: [User]
    var eventColor: String
    @State var initialVisibleCount = 2
    @State var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("Invited Users")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(Color("PrimaryText"))
                Spacer()
                Text("(\(invitedUsers.count))")
                    .font(.headline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .tracking(1.2)
                    .foregroundStyle(Color("SecondaryText"))
            }
            
            if !invitedUsers.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(invitedUsers.enumerated()), id: \.element.id) { index, user in
                        if isExpanded || index < initialVisibleCount {
                            Button(action: {
                                coordinator.push(page: .profile(currentUser: currentUser, profileUser: user, preferBackButton: true))
                            }, label: {
                                InvitedUserRow(user: user)
                            })
                        }
                    }
                    
                    if invitedUsers.count > initialVisibleCount {
                        Button(action: {
                            withAnimation(.smooth(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text(isExpanded ? "Show Less" : "Show \(invitedUsers.count - initialVisibleCount) More")
                                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                    .imageScale(.medium)
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: Int(eventColor, radix: 16)!))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.top, 5)
                    }
                }
                
                
            } else {
                Text("No users have been invited to this event.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.secondary)
                    .padding(.vertical, 10)
            }
        }
    }
}

enum EventDetailsDestinations: Hashable {
    case profileView(User)
    case editEventView(vm: EventViewModel)
}

import Kingfisher

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
    
    @State private var imageLoadingError = false

    var body: some View {
        HStack(spacing: 15) {
            
            if !imageLoadingError {
                KFImage.url(URL(string: user.profileImage))
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
            } else {
                Circle()
                    .strokeBorder(Color("ButtonColors"), lineWidth: 1.75)
                    .background(Color.clear)
                    .frame(width: 55.75, height: 55.75)
                    .overlay {
                        // Show while loading or if image fails to load
                        Circle()
                            .fill(Color("SectionalColors"))
                            .frame(width: 54, height: 54)
                            .overlay {
                                Text("\(user.displayName.first?.uppercased() ?? "J")\(user.displayName.last?.uppercased() ?? "D")")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color("PrimaryText"))
                                    .multilineTextAlignment(.center)
                            }
                    }
            }

            VStack(alignment: .leading) {
                Text("\(firstName) \(lastInitial)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                Text("@\(user.username)")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("SecondaryText"))
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
