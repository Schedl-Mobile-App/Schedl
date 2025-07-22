//
//  Untitled.swift
//  Schedl
//
//  Created by David Medina on 7/21/25.
//

import SwiftUI

struct BackdropView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pink background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.92, green: 0.85, blue: 0.95),
                        Color(red: 0.89, green: 0.80, blue: 0.92)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // White overlay card with backdrop effect
                VStack(spacing: 0) {
                    // Top spacer to position the card
                    Spacer()
                        .frame(height: geometry.size.height * 0.35)
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 48)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 48)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .frame(maxWidth: geometry.size.width * 0.7, maxHeight: .infinity, alignment: .leading)
                            .offset(y: -75)
                            
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.92, green: 0.85, blue: 0.95),
                                Color(red: 0.89, green: 0.80, blue: 0.92)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 48))
                        .frame(maxWidth: geometry.size.width * 0.3, maxHeight: 100, alignment: .topTrailing)
                        .offset(y: -75)
                        .zIndex(99)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 48)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 48)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

// Alternative approach with more pronounced backdrop blur
struct AlternativeBackdropView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pink background with subtle texture
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.94, green: 0.87, blue: 0.96), location: 0.0),
                                .init(color: Color(red: 0.88, green: 0.78, blue: 0.91), location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.35)
                    
                    // Card with glassmorphism effect
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.regularMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color.white.opacity(0.7))
                                )
                        )
                        .shadow(color: Color(red: 0.7, green: 0.5, blue: 0.8).opacity(0.15), radius: 25, x: 0, y: -8)
                        .shadow(color: Color.black.opacity(0.08), radius: 50, x: 0, y: -15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 0)
            }
        }
    }
}

// Clean approach focusing on the exact visual hierarchy
struct MinimalBackdropView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base pink background
                Color(red: 0.91, green: 0.83, blue: 0.94)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top area remains pink
                    Spacer()
                        .frame(height: geometry.size.height * 0.38)
                    
                    // Bottom white card area
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: 30,
                            x: 0,
                            y: -10
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    BackdropView()
}
