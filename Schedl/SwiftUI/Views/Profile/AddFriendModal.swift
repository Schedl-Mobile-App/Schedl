//
//  AddFriendView.swift
//  Schedoolr
//
//  Created by David Medina on 5/20/25.
//

import SwiftUI

struct AddFriendModal: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Would you like to send a friend request?")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
            HStack(alignment: .center, spacing: 15) {
                Button(action: {
                    profileViewModel.showAddFriendModal.toggle()
                }) {
                    Text("Cancel")
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
                        await profileViewModel.sendFriendRequest()
                        profileViewModel.showAddFriendModal.toggle()
                    }
                }) {
                    Text("Send")
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
