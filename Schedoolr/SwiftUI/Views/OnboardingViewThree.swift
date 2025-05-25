//
//  OnboardingViewThree.swift
//  Schedoolr
//
//  Created by David Medina on 5/18/25.
//

import SwiftUI

struct OnboardingViewThree: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            VStack(alignment: .center) {
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .overlay {
                        Text("📱")
                            .font(.system(size: 72))
                    }
                    .padding(.top, 30)
                Spacer(minLength: 75)
                VStack(alignment: .center, spacing: 20) {
                    Text("Share Your Moments")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("Turn your events into social posts. Add photos tag friends, and create memories together.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: 0x333333))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .lineSpacing(7)
                }
                .padding(.bottom, 30)
                
                HStack(alignment: .center) {
                    Circle()
                        .foregroundStyle(Color.black.opacity(0.1))
                        .frame(width: 9, height: 9)
                    Circle()
                        .foregroundStyle(Color.black.opacity(0.1))
                        .frame(width: 9, height: 9)
                    Capsule()
                        .fill(Color(hex: 0x47a2be))
                        .frame(width: 20, height: 9)
                }
                .padding(.bottom, 15)
                
                Button(action: {
                    UserDefaults.standard.hasOnboarded = true
                    authViewModel.hasOnboarded.toggle()
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: 0xf7f4f2))
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color(hex: 0x47a2be))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.bottom, 35)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}
