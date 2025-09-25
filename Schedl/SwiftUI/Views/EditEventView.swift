//
//  EditEventView.swift
//  Schedl
//
//  Created by David Medina on 7/19/25.
//

import SwiftUI

struct EditEventView: View {
    
    @ObservedObject var vm: EventViewModel
    @Environment(\.dismiss) var dismiss
        
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
                        EventDateView(eventDate: $vm.eventDate, eventEndDate: $vm.eventEndDate, hasTriedSubmitting: $vm.hasTriedSubmitting, startDateError: $vm.startDateError, endDateError: $vm.endDateError, repeatedDays: $vm.repeatedDays)
                        
                        // view for start time selection
                        EventStartTimeView(startTime: $vm.startTime, hasTriedSubmitting: $vm.hasTriedSubmitting, startTimeError: $vm.startTimeError)
                        
                        // view for end time selection
                        EventEndTimeView(endTime: $vm.endTime, endTimeError: $vm.endTimeError, hasTriedSubmitting: $vm.hasTriedSubmitting)
                        
                        // view for location selection
                        EventLocationView(selectedPlacemark: $vm.selectedPlacemark, locationError: $vm.locationError, hasTriedSubmitting: $vm.hasTriedSubmitting)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $vm.selectedFriends, showInviteUsersSheet: $vm.showInviteUsersSheet)
                            .sheet(isPresented: $vm.showInviteUsersSheet) {
                                AddInvitedUsers(currentUser: vm.currentUser, selectedFriends: $vm.selectedFriends)
                            }
                        
                        // view for event notes input
                        EventNotesView(notes: $vm.notes, notesError: $vm.notesError, hasTriedSubmitting: $vm.hasTriedSubmitting, isFocused: $isFocused)
                        
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
            .onTapGesture {
                isFocused = nil
            }
            .padding(.top)
        }
        .alert(isPresented: $vm.showDeleteEventModal) {
            Alert(title: Text("Delete Event"),
                  message: Text("If you delete this event, you and other invited users will no longer be able to see it. This cannot be undone."),
                  primaryButton: .cancel(Text("Cancel"), action: {
                vm.showDeleteEventModal = false
            }), secondaryButton: .destructive(Text("Delete").foregroundStyle(Color("ErrorTextColor")), action: {
                Task {
                    await vm.deleteEvent()
                    vm.showDeleteEventModal = false
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        vm.shouldDismissToRoot = true
                    }
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
        .toolbar(.hidden, for: .tabBar)
        .modifier(EditEventViewModifier(showDeleteEventModal: $vm.showDeleteEventModal))
    }
}

struct EditEventViewModifier: ViewModifier {
    
    @Binding var showDeleteEventModal: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Event")
                        .foregroundStyle(Color("PrimaryText"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showDeleteEventModal = true
                    }, label: {
                        Image(systemName: "trash")
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color("IconColors"))
                    })
                }
            }
    }
}
