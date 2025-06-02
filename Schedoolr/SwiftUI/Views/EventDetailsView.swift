//
//  ScheduleEventView.swift
//  calendarTest
//
//  Created by David Medina on 12/16/24.
//

import SwiftUI

struct EventDetailsView: View {
    @StateObject private var eventViewModel: EventViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showMapSheet: Bool = false
    
    // State for expanding/collapsing the list
    @State private var isExpanded = false
    // Number of users to show when collapsed
    private let initialVisibleCount = 2
    
    var formattedDate: String {
        let eventDate = Date(timeIntervalSince1970: eventViewModel.selectedEvent.eventDate)
        return eventDate.formatted(date: .complete, time: .omitted)
    }
    
    var formattedStartTime: String {
        let eventDate = Date(timeIntervalSince1970: eventViewModel.selectedEvent.eventDate)
        return eventDate.formatted(date: .omitted, time: .shortened)
    }
    
    var formattedEndTime: String {
        let eventDate = Date(timeIntervalSince1970: eventViewModel.selectedEvent.eventDate + eventViewModel.selectedEvent.eventDate)
        return eventDate.formatted(date: .omitted, time: .shortened)
    }
    
    init(event: Event, currentUser: User) {
        _eventViewModel = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, selectedEvent: event))
    }

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack(spacing: 0) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .font(.title3)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Event Details")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(0.1)
                        .fixedSize()
                        .frame(maxWidth: .infinity)
                    Button(action: {
                        print("Now Editing")
                    }) {
                        Text("Edit")
                            .foregroundStyle(Color(hex: 0x333333))
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(0.1)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Title")
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star")
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(eventViewModel.selectedEvent.title)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    Text("Created By: David Medina")
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .tracking(0.1)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Date and Time")
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "calendar")
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                VStack(alignment: .leading, spacing: 4) {
                                    let formattedStartTime = returnTimeFormatted(timeObj: eventViewModel.selectedEvent.startTime)
                                    let formattedEndTime = returnTimeFormatted(timeObj: eventViewModel.selectedEvent.endTime)
                                    Text("\(formattedDate)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    Text("\(formattedStartTime) → \(formattedEndTime)")
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .tracking(0.1)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location")
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(0.1)
                                .foregroundStyle(Color(hex: 0x333333))
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "mappin")
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(eventViewModel.selectedEvent.locationName)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                        .tracking(0.1)
                                        .foregroundStyle(Color(hex: 0x333333))
                                    Text("\(eventViewModel.selectedEvent.locationAddress)")
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
                                .foregroundStyle(Color(hex: 0x3C859E))
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Invited Users")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .tracking(1.15)
                                    .foregroundStyle(Color(hex: 0x333333))
                                Spacer()
                                Text("(\(eventViewModel.selectedEvent.taggedUsers.count))")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)
                                    .tracking(1.15)
                                    .foregroundStyle(Color(hex: 0x333333))
                            }

                            if !eventViewModel.selectedEvent.taggedUsers.isEmpty {
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
                                }

                                if eventViewModel.selectedEvent.taggedUsers.count > initialVisibleCount {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isExpanded.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text(isExpanded ? "Show Less" : "Show \(eventViewModel.selectedEvent.taggedUsers.count - initialVisibleCount) More")
                                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                                .imageScale(.medium)
                                        }
                                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x3C859E))
                                        .padding(.top)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                            } else {
                                Text("No users have been invited to this event.")
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundStyle(Color.gray)
                                    .padding(.vertical, 10)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
                        }
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                        .onAppear {
                            Task {
                                await eventViewModel.fetchInvitedUsers()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .defaultScrollAnchor(isExpanded ? .bottom : .top, for: .sizeChanges)
                .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showMapSheet) {
            NavigationView {
                SelectedLocationView(desiredPlacemark: MTPlacemark(name: eventViewModel.selectedEvent.locationName, address: eventViewModel.selectedEvent.locationAddress, latitude: eventViewModel.selectedEvent.latitude, longitude: eventViewModel.selectedEvent.longitude))
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
    
    func returnTimeFormatted(timeObj: Double) -> String {
        let hours = Int(timeObj / 3600)
        let minutes = (Double(timeObj / 3600.0) - Double(hours)) * 60
        if hours == 0 {
            return "12:\(String(format: "%02d", Int(minutes))) AM"
        } else if hours == 12 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) PM"
        } else if hours < 11 {
            return "\(Int(hours)):\(String(format: "%02d", Int(minutes))) AM"
        } else {
            return "\(Int(hours - 12)):\(String(format: "%02d", Int(minutes))) PM"
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
