//
//  MockEventDetailsView.swift
//  Schedl
//
//  Created by David Medina on 6/24/25.
//

import SwiftUI

struct MockEventDetailsView: View {
    @State var showMapSheet: Bool = false
    @State private var isExpanded = false
    private let initialVisibleCount = 3
    
    // Hardcoded sample data
    private let eventTitle = "Team Building Workshop"
    private let eventDate = "Friday, June 21, 2024"
    private let startTime = "2:00 PM"
    private let endTime = "5:30 PM"
    private let locationName = "Innovation Hub"
    private let locationAddress = "123 Tech Street, San Francisco, CA 94105"
    private let eventNotes = "Please bring your laptop and a positive attitude! We'll be doing collaborative exercises and team challenges."
    private let attendeeCount = 8
    
    // Sample attendees
    private let sampleAttendees = [
        SampleUser(id: "1", displayName: "David Medina", username: "davidm", profileImage: ""),
        SampleUser(id: "2", displayName: "Sarah Johnson", username: "sarahj", profileImage: ""),
        SampleUser(id: "3", displayName: "Mike Chen", username: "mikec", profileImage: ""),
        SampleUser(id: "4", displayName: "Emily Rodriguez", username: "emilyr", profileImage: ""),
        SampleUser(id: "5", displayName: "Alex Thompson", username: "alext", profileImage: ""),
        SampleUser(id: "6", displayName: "Jessica Park", username: "jessicap", profileImage: ""),
        SampleUser(id: "7", displayName: "Ryan Murphy", username: "ryanm", profileImage: ""),
        SampleUser(id: "8", displayName: "Olivia Davis", username: "oliviad", profileImage: "")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    // Hero Header Section
                    heroHeaderView
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Event Title Card
                        eventTitleCard
                        
                        // Date & Time Card
                        dateTimeCard
                        
                        // Location Card
                        locationCard
                        
                        // Attendees Section
                        attendeesSection
                        
                        // Notes Section
                        notesCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .refreshable {
                // Refresh action
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showMapSheet) {
            // Map sheet content
            VStack {
                Text("Map View")
                    .font(.title)
                    .padding()
                Button("Close") {
                    showMapSheet = false
                }
                .padding()
            }
        }
    }
    
    // MARK: - Hero Header
    @ViewBuilder
    private var heroHeaderView: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                ZStack(alignment: .leading) {
                    Button(action: {

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
                    VStack(alignment: .center, spacing: 30) {
                        Text("Going to the gym")
                            .font(.title2)
                            .fontDesign(.monospaced)
                            .fontWeight(.medium)
                            .tracking(0.1)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                }
            }
        }
    }
    
    // MARK: - Event Title Card
    private var eventTitleCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(hex: 0x3C859E))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Event Details")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x666666))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text("Everything you need to know")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: 0x333333))
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Date & Time Card
    private var dateTimeCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: 0x3C859E))
                
                Text("When")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x333333))
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: 0x666666))
                            .textCase(.uppercase)
                            .tracking(0.3)
                        
                        Text(eventDate)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x1a1a1a))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: 0xf8f8f8))
                )
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: 0x666666))
                            .textCase(.uppercase)
                            .tracking(0.3)
                        
                        Text(startTime)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x1a1a1a))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: 0xf8f8f8))
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: 0x666666))
                            .textCase(.uppercase)
                            .tracking(0.3)
                        
                        Text(endTime)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x1a1a1a))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: 0xf8f8f8))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Location Card
    private var locationCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: 0x3C859E))
                
                Text("Where")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x333333))
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(locationName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x1a1a1a))
                        .lineLimit(2)
                    
                    Text(locationAddress)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: 0x666666))
                        .lineLimit(3)
                }
                
                Spacer()
                
                Button(action: {
                    showMapSheet.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "map")
                            .font(.system(size: 14, weight: .medium))
                        Text("View")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: 0x3C859E))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Attendees Section
    private var attendeesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: 0x3C859E))
                
                Text("Attendees")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x333333))
                
                Spacer()
                
                Text("\(attendeeCount)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color(hex: 0x3C859E))
                    )
            }
            
            VStack(spacing: 8) {
                ForEach(Array(sampleAttendees.enumerated()), id: \.element.id) { index, user in
                    if isExpanded || index < initialVisibleCount {
                        ModernInvitedUserRow(user: user)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.98).combined(with: .opacity).combined(with: .offset(y: -5)),
                                removal: .scale(scale: 0.98).combined(with: .opacity).combined(with: .offset(y: 5))
                            ))
                    }
                }
                
                if sampleAttendees.count > initialVisibleCount {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text(isExpanded ? "Show Less" : "Show \(sampleAttendees.count - initialVisibleCount) More")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color(hex: 0x3C859E))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: 0x3C859E).opacity(0.08))
                        )
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: 0x3C859E))
                
                Text("Notes")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x333333))
                
                Spacer()
            }
            
            HStack {
                Text(eventNotes)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(hex: 0x444444))
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: 0xf8f8f8))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Sample User Model
struct SampleUser: Identifiable {
    let id: String
    let displayName: String
    let username: String
    let profileImage: String
}

// MARK: - Modern Invited User Row
struct ModernInvitedUserRow: View {
    let user: SampleUser

    private var initials: String {
        let nameParts = user.displayName.components(separatedBy: " ")
        let firstInitial = nameParts[0].first?.uppercased() ?? "J"
        let lastInitial = nameParts.count > 1 ? nameParts[1].first?.uppercased() ?? "D" : ""
        let result = firstInitial + lastInitial
        return result.isEmpty ? "?" : result
    }

    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color(hex: 0xe8f4f7))
                    .frame(width: 46, height: 46)
                
                // Since we don't have actual images, show initials
                Text(initials)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x3C859E))
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x1a1a1a))
                
                Text("@\(user.username)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: 0x666666))
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(Color(hex: 0x34c759))
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: 0xfafafa))
        )
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Preview
struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MockEventDetailsView()
    }
}
