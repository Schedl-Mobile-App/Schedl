//
//  Tab.swift
//  Schedoolr
//
//  Created by David Medina on 1/19/25.
//

import SwiftUI

enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case schedules, posts, tagged, likes
    
    internal var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .schedules:
            return "Schedules"
        case .posts:
            return "Posts"
        case .tagged:
            return "Tagged"
        case .likes:
            return "Likes"
        }
    }
    
    var color: Color {
        switch self {
        case .schedules:
            return .indigo
        case .posts:
            return .pink
        case .tagged:
            return .orange
        case .likes:
            return .yellow
        }
    }
}
