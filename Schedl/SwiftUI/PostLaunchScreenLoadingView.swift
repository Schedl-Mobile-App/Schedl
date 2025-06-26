//
//  PostLaunchScreenLoadingView.swift
//  Schedl
//
//  Created by David Medina on 6/24/25.
//

import SwiftUI

struct PostLaunchScreenLoadingView: View {
    
    var body: some View {
        ZStack {
            Color(hex: 0x0887A1)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 33)
                        .fill(Color(hex: 0xF6F4F2))
                        .frame(width: 128, height: 128)
                    
                    RoundedRectangle(cornerRadius: 17)
                        .fill(Color(hex: 0x0887A1))
                        .frame(width: 90, height: 90)
                    
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                }
                
                Text("Schedl")
                    .font(.custom("GillSans-Bold", size: 36))
                    .foregroundStyle(Color(hex: 0xF6F4F2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.top, 25)
        }
    }
}

#Preview {
    PostLaunchScreenLoadingView()
}
