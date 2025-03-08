//
//  SidebarView.swift
//  Schedoolr
//
//  Created by David Medina on 3/6/25.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    @State var showMySchedules = false
    @State var showFriendsSchedules = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
            
            // Sidebar content
            VStack(alignment: .leading, spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 24))
                            .padding()
                    }
                }
                .padding(.top, 50)
                
                // Schedule title
                Text(scheduleViewModel.schedule?.title ?? "David's Schedule")
                    .font(.system(size: 20, design: .monospaced))
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // My Schedules section
                HStack(alignment: .center, spacing: 10) {
                    Text("My Schedules")
                        .font(.system(size: 20, design: .monospaced))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showMySchedules ? 180 : 0))
                        .animation(.easeInOut, value: showMySchedules)
                }
                .padding()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(width: 1, edges: [.top], color: Color.primary)
                .onTapGesture {
                    showMySchedules.toggle()
                }
                
                // Friends Schedules section
                HStack(alignment: .center, spacing: 10) {
                    Text("Friends Schedules")
                        .font(.system(size: 20, design: .monospaced))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showFriendsSchedules ? 180 : 0))
                        .animation(.easeInOut, value: showFriendsSchedules)
                }
                .padding()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(width: 1, edges: [.top, .bottom], color: Color.primary)
                .onTapGesture {
                    showFriendsSchedules.toggle()
                }
                
                Spacer()
            }
            .frame(width: 275)
            .background(Color.white)
        }
        .ignoresSafeArea(.all, edges: .vertical)
        .transition(.move(edge: .leading))
    }
}

