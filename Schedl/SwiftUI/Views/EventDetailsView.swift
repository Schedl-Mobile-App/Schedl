////
////  ScheduleEventView.swift
////  calendarTest
////
////  Created by David Medina on 12/16/24.
////
//
//import SwiftUI
//
//struct HelperView: View {
//    @StateObject private var eventViewModel: EventViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State var showMapSheet: Bool = false
//    @State var showTabBar = false
//    @Binding var shouldReloadData: Bool
//    
//    // State for expanding/collapsing the list
//    @State private var isExpanded = false
//    // Number of users to show when collapsed
//    private let initialVisibleCount = 2
//    
//    var formattedDate: String {
//        guard let event = eventViewModel.selectedEvent?.event else { return "" }
//        let eventDate = Date(timeIntervalSince1970: event.startDate)
//        return eventDate.formatted(date: .complete, time: .omitted)
//    }
//    
//    init(event: RecurringEvents, currentUser: User, shouldReloadData: Binding<Bool>) {
//        _eventViewModel = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, selectedEvent: event))
//        _shouldReloadData = Binding(projectedValue: shouldReloadData)
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(hex: 0xf7f4f2)
//                .ignoresSafeArea()
//            if eventViewModel.isLoading {
//                ProgressView()
//            } else if let error = eventViewModel.errorMessage {
//                Text(error)
//            } else if let selectedEvent = eventViewModel.selectedEvent {
//                VStack(spacing: 15) {
//                    ZStack(alignment: .leading) {
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .fontWeight(.bold)
//                                .imageScale(.large)
//                                .labelStyle(.iconOnly)
//                                .foregroundStyle(Color.primary)
//                        }
//                        Text("Event Details")
//                            .foregroundStyle(Color(hex: 0x333333))
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .fontDesign(.monospaced)
//                            .tracking(-0.25)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                        NavigationLink(destination: EditEventView(currentUser: eventViewModel.currentUser, event: selectedEvent, shouldReloadData: $shouldReloadData)) {
//                            
//                            Text("Edit")
//                                .foregroundStyle(Color(hex: 0x333333))
//                                .font(.headline)
//                                .fontWeight(.bold)
//                                .fontDesign(.monospaced)
//                                .tracking(0.1)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                    }
//                    .padding([.horizontal, .top])
//                    
//                    ScrollView(.vertical, showsIndicators: false) {
//                        VStack(alignment: .leading, spacing: 30) {
//                            
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Title")
//                                    .font(.headline)
//                                    .fontWeight(.bold)
//                                    .fontDesign(.monospaced)
//                                    .tracking(0.1)
//                                    .foregroundStyle(Color(hex: 0x333333))
//                                HStack(alignment: .top, spacing: 8) {
//                                    Image(systemName: "star")
//                                        .imageScale(.medium)
//                                        .fontWeight(.bold)
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text("\(selectedEvent.event.title)")
//                                            .font(.headline)
//                                            .fontWeight(.bold)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color(hex: 0x333333))
//                                        Text("Created By: \(eventViewModel.eventCreatorName)")
//                                            .font(.footnote)
//                                            .fontWeight(.medium)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color.gray)
//                                    }
//                                }
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white)
//                                    .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
//                            }
//                            .padding(.top)
//                            
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Date and Time")
//                                    .font(.headline)
//                                    .fontWeight(.bold)
//                                    .fontDesign(.monospaced)
//                                    .tracking(0.1)
//                                    .foregroundStyle(Color(hex: 0x333333))
//                                HStack(alignment: .top, spacing: 8) {
//                                    Image(systemName: "calendar")
//                                        .imageScale(.medium)
//                                        .fontWeight(.bold)
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        let formattedStartTime = returnTimeFormatted(timeObj: selectedEvent.event.startTime)
//                                        let formattedEndTime = returnTimeFormatted(timeObj: selectedEvent.event.endTime)
//                                        Text("\(formattedDate)")
//                                            .font(.headline)
//                                            .fontWeight(.bold)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color(hex: 0x333333))
//                                        Text("\(formattedStartTime) → \(formattedEndTime)")
//                                            .font(.footnote)
//                                            .fontWeight(.medium)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color.gray)
//                                    }
//                                }
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white)
//                                    .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
//                            }
//                            
//                            VStack(alignment: .leading, spacing: 12) {
//                                Text("Location")
//                                    .font(.headline)
//                                    .fontWeight(.bold)
//                                    .fontDesign(.monospaced)
//                                    .tracking(0.1)
//                                    .foregroundStyle(Color(hex: 0x333333))
//                                
//                                HStack(alignment: .top, spacing: 8) {
//                                    Image(systemName: "mappin")
//                                        .imageScale(.medium)
//                                        .fontWeight(.bold)
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text("\(selectedEvent.event.locationName)")
//                                            .font(.headline)
//                                            .fontWeight(.bold)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color(hex: 0x333333))
//                                        Text("\(selectedEvent.event.locationAddress)")
//                                            .font(.footnote)
//                                            .fontWeight(.bold)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color.gray)
//                                    }
//                                }
//                                
//                                Button(action: {
//                                    showMapSheet.toggle()
//                                }) {
//                                    HStack {
//                                        Text("More Details →")
//                                    }
//                                    .font(.subheadline)
//                                    .fontWeight(.bold)
//                                    .fontDesign(.monospaced)
//                                    .foregroundStyle(Color(hex: 0x3C859E))
//                                    .padding(.top)
//                                    .frame(maxWidth: .infinity, alignment: .trailing)
//                                }
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white)
//                                    .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
//                            }
//                            
//                            VStack(alignment: .leading, spacing: 10) {
//                                HStack {
//                                    Text("Invited Users")
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .fontDesign(.monospaced)
//                                        .tracking(1.15)
//                                        .foregroundStyle(Color(hex: 0x333333))
//                                    Spacer()
//                                    Text("(\(selectedEvent.event.taggedUsers.count))")
//                                        .font(.headline)
//                                        .fontWeight(.medium)
//                                        .fontDesign(.monospaced)
//                                        .tracking(1.15)
//                                        .foregroundStyle(Color(hex: 0x333333))
//                                }
//                                
//                                if !selectedEvent.event.taggedUsers.isEmpty {
//                                    VStack(alignment: .leading, spacing: 0) {
//                                        ForEach(Array(eventViewModel.invitedUsersForEvent.enumerated()), id: \.element.id) { index, user in
//                                            if isExpanded || index < initialVisibleCount {
//                                                InvitedUserRow(user: user)
//                                                    .transition(.asymmetric(
//                                                        insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: -10)),
//                                                        removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .offset(y: 10))
//                                                    ))
//                                                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isExpanded)
//                                            }
//                                        }
//                                    }
//                                    
//                                    if selectedEvent.event.taggedUsers.count > initialVisibleCount {
//                                        Button(action: {
//                                            withAnimation(.easeInOut(duration: 0.3)) {
//                                                isExpanded.toggle()
//                                            }
//                                        }) {
//                                            HStack {
//                                                Text(isExpanded ? "Show Less" : "Show \(selectedEvent.event.taggedUsers.count - initialVisibleCount) More")
//                                                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
//                                                    .imageScale(.medium)
//                                            }
//                                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
//                                            .foregroundStyle(Color(hex: 0x3C859E))
//                                            .padding(.top)
//                                            .frame(maxWidth: .infinity, alignment: .trailing)
//                                        }
//                                    }
//                                } else {
//                                    Text("No users have been invited to this event.")
//                                        .font(.system(size: 14, design: .monospaced))
//                                        .foregroundStyle(Color.gray)
//                                        .padding(.vertical, 10)
//                                }
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white)
//                                    .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
//                            }
//                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
//                            
//                            if selectedEvent.event.notes.isEmpty {
//                                // area for any event notes
//                                VStack(alignment: .leading, spacing: 12) {
//                                    Text("Notes")
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .fontDesign(.monospaced)
//                                        .tracking(0.1)
//                                        .foregroundStyle(Color(hex: 0x333333))
//                                    HStack(alignment: .top, spacing: 8) {
//                                        Image(systemName: "pencil")
//                                            .imageScale(.medium)
//                                            .fontWeight(.bold)
//                                        Text("\(selectedEvent.event.notes)")
//                                            .font(.headline)
//                                            .fontWeight(.bold)
//                                            .fontDesign(.monospaced)
//                                            .tracking(0.1)
//                                            .foregroundStyle(Color(hex: 0x333333))
//                                    }
//                                }
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .fill(Color.white)
//                                        .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
//                                }
//                            }
//                            
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .padding(.horizontal, 25)
//                        .padding(.vertical)
//                    }
//                    .defaultScrollAnchor(isExpanded ? .bottom : .top, for: .sizeChanges)
//                }
//                .padding(.bottom, 0.5)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .fullScreenCover(isPresented: $showMapSheet) {
//                    NavigationView {
//                        SelectedLocationView(desiredPlacemark: MTPlacemark(name: selectedEvent.event.locationName, address: selectedEvent.event.locationAddress, latitude: selectedEvent.event.latitude, longitude: selectedEvent.event.longitude))
//                            .toolbar {
//                                ToolbarItem(placement: .navigationBarTrailing) {
//                                    Button("Done") {
//                                        showMapSheet = false
//                                    }
//                                }
//                            }
//                    }
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .task {
//            await eventViewModel.fetchEventData()
//        }
//        .onAppear {
//            shouldReloadData = false
//        }
//        .onDisappear {
//            shouldReloadData = true
//        }
//    }
//    
//    func returnTimeFormatted(timeObj: Double) -> String {
//        let startOfDay = Calendar.current.startOfDay(for: Date())
//        let date = startOfDay.addingTimeInterval(timeObj)
//        return date.formatted(date: .omitted, time: .shortened)
//    }
//}
//
