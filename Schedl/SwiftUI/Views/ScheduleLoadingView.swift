//
//  ScheduleLoadingView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct ScheduleLoadingView: View {
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(alignment: .center) {
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: 200, height: 25)
                    Spacer()
                    ShimmerEffectBox()
                        .cornerRadius(8)
                        .frame(width: 25, height: 25)
                }
                .padding(.horizontal)
                
                GeometryReader { geometry in
                    let colWidth = 60
                    let rowHeight = 100
                    let columns: Int = Int(geometry.size.width / CGFloat(colWidth))
                    let rows: Int = Int(geometry.size.height / CGFloat(rowHeight))
                    
                    ZStack {
                        ForEach(0...columns, id: \.self) { col in
                            ShimmerEffectBox()
                                .cornerRadius(15)
                                .frame(width: 30, height: 10)
                                .position(x: CGFloat(col) * CGFloat(colWidth) + 22, y: -35)
                        }
                        
                        ForEach(0...columns, id: \.self) { col in
                            ShimmerEffectBox()
                                .cornerRadius(15)
                                .frame(width: 20, height: 10)
                                .position(x: CGFloat(col) * CGFloat(colWidth) + 17, y: -20)
                        }
                        
                        ForEach(0...columns, id: \.self) { col in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 1, height: 45)
                                    .position(x: CGFloat(col+1) * CGFloat(colWidth) , y: -25)
                        }
                    }
                    .offset(x: 49, y: 0)
                    
                    VStack(spacing: 0) {
                        ForEach(0...rows, id: \.self) { row in
                            ShimmerEffectBox()
                                .cornerRadius(15)
                                .frame(width: 30, height: 8)
                                .offset(x: 10, y: CGFloat(row) * CGFloat(rowHeight) - CGFloat(row) * 9-2)
                        }
                    }
                    
                    ZStack {
                        // Vertical lines
                        ForEach(0...columns, id: \.self) { col in
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 1, height: geometry.size.height)
                                .position(x: CGFloat(col+1) * CGFloat(colWidth), y: geometry.size.height / 2)
                        }
                        // Horizontal lines
                        ForEach(0...rows, id: \.self) { row in
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: geometry.size.width, height: 1)
                                .position(x: geometry.size.width / 2, y: CGFloat(row) * CGFloat(rowHeight) )
                        }
                    }
                    .offset(x: 49, y: 0)
                }
                .padding(.top, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
        }
    }
}

#Preview {
    ScheduleLoadingView()
}
