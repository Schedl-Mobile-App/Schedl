//
//  ProfileInformatics.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct ProfileInformatics: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0xe0dad5))
            .cornerRadius(15)
            .overlay {
                HStack {
                    NavigationLink(destination: FriendsView(profileViewModel: profileViewModel)) {
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(profileViewModel.friends.count)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: 0x333333))
                            Text("Friends")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color(hex: 0x666666))
                                .tracking(0.01)
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 50)
                        .background(Color(hex: 0xc0b8b2))
                    VStack(alignment: .center, spacing: 6) {
                        Text("\(profileViewModel.userEvents.count)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Events")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.01)
                            .fixedSize()
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                        .foregroundStyle(Color(hex: 0xc0b8b2))
                        .frame(maxWidth: 1.75, maxHeight: 50)
                        .background(Color(hex: 0xc0b8b2))
                    
                    VStack(alignment: .center, spacing: 6) {
                        Text("\(profileViewModel.userPosts.count)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Posts")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.01)
                            .fixedSize()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
            .padding(.horizontal, 50)
    }
}
