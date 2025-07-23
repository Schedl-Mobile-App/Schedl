//
//  ContentView.swift
//  Schedl
//
//  Created by David Medina on 7/23/25.
//


import SwiftUI

struct CutoutShape: Shape {
    var cornerRadius: CGFloat = 20
    var cutoutWidth: CGFloat = 80
    var cutoutHeight: CGFloat = 40
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at the point where the cutout begins on the top edge
        let cutoutStartX = rect.minX + cutoutWidth
        let cutoutStartY = rect.minY
        
        // Start the path at the cutout start point
        path.move(to: CGPoint(x: cutoutStartX, y: cutoutStartY))
        
        // Top edge to top-right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        
        // Left edge up to where the cutout begins
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cutoutHeight + cornerRadius))
        
        // Create the complex curved cutout section that slopes down and back up
        // This creates a smooth "scoop" or "U" shape
        
        // First control point - creates the initial downward slope (gentler)
        let controlPoint1 = CGPoint(
            x: rect.minX + cutoutWidth * 0.3,
            y: rect.minY + cutoutHeight * 1
        )
        
        // Midpoint of the curve - the deepest part of the scoop (less deep, more rounded)
        let midPoint = CGPoint(
            x: rect.minX + cutoutWidth * 0.9,
            y: rect.minY + cutoutHeight * 1.3
        )
        
        // Second control point - creates the upward slope back to the top edge (gentler)
        let controlPoint2 = CGPoint(
            x: rect.minX + cutoutWidth * 0.3,
            y: rect.minY + cutoutHeight * 1.1
        )
        
        // Create the smooth scoop using cubic curves with gentler slopes
        path.addCurve(
            to: midPoint,
            control1: controlPoint1,
            control2: CGPoint(
                x: rect.minX + cutoutWidth * 0.9,
                y: rect.minY + cutoutHeight * 1.5
            )
        )
        
        path.addCurve(
            to: CGPoint(x: cutoutStartX, y: cutoutStartY),
            control1: CGPoint(
                x: rect.minX + cutoutWidth * 0.55,
                y: rect.minY + cutoutHeight * 1.25
            ),
            control2: controlPoint2
        )
        
        return path
    }
}

// Example usage with preview
struct ContentView: View {
    var body: some View {
        VStack(spacing: 30) {
            // Basic cutout shape matching the image
            CutoutShape(cornerRadius: 15, cutoutWidth: 100, cutoutHeight: 60)
                .fill(Color.blue)
                .frame(width: 200, height: 150)
            
            // Smaller cutout
            CutoutShape(cornerRadius: 20, cutoutWidth: 80, cutoutHeight: 50)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 250, height: 180)
            
            // With stroke to see the shape clearly
            CutoutShape(cornerRadius: 12, cutoutWidth: 70, cutoutHeight: 45)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 180, height: 120)
            
            // Larger cutout
            CutoutShape(cornerRadius: 18, cutoutWidth: 120, cutoutHeight: 70)
                .fill(Color.orange)
                .frame(width: 220, height: 160)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
