//
//  EditEventView.swift
//  Schedl
//
//  Created by David Medina on 7/19/25.
//

import SwiftUI

struct EditEventView: View {
    
    @Environment(\.router) var coordinator: Router
    @ObservedObject var vm: EventViewModel
        
    @FocusState var isFocused: EventInfoFields?
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 10) {
                    
                    VStack(spacing: 0) {
                        // view for event title input
                        EventTitleView(title: $vm.title, isFocused: $isFocused, hasTriedSubmitting: $vm.hasTriedSubmitting, titleError: $vm.titleError)
                        
                        // view for event date and recurring days seletion
                        EventDateView(eventDate: $vm.startDate, recurrence: $vm.recurrence, hasTriedSubmitting: vm.hasTriedSubmitting, startDateError: vm.startDateError, recurrenceError: vm.recurrenceError)
                        
                        // view for start time selection
                        EventStartTimeView(startTime: $vm.startTime, hasTriedSubmitting: vm.hasTriedSubmitting, startTimeError: vm.startTimeError)
                        
                        // view for end time selection
                        EventEndTimeView(endTime: $vm.endTime, endTimeError: vm.endTimeError, hasTriedSubmitting: vm.hasTriedSubmitting)
                        
                        // view for location selection
                        EventLocationView(selectedPlacemark: $vm.selectedPlacemark, locationError: vm.locationError, hasTriedSubmitting: vm.hasTriedSubmitting)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $vm.selectedFriends, currentUser: vm.currentUser)
                        
                        // view for event notes input
                        EventNotesView(notes: $vm.notes, notesError: vm.notesError, hasTriedSubmitting: vm.hasTriedSubmitting, isFocused: $isFocused)
                        
                        EventColorView(eventColor: $vm.eventColor)
                    }
                    
                    VStack(spacing: 6) {
                        Text(vm.submitError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .opacity(vm.hasTriedSubmitting && !vm.submitError.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: vm.hasTriedSubmitting)
                        
                        Button(action: {
                            if !vm.checkValidInputs() { return }
                            if vm.shouldShowEditRecurringModal {
                                vm.showSaveChangesModal = true
                            } else {
                                Task {
                                    await vm.updateEvent()
                                }
                            }
                        }, label: {
                            Text("Save Changes")
                                .foregroundColor(Color.white)
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("ButtonColors"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical)
                .padding(.horizontal, 25)
                .simultaneousGesture(TapGesture().onEnded {
                    if vm.hasTriedSubmitting {
                        vm.hasTriedSubmitting = false
                        vm.resetErrors()
                    }
                })
            }
            .defaultScrollAnchor(.top, for: .initialOffset)
            .scrollDismissesKeyboard(.interactively)
        }
        .alert(isPresented: $vm.showDeleteEventModal) {
            Alert(title: Text("Delete Event"),
                  message: Text("If you delete this event, you and other invited users will no longer be able to see it. This cannot be undone."),
                  primaryButton: .cancel(Text("Cancel"), action: {
                vm.showDeleteEventModal = false
            }), secondaryButton: .destructive(Text("Delete").foregroundStyle(Color("ErrorTextColor")), action: {
                Task {
                    await vm.deleteEvent()
                    coordinator.pop(2)
                }
            }))
        }
        .onAppear {
            vm.setInitialValues()
        }
        .onDisappear {
            vm.resetErrors()
        }
        .navigationBarBackButtonHidden(false)
        .modifier(EditEventViewModifier(showDeleteEventModal: $vm.showDeleteEventModal))
    }
}

struct EditEventViewModifier: ViewModifier {
    
    @Binding var showDeleteEventModal: Bool
    
    func body(content: Content) -> some View {
        content
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showDeleteEventModal = true
                    }, label: {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .bold))
                            .labelStyle(.iconOnly)
                    })
                }
            }
    }
}
