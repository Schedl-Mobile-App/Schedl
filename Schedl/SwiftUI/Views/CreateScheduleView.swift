//
//  CreateScheduleView.swift
//  Schedl
//
//  Created by David Medina on 9/16/25.
//

import SwiftUI

struct CreateScheduleView: View {
        
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @Environment(\.dismiss) var dismiss
    
    @FocusState var isFocused: EventInfoFields?
    
    init(scheduleViewModel: ScheduleViewModel) {
        _scheduleViewModel = ObservedObject(initialValue: scheduleViewModel)
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Fill out the details below to create your schedule!")
                        .font(.body)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("PrimaryText"))
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 0) {
                        
                    }
                    
                    Button(action: {
//                        Task {
//                            await scheduleViewModel.createSchedule(title: "")
//                            if scheduleViewModel.shouldDismiss {
//                                scheduleViewModel.shouldReloadData = true
//                                dismiss()
//                            }
//                        }
                    }, label: {
                        Text("Create Event")
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
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 25)
                .simultaneousGesture(TapGesture().onEnded {
                })
            }
            .defaultScrollAnchor(.top, for: .initialOffset)
            .scrollDismissesKeyboard(.immediately)
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Schedule")
                    .foregroundStyle(Color("PrimaryText"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
        }
    }
}
