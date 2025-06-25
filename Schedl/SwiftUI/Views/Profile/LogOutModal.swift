//
//  LogOutModal.swift
//  Schedl
//
//  Created by David Medina on 6/23/25.
//

import SwiftUI

struct LogOutModal: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Are you sure you want to log out?")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
            HStack(alignment: .center, spacing: 15) {
                Button(action: {
                    profileViewModel.showLogoutModal.toggle()
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
                    profileViewModel.showLogoutModal.toggle()
                    Task {
                        await authViewModel.logout()
                    }
                }) {
                    Text("Yes")
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

