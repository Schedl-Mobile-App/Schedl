//
//  View+Extension.swift
//  Schedoolr
//
//  Created by David Medina on 5/17/25.
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()   // built-in hidden fills the space
        } else {
            self
        }
    }
}
