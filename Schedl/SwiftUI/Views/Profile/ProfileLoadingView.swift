//
//  ProfileLoadingView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct ProfileLoadingView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack {
                HStack {
                    ShimmerEffectBox()
                        .cornerRadius(15)
                        .frame(width: 60, height: 15, alignment: .leading)
                    Spacer()
                    ShimmerEffectBox()
                        .cornerRadius(30)
                        .frame(width: 30, height: 30)
                }
                .frame(maxWidth: .infinity)
                
                ShimmerEffectBox()
                    .cornerRadius(15)
                    .frame(width: 100, height: 20)
            }
            .padding()
            
            VStack(spacing: 12) {
                
                // profile view
                ShimmerEffectBox()
                    .cornerRadius(114)
                    .frame(width: 120, height: 120)
                
                ShimmerEffectBox()
                    .cornerRadius(15)
                    .frame(width: 140, height: 20)
            }
            
            Rectangle()
                .cornerRadius(15)
                .overlay {
                    ShimmerEffectBox()
                        .cornerRadius(15)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
                .padding(.horizontal, 50)
            
            ShimmerEffectBox()
                .cornerRadius(30)
                .frame(maxWidth: .infinity, maxHeight: 45, alignment: .center)
                .padding(.horizontal, 25)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(height: 200)
                        .padding(.horizontal, 25)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(height: 200)
                        .padding(.horizontal, 25)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ProfileLoadingView()
}
