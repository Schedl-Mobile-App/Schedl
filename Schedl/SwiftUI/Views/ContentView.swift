import SwiftUI

struct CustomBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Starting from top center, moving clockwise
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.1))
        
        // Top right curve
        path.addCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.3),
            control1: CGPoint(x: width * 0.7, y: height * 0.1),
            control2: CGPoint(x: width * 0.85, y: height * 0.2)
        )
        
        // Right side curve
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.6),
            control1: CGPoint(x: width * 0.9, y: height * 0.4),
            control2: CGPoint(x: width * 0.85, y: height * 0.5)
        )
        
        // Bottom right curve
        path.addCurve(
            to: CGPoint(x: width * 0.6, y: height * 0.85),
            control1: CGPoint(x: width * 0.8, y: height * 0.75),
            control2: CGPoint(x: width * 0.7, y: height * 0.85)
        )
        
        // Bottom center curve
        path.addCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.9),
            control1: CGPoint(x: width * 0.5, y: height * 0.9),
            control2: CGPoint(x: width * 0.42, y: height * 0.92)
        )
        
        // Bottom left curve
        path.addCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.65),
            control1: CGPoint(x: width * 0.25, y: height * 0.85),
            control2: CGPoint(x: width * 0.1, y: height * 0.75)
        )
        
        // Left side curve
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.35),
            control1: CGPoint(x: width * 0.1, y: height * 0.5),
            control2: CGPoint(x: width * 0.15, y: height * 0.42)
        )
        
        // Top left curve back to start
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.1),
            control1: CGPoint(x: width * 0.2, y: height * 0.25),
            control2: CGPoint(x: width * 0.32, y: height * 0.1)
        )
        
        path.closeSubpath()
        return path
    }
}

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Custom blob shape taking up half the screen height
                CustomBlobShape()
                    .fill(Color(red: 0.95, green: 0.94, blue: 0.92))
                    .frame(height: geometry.size.height / 2)
                    .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Remaining space
                Color.white
                    .frame(height: geometry.size.height / 2)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
