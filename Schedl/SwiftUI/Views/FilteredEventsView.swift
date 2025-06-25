//
//  FilteredEventsView.swift
//  Schedl
//
//  Created by David Medina on 6/24/25.
//

import SwiftUI

enum searchParameters {
    case title, location, date, all
}

struct FilteredEventsView: View {
    
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    @State var searchText = ""
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Button {}
                    label : {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .imageScale(.medium)
                    }
                    
                    TextField("Search by ", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .autocorrectionDisabled(true)
                    
                    Spacer()
                    
                    Button("Clear", action: {
                        searchText = ""
                    })
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .opacity(searchText.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .padding(.top)
            }
        }
    }
}
