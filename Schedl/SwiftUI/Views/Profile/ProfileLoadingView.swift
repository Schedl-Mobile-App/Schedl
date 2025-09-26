//
//  ProfileLoadingView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct ProfileLoadingView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            VStack(spacing: 8) {
                
                // profile view
                ShimmerEffectBox()
                    .cornerRadius(114)
                    .frame(width: 120, height: 120)
                
                ShimmerEffectBox()
                    .cornerRadius(15)
                    .frame(width: 140, height: 25)
            }
            
            Rectangle()
                .cornerRadius(15)
                .overlay {
                    ShimmerEffectBox()
                        .cornerRadius(15)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: 75, alignment: .center)
                .padding(.horizontal, 60)
            
            ShimmerEffectBox()
                .cornerRadius(30)
                .frame(maxWidth: .infinity, maxHeight: 45, alignment: .center)
                .padding(.horizontal, 20)
            
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
        .padding(.top)
    }
}

#Preview {
    ProfileLoadingView()
}
