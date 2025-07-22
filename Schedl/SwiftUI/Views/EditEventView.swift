//
//  EditEventView.swift
//  Schedl
//
//  Created by David Medina on 7/19/25.
//

import SwiftUI

struct EditEventView: View {
    
    @StateObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var shouldReloadData: Bool
        
    @FocusState var isFocused: EventInfoFields?
    
    init(currentUser: User, event: RecurringEvents, shouldReloadData: Binding<Bool>) {
        _eventViewModel = StateObject(wrappedValue: EventViewModel(currentUser: currentUser, selectedEvent: event))
        _shouldReloadData = Binding(projectedValue: shouldReloadData)
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 15) {
                ZStack {
                    Text("Edit Event")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .fontWeight(.bold)
                                .imageScale(.large)
                                .labelStyle(.iconOnly)
                                .foregroundStyle(Color.primary)
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
//                                await eventViewModel.deleteEvent()
                                if eventViewModel.shouldDismiss {
                                    dismiss()
                                }
                            }
                        }, label: {
                            Image(systemName: "trash")
                                .font(.system(size: 26))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: 0x333333))
                        })
                    }
                }
                .padding([.horizontal, .top])
                .frame(maxWidth: .infinity)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 30) {
                        
                        // view for event title input
                        EventTitleView(title: $eventViewModel.title, isFocused: $isFocused, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, titleError: $eventViewModel.titleError)
                        
                        // view for event date and recurring days seletion
                        EventDateView(eventDate: $eventViewModel.eventDate, eventEndDate: $eventViewModel.eventEndDate, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, startDateError: $eventViewModel.startDateError, endDateError: $eventViewModel.endDateError, repeatedDays: $eventViewModel.repeatedDays)
                        
                        // view for start time selection
                        EventStartTimeView(startTime: $eventViewModel.startTime, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, startTimeError: $eventViewModel.startTimeError)
                        
                        // view for end time selection
                        EventEndTimeView(endTime: $eventViewModel.endTime, endTimeError: $eventViewModel.endTimeError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting)
                        
                        // view for location selection
                        EventLocationView(selectedPlacemark: $eventViewModel.selectedPlacemark, locationError: $eventViewModel.locationError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $eventViewModel.selectedFriends, showInviteUsersSheet: $eventViewModel.showInviteUsersSheet)
                            .sheet(isPresented: $eventViewModel.showInviteUsersSheet) {
                                AddInvitedUsers(eventViewModel: eventViewModel)
                            }
                        
                        // view for event notes input
                        EventNotesView(notes: $eventViewModel.notes, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, isFocused: $isFocused)
                        
                        VStack(spacing: 12) {
                            // view for event color selection
                            EventColorView(eventColor: $eventViewModel.eventColor)
                            
                            VStack(spacing: 6) {
                                Text(eventViewModel.submitError)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .opacity(eventViewModel.hasTriedSubmitting && !eventViewModel.submitError.isEmpty ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: eventViewModel.hasTriedSubmitting)
                                
                                Button(action: {
                                    Task {
                                        await eventViewModel.updateEvent()
                                        if eventViewModel.shouldDismiss {
                                            dismiss()
                                        }
                                    }
                                }) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .overlay {
                                            Text("Save Changes")
                                                .foregroundColor(Color(hex: 0xf7f4f2))
                                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                                .tracking(0.1)
                                        }
                                }
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(Color(hex: 0x3C859E))
                            }
                            .padding(.bottom)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical)
                    .padding(.horizontal, 25)
                    .simultaneousGesture(TapGesture().onEnded {
                        if eventViewModel.hasTriedSubmitting {
                            print("In sim gesture")
                            eventViewModel.hasTriedSubmitting = false
                        }
                    })
                }
                .defaultScrollAnchor(.top, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    isFocused = nil
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            shouldReloadData = false
        }
        .onDisappear {
            shouldReloadData = true
        }
    }
}
