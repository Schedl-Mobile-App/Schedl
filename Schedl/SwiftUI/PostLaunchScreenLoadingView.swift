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

//#Preview {
//    ClockView()
//}
//
//import SwiftUI
//
//struct ClockView: View {
//    var body: some View {
//        TimelineView(.animation) { timeline in
//            let date = timeline.date
//            
//            Canvas { context, size in
//                let center = CGPoint(x: size.width / 2, y: size.height / 2)
//                
//                // Draw clock face
//                context.stroke(
//                    Path { path in
//                        path.addEllipse(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//                    },
//                    with: .color(.gray),
//                    lineWidth: 2
//                )
//                
//                // Calculate second hand angle
//                let calendar = Calendar.current
//                let seconds = Double(calendar.component(.second, from: date))
//                
//                let angle = Angle.degrees(seconds * 6)
//                
//                // Draw second hand
//                var secondHand = Path()
//                secondHand.move(to: center)
//                secondHand.addLine(to: CGPoint(
//                    x: center.x + cos(angle.radians - .pi/2) * (size.width / 2 - 10),
//                    y: center.y + sin(angle.radians - .pi/2) * (size.height/ 2 - 10)
//                ))
//                
//                context.stroke(secondHand, with: .color(.red), lineWidth: 2)
//            }
//        }
//        .frame(width: 200, height: 200)
//    }
//}
