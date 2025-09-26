//
//  EventDetailsLoadingView.swift
//  Schedl
//
//  Created by David Medina on 9/11/25.
//

import SwiftUI

struct EventDetailsLoadingView: View {
    
    var bgColor: String
        
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            ZStack(alignment: .topLeading) {
                LighterShimmerEffectBox()
                    .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.65, alignment: .leading)
                    .frame(height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 30)
                    
                HStack {
                    Circle()
                        .frame(width: 55, height: 55)
                        .overlay {
                            LighterShimmerEffectBox()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                }
                .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.875, alignment: .trailing)
                .padding(.top, 15)
            }
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: 0x666666))
                .frame(maxWidth: .infinity)
                .frame(height: 0.75)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    VStack(alignment: .leading, spacing: 10) {
                        LighterShimmerEffectBox()
                            .frame(width: 100, height: 22.5)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        HStack {
                            LighterShimmerEffectBox()
                                .frame(width: 30, height: 25)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            LighterShimmerEffectBox()
                                .frame(maxWidth: .infinity)
                                .frame(height: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        LighterShimmerEffectBox()
                            .frame(width: 100, height: 22.5)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        HStack {
                            LighterShimmerEffectBox()
                                .frame(width: 30, height: 25)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            LighterShimmerEffectBox()
                                .frame(maxWidth: .infinity)
                                .frame(height: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        LighterShimmerEffectBox()
                            .frame(width: 100, height: 22.5)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                LighterShimmerEffectBox()
                                    .frame(width: 30, height: 25)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                VStack(alignment: .leading, spacing: 4) {
                                    LighterShimmerEffectBox()
                                        .frame(width: 150, height: 20)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    LighterShimmerEffectBox()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    HStack {
                                        Spacer()
                                        LighterShimmerEffectBox()
                                            .frame(width: 100, height: 22.5)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        LighterShimmerEffectBox()
                            .frame(width: 125, height: 25)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        HStack {
                            Circle()
                                .frame(width: 60, height: 60)
                                .overlay {
                                    LighterShimmerEffectBox()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                            
                            VStack(alignment: .leading) {
                                LighterShimmerEffectBox()
                                    .frame(width: 120, height: 20)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                LighterShimmerEffectBox()
                                    .frame(width: 100, height: 20)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .defaultScrollAnchor(.top, for: .initialOffset)
            .defaultScrollAnchor(.bottom, for: .sizeChanges)
        }
        .padding(.horizontal)
        .background {
            Image("customBackground")
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.vertical) { height, axis in
                    return height + 175
                }
                .padding(.top, 230)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct LighterShimmerEffectBox: View {
    private var gradientColors = [
        Color(hex: 0xFCFAF8), // very close to background, softer
        Color(hex: 0xFEFEFE), // softer highlight (slightly off-white)
        Color(hex: 0xFCFAF8)  // mirror tone
    ]
    @State var startPoint: UnitPoint = .init(x: -1.8, y: -1.2)
    @State var endPoint: UnitPoint = .init(x: 0, y: -0.2)
    
    var body: some View {
        LinearGradient (colors: gradientColors,
                        startPoint: startPoint,
                        endPoint: endPoint)
        .onAppear {
            withAnimation (.easeInOut (duration: 1.25)
                .repeatForever (autoreverses: false)) {
                    startPoint = .init(x: 1, y: 1)
                    endPoint = .init(x: 2.2, y: 2.2)
                }
        }
    }
}

#Preview {
    EventDetailsLoadingView(bgColor: "CBACCE")
}
