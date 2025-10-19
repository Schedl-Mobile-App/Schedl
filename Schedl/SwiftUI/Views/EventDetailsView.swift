//
//  Untitled.swift
//  Schedl
//
//  Created by David Medina on 7/21/25.
//

import SwiftUI
import Kingfisher

struct EventDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var showEyeSlash = false
    @State private var navigateToUser: User?
    @State private var navigateToEditEvent: Bool = false
    
    @ObservedObject var vm: EventViewModel
    
    func getMonthDate(for date: Date) -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let month = dateComponents.month, let day = dateComponents.day else { return "" }
        
        let monthName = calendar.monthSymbols[month-1]
        return "\(monthName) \(day)"
    }
    
    func getWeekday(for date: Date) -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        
        guard let weekday = dateComponents.weekday else { return "" }
        let weekdayName = calendar.weekdaySymbols[weekday-1]
        
        return "\(weekdayName)"
    }
    
    var body: some View {
        if let event = vm.event {
            ZStack {
                Color(hex: Int(event.event.color, radix: 16)!)
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(getMonthDate(for: event.event.startDate))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color(hex: Int(event.event.color, radix: 16)!))
                                
                                Text(getWeekday(for: event.event.startDate))
                                    .font(.largeTitle)
                                    .fontWeight(.regular)
                                    .lineLimit(1)
                                    .tracking(1.75)
                                    .foregroundStyle(Color(hex: Int(event.event.color, radix: 16)!))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "birthday.cake")
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundStyle(Color(hex: Int(event.event.color, radix: 16)!))
                        }
                        .padding()
                        .padding(.horizontal, 10)
                        
                        ZStack(alignment: .topLeading) {
                            GeometryReader { geo in
                                CustomRoundedRectangle(cornerRadius: 35)
                                    .fill(Color("BackgroundColor"))
                                    .frame(height: 1200)
                            }
                        
                            
                            VStack(alignment: .leading, spacing: 25) {
                                
                                VStack(alignment: .leading, spacing: 30) {
                                    EventDetails_TitleView(navigateToEditEvent: $navigateToEditEvent, showEyeSlash: $showEyeSlash, userCanEdit: vm.userCanEdit, eventColor: event.event.color, title: event.event.title)
                                    
                                    EventDetails_NotesView(notes: event.event.notes)
                                }
                                
                                EventDetails_ScheduleNameView()
                                
                                EventDetails_TimeView(startTime: event.event.startTime, endTime: event.event.endTime)
                                
                                EventDetails_LocationView(location: event.event.location, eventColor: event.event.color)
                                
                                EventDetails_InvitedUsersView(vm: vm, showEyeSlash: $showEyeSlash, navigateToEditEvent: $navigateToEditEvent, navigateToUser: $navigateToUser)
                            }
                            .padding()
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
//                .onScrollGeometryChange(for: Bool.self, of: { geometry in
//                    geometry.contentOffset.y > 0
//                }, action: { oldValue, newValue in
//                    self.barHidden = !newValue  // Set based on whether scrolled past threshold
//                })
            }
            .navigationDestination(item: $navigateToUser, destination: { user in
                ProfileView(currentUser: vm.currentUser, profileUser: user, preferBackButton: true)
            })
            .navigationDestination(isPresented: $navigateToEditEvent, destination: {
                EditEventView(vm: vm)
            })
        }
    }
}

struct FullEventDetailsView: View {
    
    @Environment(\.tabBar) var tabBar
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: EventViewModel
        
    init(event: EventOccurrence, currentUser: User) {
        _vm = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, event: event))
    }
    
    var body: some View {
        EventDetailsView(vm: vm)
            .task {
                await vm.fetchEventData()
            }
            .toolbar(tabBar.isTabBarHidden ? .hidden : .visible, for: .tabBar)
            .onAppear {
                tabBar.isTabBarHidden = true
            }
    }
}

#Preview {
    // Mock current user
    let mockUser = User(
        id: "user_preview_1",
        email: "jane@example.com",
        displayName: "David Medina",
        username: "djay0628",
        profileImage: "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FEklrnJ8NRuVjWl8vpoAiJUwyNsk1%2FprofileImages%2Fprofile_87907532-2551-479F-8153-24B8092D2504.jpg?alt=media&token=000e42ff-e566-4964-a424-016f81da818e",
        numOfEvents: 12,
        numOfFriends: 5,
        numOfPosts: 3
    )
    
    let mockUser2 = User(
        id: "user_preview_2",
        email: "jane@example.com",
        displayName: "Gerimeel Rivas",
        username: "geriwax",
        profileImage:
            "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FUNbmCWPIRFM8c9tmNz2gBNlNHGz1%2FprofileImages%2Fprofile_81EDEAE0-5EA9-4195-ABE1-76D168C25222.jpg?alt=media&token=df052ad0-5a78-4c57-9120-fc05284914ea",
        numOfEvents: 12,
        numOfFriends: 5,
        numOfPosts: 3
    )

    // Times and dates
    let startOfDay = Calendar.current.startOfDay(for: Date())
    let mockStartTime: Int = 9 * 60   // 9:00 AM
    let mockEndTime: Int = 11 * 60    // 11:00 AM
    
    let location = MTPlacemark(name: "Cafe Luna", address: "123 Main St, Austin, TX", latitude: 30.2672, longitude: -97.7431)
    
    let invitedUsers = [InvitedUser(userId: "user_preview_2", status: "pending"), InvitedUser(userId: "user_preview_1", status: "accepted")]

    // Mock event (empty invitedUsers to avoid any data fetch during previews)
    let mockEvent = Event(
        id: "evt_preview_1",
        ownerId: mockUser.id,
        title: "CodePath Meeting iOS102",
        startDate: startOfDay,
        startTime: mockStartTime,
        endTime: mockEndTime,
        location: location,
        color: "3C859E",
        invitedUsers: invitedUsers
    )

    // Wrap in RecurringEvents for the details view
    let mockEventOccurence = EventOccurrence(recurringDate: startOfDay, event: mockEvent)
    
    var eventView: any View {
        NavigationStack {
            FullEventDetailsView(
                event: mockEventOccurence,
                currentUser: mockUser,
            )
        }
    }
    
    eventView
}

struct EventDetails_TitleView: View {
    
//    @Environment(\.router) var coordinator: Router
    
    @Binding var navigateToEditEvent: Bool
    @Binding var showEyeSlash: Bool
    
    var userCanEdit: Bool
    var eventColor: String
    var title: String
    
    func stringToColor(_ color: String) -> Color {
        if let hexColor = Int(color, radix: 16) {
            return Color(hex: hexColor).opacity(0.5)
        }
        return .red
    }
        
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(3)
                    .foregroundStyle(Color("PrimaryText"))
                    .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.625, alignment: .leading)
                    
                Text("Created by: David Medina")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if #available(iOS 26.0, *) {
                Button(action: {
                    if userCanEdit {
                        navigateToEditEvent = true
                    } else {
                        withAnimation {
                            showEyeSlash = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            showEyeSlash = false
                        })
                    }
                }, label: {
                    Image(systemName: showEyeSlash ? "eye.slash" : "pencil")
                        .foregroundStyle(.white)
                        .contentTransition(.symbolEffect(.replace))
                        .font(.system(size: 32))
                        .frame(width: 38, height: 38)
                        .padding()
                })
                .glassEffect(.regular.tint(stringToColor(eventColor)).interactive(), in: .circle)
                .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.8625, alignment: .trailing)
                .offset(y: -15)
            } else {
                Button(action: {
                    if userCanEdit {
                        navigateToEditEvent = true
                    } else {
                        withAnimation {
                            showEyeSlash = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            showEyeSlash = false
                        })
                    }
                }, label: {
                    Image(systemName: showEyeSlash ? "eye.slash" : "pencil")
                        .foregroundStyle(.white)
                        .contentTransition(.symbolEffect(.replace))
                        .font(.system(size: 32))
                        .frame(width: 38, height: 38)
                        .padding()
                })
                .buttonStyle(.plain)
                .background(stringToColor(eventColor), in: .circle)
                .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.8625, alignment: .trailing)
                .offset(y: -15)
            }
        }
    }
}

struct EventDetails_NotesView: View {
    
    var notes: String?
    
    var body: some View {
        if let notes, notes.isEmpty == false {
            VStack(alignment: .leading, spacing: 15) {
                Text("Meeting will start \(10) minutes before, so get there early!")
                    .font(.headline)
                    .fontWeight(.semibold)
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

struct EventDetails_ScheduleNameView: View {
    
    var scheduleName: String = "David's Schedule"
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            if #available(iOS 26.0, *) {
                Image(systemName: "calendar.badge")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.green)
                    .imageScale(.large)
            } else {
                Image(systemName: "calendar")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.green)
                    .imageScale(.large)
            }
            
            Text(scheduleName)
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color("PrimaryText"))
        }
    }
}

struct EventDetails_ColorView: View {
    
    let color: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: "circle.fill")
                .foregroundStyle(Color(hex: Int(color, radix: 16)!))
                .imageScale(.large)
            
            Text("Color")
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color("PrimaryText"))
        }
    }
}

struct EventDetails_TimeView: View {
    
    var startTime: Int
    var endTime: Int
    
    func returnTimeFormatted(_ time: Int) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let date = Calendar.current.date(byAdding: .hour, value: time, to: startOfDay)
        
        if let date {
            return date.formatted(date: .omitted, time: .shortened)
        }
        
        return "3:13AM"
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: "clock.badge")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.orange)
                .imageScale(.large)
            let formattedStartTime = returnTimeFormatted(startTime)
            let formattedEndTime = returnTimeFormatted(endTime)
            HStack(spacing: 10) {
                Text(formattedStartTime)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .tracking(1)
                    .foregroundStyle(Color("PrimaryText"))
                Image(systemName: "arrow.forward")
                    .imageScale(.small)
                    .foregroundStyle(.orange)
                Text(formattedEndTime)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .tracking(1)
                    .foregroundStyle(Color("PrimaryText"))
            }
        }
    }
}

struct EventDetails_LocationView: View {
    
    @Environment(\.router) var coordinator: Router
    var location: MTPlacemark
    var eventColor: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: "mappin.and.ellipse")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.red)
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(location.name)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .tracking(1)
                        .foregroundStyle(Color("PrimaryText"))
                    Text("\(location.address)")
                        .monospacedDigit()
                        .font(.footnote)
                        .fontWeight(.bold)
                        .tracking(1)
                        .lineLimit(2)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    coordinator.push(page: .locationView(placemark: location))
                }, label: {
                    HStack {
                        Image(systemName: "location")
                            .symbolRenderingMode(.hierarchical)
                            .imageScale(.medium)
                            .foregroundStyle(.red)
                        Text("More Details")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.red)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

struct EventDetails_InvitedUsersView: View {
    
    
    @ObservedObject var vm: EventViewModel
    @Binding var showEyeSlash: Bool
    @Binding var navigateToEditEvent: Bool
    @Binding var navigateToUser: User?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Image(systemName: "person.2")
                    .foregroundStyle(.blue)
                Text("Invited Users")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .tracking(1.25)
                    .textCase(.uppercase)
                    .foregroundStyle(Color("PrimaryText"))
            }
            
            if !vm.selectedFriends.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(vm.selectedFriends, id: \.id) { user in
                        Button(action: {
                            navigateToUser = user
                        }, label: {
                            HStack(spacing: 20) {
                                PostProfileImage(profileImage: user.profileImage, displayName: user.displayName)
                                
                                VStack(alignment: .leading) {
                                    Text(user.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(Color("PrimaryText"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("@\(user.username)")
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.gray)
                                        .tracking(1.05)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        })
                    }
                }
            } else {
                Text("No users have been invited to this event yet.")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                
            Button(action: {
                if vm.userCanEdit {
                    navigateToEditEvent = true
                } else {
                    withAnimation {
                        showEyeSlash = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        showEyeSlash = false
                    })
                }
            }, label: {
                HStack {
                    Image(systemName: "plus.circle")
                        .symbolRenderingMode(.hierarchical)
                        .imageScale(.medium)
                        .foregroundStyle(.blue)
                    Text("Invite Friends")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.blue)
                    
                }
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
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

struct EventDetails_ScheduleTitleView: View {
    
    @Environment(\.router) var coordinator: Router
    var location: MTPlacemark
    var eventColor: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "calendar.badge")
                .foregroundStyle(.red)
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(location.name)")
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .tracking(1)
                        .foregroundStyle(Color("PrimaryText"))
                    Text("\(location.address)")
                        .monospacedDigit()
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.secondary)
                }
                
                Button(action: {
                    coordinator.push(page: .locationView(placemark: location))
                }) {
                    HStack {
                        Text("More Details →")
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.red)
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

struct CustomRoundedRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY

        // Ensure corner radius doesn't exceed half of the shortest side
        let effectiveCornerRadius = min(cornerRadius, rect.width / 2, rect.height / 2)
        
        // Define how much to pull back from the right edge
        let rightEdgeInset: CGFloat = 120

        // Start at the top-left corner after the curve
        path.move(to: CGPoint(x: minX + effectiveCornerRadius, y: minY))

        // Top edge (shortened by rightEdgeInset)
        path.addLine(to: CGPoint(x: maxX - effectiveCornerRadius - rightEdgeInset, y: minY))
        // Top-right corner arc
        path.addArc(center: CGPoint(x: maxX - effectiveCornerRadius - rightEdgeInset, y: minY + effectiveCornerRadius),
                    radius: effectiveCornerRadius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        // Go down slightly
        path.addLine(to: CGPoint(x: maxX - rightEdgeInset, y: minY + 10))

        // Add inverted (outward-opening) rounded corner
        path.addArc(center: CGPoint(x: maxX - rightEdgeInset + effectiveCornerRadius, y: minY + 10 + effectiveCornerRadius),
                    radius: effectiveCornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 90),
                    clockwise: true)

        // Continue to the right
        let rightExtension = maxX - effectiveCornerRadius
        path.addLine(to: CGPoint(x: rightExtension, y: minY + 45 + effectiveCornerRadius))

        // Add normal (inward-opening) rounded corner at the right edge
        path.addArc(center: CGPoint(x: rightExtension, y: minY + 45 + effectiveCornerRadius * 2),
                    radius: effectiveCornerRadius,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)

        // Continue downward
        path.addLine(to: CGPoint(x: rightExtension + effectiveCornerRadius, y: maxY))
        
        // Bottom-right corner arc
        path.addArc(center: CGPoint(x: rightExtension, y: maxY - effectiveCornerRadius),
                    radius: effectiveCornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)

        // Bottom edge
        path.addLine(to: CGPoint(x: minX + effectiveCornerRadius, y: maxY))
        // Bottom-left corner arc
        path.addArc(center: CGPoint(x: minX + effectiveCornerRadius, y: maxY - effectiveCornerRadius),
                    radius: effectiveCornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)

        // Left edge
        path.addLine(to: CGPoint(x: minX, y: minY + effectiveCornerRadius))
        // Top-left corner arc
        path.addArc(center: CGPoint(x: minX + effectiveCornerRadius, y: minY + effectiveCornerRadius),
                    radius: effectiveCornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)

        path.closeSubpath()

        return path
    }
}
