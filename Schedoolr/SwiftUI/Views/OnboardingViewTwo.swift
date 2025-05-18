//
//  OnboardingViewTwo.swift
//  Schedoolr
//
//  Created by David Medina on 5/18/25.
//

import SwiftUI

struct OnboardingViewTwo: View {
    
    @State var continueOnboarding: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            VStack(alignment: .center) {
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .overlay {
                        Text("👥")
                            .font(.system(size: 72))
                    }
                    .padding(.top, 30)
                Spacer(minLength: 75)
                VStack(alignment: .center, spacing: 20) {
                    Text("Connect with Friends")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("Find your friends, follow their schedules, and stay connected with what everyone is up to.")
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
                    Capsule()
                        .fill(Color(hex: 0x47a2be))
                        .frame(width: 20, height: 9)
                    Circle()
                        .foregroundStyle(Color.black.opacity(0.1))
                        .frame(width: 9, height: 9)
                }
                .padding(.bottom, 15)
                
                HStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        UserDefaults.standard.hasOnboarded = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.black.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Button(action: {
                        continueOnboarding.toggle()
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: 0xf7f4f2))
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color(hex: 0x47a2be))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.bottom, 35)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 30)
        }
        .navigationDestination(isPresented: $continueOnboarding) {
            OnboardingViewThree()
        }
        .navigationBarBackButtonHidden(true)
    }
}
