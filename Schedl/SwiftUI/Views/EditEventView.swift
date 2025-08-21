//
//  EditEventView.swift
//  Schedl
//
//  Created by David Medina on 7/19/25.
//

import SwiftUI

struct EditEventView: View {
    
    @ObservedObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) var dismiss
        
    @FocusState var isFocused: EventInfoFields?
    
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
                                .fontWeight(.bold)
                                .font(.system(size: 24))
                                .labelStyle(.iconOnly)
                                .foregroundStyle(Color(hex: 0x333333))
                        })
                    }
                }
                .padding([.horizontal, .top])
                .frame(maxWidth: .infinity)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        
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
                        EventNotesView(notes: $eventViewModel.notes, notesError: $eventViewModel.notesError, hasTriedSubmitting: $eventViewModel.hasTriedSubmitting, isFocused: $isFocused)
                        
                        EventColorView(eventColor: $eventViewModel.eventColor)
                        
                        VStack(spacing: 6) {
                            Text(eventViewModel.submitError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .opacity(eventViewModel.hasTriedSubmitting && !eventViewModel.submitError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: eventViewModel.hasTriedSubmitting)
                            
                            Button(action: {
                                if eventViewModel.isRecurringEvent {
                                    eventViewModel.showSaveChangesModal.toggle()
                                } else {
                                    Task {
                                        await eventViewModel.updateEvent()
                                    }
                                }
                            }, label: {
                                Text("Save Changes")
                                    .foregroundColor(Color(hex: 0xf7f4f2))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .tracking(0.1)
                            })
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: 0x3C859E))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.vertical, 8)
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
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isFocused = nil
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ZStack {
                Color(.black.opacity(0.7))
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {}
                
                SaveEditedEventModal(eventViewModel: eventViewModel)
            }
            .zIndex(1)
            .hidden(!eventViewModel.showSaveChangesModal)
            .allowsHitTesting(eventViewModel.showSaveChangesModal)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: eventViewModel.shouldDismiss) {
            dismiss()
        }
    }
}

struct SaveEditedEventModal: View {
    
    @ObservedObject var eventViewModel: EventViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Do you want to save these changes to all future events or just this one?")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
            HStack(alignment: .center, spacing: 15) {
                Button(action: {
                    Task {
                        await eventViewModel.updateRecurringEvent()
                    }
                }) {
                    Text("Single")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.1))
                }
                
                Button(action: {
                    Task {
                        await eventViewModel.updateAllFutureRecurringEvent()
                    }
                }) {
                    Text("All")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: 0xf7f4f2))
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: 0x6d8a96))
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: 0xe0dad5))
        }
        .padding(.horizontal, UIScreen.main.bounds.width * 0.075)
    }
}
