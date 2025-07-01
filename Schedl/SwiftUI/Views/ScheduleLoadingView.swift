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
            Color(hex: 0xF6F4F2)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: 30, height: 30)
                    
                    ShimmerEffectBox()
                        .cornerRadius(15)
                        .frame(width: 175, height: 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                
                HStack(alignment: .center) {
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: 135, height: 25)
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
//                    let colWidth = geometry.size.width / CGFloat(columns)
//                    let rowHeight = geometry.size.height / CGFloat(rows)
                    
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
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(1) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 - CGFloat(rowHeight))
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(1) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 + CGFloat(rowHeight) * 2)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(rowHeight))
                        .position(x: CGFloat(2) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 - CGFloat(rowHeight) * 2)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*2.25))
                        .position(x: CGFloat(2) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 + CGFloat(Double(rowHeight)*0.75))
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(3) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 - CGFloat(rowHeight) * 0.5)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(3) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 + CGFloat(rowHeight) * 1.5)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(4) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 - CGFloat(rowHeight) * 1.25)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(5) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 + CGFloat(rowHeight) * 0.5)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(5) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 + CGFloat(rowHeight) * 2.5)
                    
                    ShimmerEffectBox()
                        .cornerRadius(10)
                        .frame(width: CGFloat(colWidth)-4, height: CGFloat(Double(rowHeight)*1.25))
                        .position(x: CGFloat(6) * CGFloat(colWidth) + 19, y: geometry.size.height / 2 - CGFloat(rowHeight) * 2)
                }
                .padding(.top, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 5)
        }
    }
}

#Preview {
    ScheduleLoadingView()
}
